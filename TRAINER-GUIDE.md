# NWLEGACY – Trainer guide (answer key)

This guide catalogs everything that was planted in NWLEGACY for modernization
training:
* legacy coding patterns
* the architecture
* logic that was copied and has since drifted apart
* latent bugs

Use it to check what trainees, with or without AI help, find, explain and fix.

References give the **program and subroutine** (and change marker), because
line numbers move as soon as someone edits the code. The modern
`northwind-ibmi` package is the "after" picture for most exercises.

---

## 1. The story the code tells

The change logs (columns 1–5 markers and program headers) describe 25 years of
maintenance:

| Year | Who | What happened |
|---|---|---|
| 1988–89 | RKM | Original RPG III system: customers, order entry and inquiry, invoice, the NW700R report |
| 1991 | DLW | Employees and products added, based on NW100R |
| 1994–96 | DLW, BJT | Phone/fax edits and employee notes. Suppliers "copied from NW100R" |
| 1997 | JS | F4 prompt windows NW190R/NW490R |
| 1998 | RKM | Small tables moved into one code file CODTBL, maintained by NW500R |
| 1999 | JS | Y2K: order dates become CYYMMDD with a window (YY < 40 = 20YY). Customer and "entered" dates were missed |
| 2001–03 | JS, RKM, TPK | DATCHK copy member (only one program uses it). Inventory relief. CVTRPGSRC to RPG IV, except NW700R |
| 2004–11 | TPK, MH | Logical delete, cancel order, territories, demographic types (NW520R cloned from NW510R) |

---

## 2. Legacy language patterns (where to find them)

| # | Pattern | Examples |
|---|---|---|
| L1 | Fixed-format C-specs (factor 1 / opcode / factor 2 / result) | every RPG member |
| L2 | **RPG/400 never converted**, using the **RPG cycle** (primary file, `L1` level break, `LR` totals, blank-after `B` to reset a counter) | NW700R |
| L3 | Numbered indicators with program-wide meaning (50 = error, 90 = EOF, 92/93 = not found, 40/41 = protect, 31–34 subfile) | all |
| L4 | Indicator tricks: `MOVEA '0000000000' *IN(61)`, `*IN(J)` with a computed index, `*IN25` ROLLUP | NW600R `CALC`, NW200R mainline |
| L5 | `GOTO`/`TAG` loops (`MAIN`, `RELOAD`, `ENDPGM`), `CABxx` to leave loops, `GOTO` inside subroutines | all interactive programs |
| L6 | Old structured ops: `IFEQ`/`ANDEQ`/`OREQ`, `DOWEQ`, `CASEQ … ENDCS` | NW100R `PRCOPT`, NW600R `EDTHDR` |
| L7 | Fields defined on C-specs (result length), `*LIKE DEFINE`, `KLIST`/`KFLD`, `*ENTRY PLIST` | all |
| L8 | `MOVE`/`MOVEL` truncation and implicit conversion: numeric → char `'003'`; `MOVE` of CYYMMDD into 6 digits drops the century; order number moved into a message with leading zeros | NW400R `GETNAM`, NW610R `CYMMDY`, NW600R `WRTORD` |
| L9 | Positional data structures used to split dates; arrays overlaid on numbered screen fields | NW200R `DATDS`/`YMDDS`/`NOTDS`, NW600R `DAT6` and `LPRDDS`… |
| L10 | Compile-time arrays (`**CTDATA`), alternating arrays (`ALT`), `LOOKUP` | NW500R `TYP`/`TTL`, NW600R `PRMPRD` (first empty line), all `MSG` arrays |
| L11 | Program-described printer file with O-specs, `EXCPT` names, `OFLIND(*INOF)`, `PAGE`, edit codes | NW620R |
| L12 | Data areas: `*DTAARA DEFINE`, `IN *LOCK`, `OUT`, `UNLOCK`; the LDA via `UDS DTAARA(*LDA)` | NW400R, NW600R, NW620R, NW100R, NW610R |
| L13 | Mixed eras: `EVAL` and `CLEAR` dropped into fixed-format code | NW400R `EDTPRD`, NW610R `CANORD`, NW300R `ADDREC` |
| L14 | Change markers in columns 1–5, modification logs, commented-out code | NW100R `DLTREC` (old `DELETE`), NW300R `EDTCHK` (fax check) |
| L15 | Dead code: unused subroutine, unused messages | NW300R `OLDCHK`. MSG(5), MSG(7) and MSG(8) in NW100R. "Unused message" in NW510R/NW520R |
| L16 | Magic numbers and literals: subfile limits 500/999/200/300, status codes `D O S C`, table types, "call I.S. x4357" | throughout |
| L17 | DDS display files without INDARA; `ERRMSG` keywords in some display files, a message-line field in others | NW100D/NW300D/NW500D/NW510D/NW520D (ERRMSG) vs NW200D/NW400D/NW600D (message field) |
| L18 | OPM CL: hard-coded libraries, a global `MONMSG CPF0000` that hides every error, `SIGNOFF` from the menu | NW000C, NW700C |
| L19 | `OVRPRTF` wrapper CL around a print program; `SBMJOB` with a library-qualified `CALL` | NW620C, NW700C |
| L20 | Cryptic 6-character names (`CMCUST`, `OHORD#`), `#` in names, packed numerics, numeric dates in three formats | all DDS |

---

## 3. Architecture smells

* **Nothing is modular.** Every program does screen handling, validation,
  business rules and file I/O in one source member, with global variables
  shared between subroutines.
* **Business rules live in screen programs:**
  * pricing, inventory relief and the order total in NW600R
  * "cancel" in NW610R
  * the numbering rules in NW200R, NW300R, NW400R and NW600R
* **Programs talk through side channels:**
  * dynamic `CALL`/`PARM`: NW100R→NW520R, NW200R→NW510R, NW600R→NW190R, NW490R and NW620C
  * the **LDA**: NW100R option 8 → NW610R
  * **data areas** for next numbers
* **One true lookup table.** CODTBL holds regions, shippers, categories,
  territories and customer types. `CTALT1`/`CTALT2` mean different things per
  type: shipper phone, category description, or a territory's region code.
  Codes are formatted differently per type: `'1'` for shippers but `'001'` for
  categories.
* **Implicit data movement by name:**
  * NW300D fields `REF` the supplier file, so `CHAIN` puts data on the screen and `UPDATE` writes the screen back.
  * PF and LF share field names, so reading the LF overwrites the PF buffer.
* **No database integrity.** There are no constraints, no journaling and no
  commitment control. Referential checks are done in some programs and not
  others.

---

## 4. Duplicated logic and how the copies drifted

| Logic | Copies | Drift (what an AI should notice) |
|---|---|---|
| Load-all subfile with position-to | NW100R `LODSFL`, NW300R `LODSFL`, NW190R/NW490R `LOAD`, NW500R, NW510R/NW520R | NW100R skips logically deleted customers; NW190R does not, so the F4 window offers deleted customers. NW490R offers discontinued products. |
| Page-at-a-time subfile | NW200R `LODPAG`, NW400R `LODPAG` | Same bug in both: `SFLEND` is only set when EOF is hit, so with exactly 12 rows left the user sees "+" and rolls to an empty page. Neither supports roll-down. |
| Date validation | NW200R `DATCHK` (MMDDYYYY), copy member `DATCHK` (MMDDYY) used only by NW600R | Leap year is "divisible by 4" in both copies. NW100R, NW400R and NW610R validate no dates at all. |
| Date conversion | NW600R `CVTCYM`, NW610R `CYMMDY`, NW620R inline `DIV`/`MVR` | Three implementations of the same CYYMMDD rule: arithmetic, a `MOVE` that truncates, and division by 10000. |
| **Extended price** | NW600R `CALC` (half-adjust; discount entered in whole %), NW610R `DSPORD` (truncates), NW620R detail (rounds the net unit price, then multiplies) | **Order 10263, product 16 (13.90 × 60 less 25%):** inquiry shows **625.50**, the invoice prints **625.80**. 149 of the 830 converted orders print a different amount than the inquiry shows. |
| "Total" | NW600R stores `OHTOTL` without freight; NW610R lists it as "Total"; NW620R adds freight | Three meanings of the word "total". |
| Next number | NW200R/NW300R `SETGT *HIVAL` + `READP` + 1; NW400R data area locked during data entry; NW600R data area locked briefly | Three strategies. Two users adding at once collide (NW200R/NW300R) or wait (NW400R). |
| Phone/fax edit | NW100R `EDTCHK`, NW300R `EDTCHK` | The fax check was commented out in NW300R in 1997. |
| Delete confirmation | NW100R/NW200R/NW300R/NW400R `DLTREC` screens | NW500R deletes with no confirmation. |
| Messages | NW300R copied NW100R's messages; NW520R copied NW510R's | NW300R still says "Customer not found". NW520R says "Employee not on file" and "No territories assigned". |
| Customer validation | NW100R, NW520R, NW600R, NW610R | Only NW100R knows about logical delete (`CMSTAT = 'D'`). |

---

## 5. Latent bugs and data-integrity issues (bug-hunt answer key)

1. **Record locks during user think time.** NW100R, NW200R, NW300R and NW400R
   `CHAIN` the update file and then `EXFMT`. F12 never unlocks, so the record
   stays locked until the next I/O on that file. Display (option 5) also locks.
2. **Product rows stay locked in NW600R.** `CALC` chains the update-capable
   PRDMST for every line. The last product stays locked while the user looks
   at the screen, and other order takers get lock waits.
3. **NW400R holds the NWNXTPRD data-area lock** for the whole add screen.
4. **No commitment control in NW600R `WRTORD`.** It writes the header, then
   the lines, then updates stock one product at a time. A failure part-way
   leaves a partial order. The order number is consumed before anything is
   written, so numbers can be skipped.
5. **Inventory can go negative** (NW600R). Cancelling (NW610R `CANORD`) does
   not put stock back.
6. **Orphans and missing where-used checks:**
   * NW100R delete ignores open orders. MSG(5) "has open orders" exists but is never used.
   * NW300R deletes suppliers that have products.
   * NW400R deletes products that are on orders, so NW610R shows `*DELETED`.
   * NW500R deletes categories, regions and shippers that are in use.
   * NW200R deletes employees but leaves EMPNOT and EMPTER rows behind.
7. **Order entry accepts bad references.** It accepts logically deleted
   customers (no `CMSTAT` check) and discontinued products (no `PMDISC` check).
8. **Stale ship-to.** NW600R copies the ship-to address only when it is
   blank. If the user changes the customer, the order ships to the previous
   customer's address.
9. **Weak date rules in NW600R.** The required date is never compared with the
   order date. Discount is limited to whole percent, but stored discounts have
   two decimals.
10. **Stale LDA filter.** NW100R option 8 sets `LDCUST` and nothing clears it.
    Menu option 11 then opens NW610R filtered to the last customer viewed.
11. **Silent subfile limits:**
    * NW100R and NW300R stop at 500 rows.
    * NW610R stops at 999, and there are 830 orders today.
    * NW500R stops at 200 and the prompt windows at 300.
    * There is no "list truncated" message anywhere.
12. **NW610R list order is inconsistent.** It is oldest first when unfiltered
    (ORDHDR) and newest first when filtered (ORDHDRL1). It also reads the
    update-capable ORDHDR, locking as it goes.
13. **Y2K leftovers:**
    * The `YY < 40` window breaks in 2040.
    * `CMCRDT`/`CMCHDT` (MMDDYY) and `OHENTD` (MMDDYY) were never converted.
    * NW610R drops the century when it displays dates.
    * Leap-year rules are wrong for 1900/2100.
14. **Notes data loss (latent).** NW200R `NOTES` loads only the first 10
    lines, deletes *all* lines, then writes back 10. The longest converted
    note is 8 lines, so to show the loss, first add lines 110 and 120 to an
    employee with DFU or SQL. The converted notes are also split mid-word.
15. **Invisible duplicates.** NW100R's add-duplicate check finds logically
    deleted customers, so the user sees "Customer already exists" for an ID
    that is not in the list.
16. **Blocked output (fixed in 1990).** NW600R marker RKM90 shows `FEOD`
    before the invoice call. Without it, the order records were still in
    NW600R's output buffer and NW620R printed nothing. Ask trainees what
    `FEOD` does and what a modern fix would be.
17. **Hidden failures in CL.** NW000C's global `MONMSG` replaces every failure
    with "An error occurred". NW620C's `MONMSG` after `CALL` hides print
    failures.
18. **Updating the wrong record.** NW500R, marker TPK04, shows a fixed bug: a
    validation `CHAIN` on the same file moved the record pointer, so `UPDATE`
    hit the wrong record. The fix was to re-chain. Ask trainees why the fix
    was needed.
19. **Truncation everywhere:**
    * Supplier home pages are cut to 80 characters and wrap across two screen lines.
    * Category descriptions are cut to 30 characters in `CTALT1`.
    * Names are truncated in the subfiles.

---

## 6. Suggested exercises

1. **Explain** NW600R end to end with AI help: write a flow chart, an
   indicator map and a data dictionary. Check the result against sections 2–5.
2. **Characterize before you change.** Capture the current behaviour, for
   example the invoice amounts for order 10263, as tests, then refactor
   without changing the numbers. Afterwards, decide which pricing rule is
   *correct* and change it on purpose.
3. **RPG/400 → RPG IV → fully free.** Start with NW700R (cycle) and NW100R
   (GOTO/indicator-heavy). Replace the indicators with named indicators or an
   INDDS, and replace GOTO with structured loops.
4. **De-duplicate.** Extract date handling, pricing, next-number and the
   customer, product and employee lookups into service programs with
   prototypes. Make NW600R, NW610R and NW620R call one pricing procedure.
5. **Fix concurrency.** Use `CHAIN(N)` for display, re-read and compare before
   update (optimistic locking with a change timestamp), and stop holding data
   areas during user input.
6. **Transactions.** Journal the files and wrap order creation in commitment
   control (`COMMIT`/`ROLBK`).
7. **DDS → DDL.**
   * Generate `CREATE TABLE` with real `DATE` columns, primary and foreign
     keys, and check constraints.
   * Split CODTBL into proper tables.
   * Replace EMPNOT with a CLOB column.
   * Compare the result with the original NORTHWIND schema.
8. **SQL and APIs.** Replace native I/O in NW610R with embedded SQL, then
   expose order inquiry as a REST service.
9. **Bug hunt.** Give trainees section 5 as a scoring sheet only after the
   hunt.
10. **Compare with the target.** Map each NWLEGACY program to its counterpart
    in the modern `northwind-ibmi` package (service programs, Work-with
    panels, iRPGUnit tests).

---

## 7. Data notes (from the 1999 "conversion")

* Customers were stamped created/changed `11/23/99` by user `CONVERSION`.
* Order lines were renumbered 1..n per order, sorted by product.
* `OHTOTL` was computed with per-line rounding. That is a fourth variant of
  the price calculation, and it usually matches NW600R.
* Data area NWNXTORD starts at 11078 and NWNXTPRD at 78.
