# NWLEGACY – Northwind Traders, the legacy way

This is a deliberately old-fashioned IBM i green-screen application for
**AI-assisted modernization training**. It does the same job as the modern
`northwind-ibmi` package, which has file maintenance, order entry and order
inquiry. Here, though, it is written the way much of the world's IBM i code
still looks:

* fixed-format RPG IV (converted from RPG III in 2003), plus one program never
  converted from **RPG/400** (`NW700R`, an RPG-cycle report)
* **no SQL, no service programs, no procedures, no unit tests**
* native record-level I/O against **DDS physical and logical files**
* numbered indicators, `GOTO`/`TAG`, `CABxx`, `CASxx`, `MOVE`/`MOVEL`/`Z-ADD`,
  `MOVEA` into `*IN`, `KLIST`, `*LIKE DEFINE`, result-field definitions,
  compile-time arrays, the LDA and data areas, and O-spec printing
* **OPM CL** (`CLP`) menu with hard-coded libraries and a global `MONMSG`
* logic copied from program to program, with the copies drifting apart over
  25 years of change-log entries

> `TRAINER-GUIDE.md` is the answer key. It catalogs the legacy patterns, the
> duplicated logic, the latent bugs and suggested exercises, with the program
> and subroutine for each. Keep it away from trainees until after an exercise.

## Contents

| Object | Type | Purpose |
|---|---|---|
| NW000C / NW000D | CLP + DSPF | Main menu (libraries hard-coded) |
| NW100R / NW100D | RPGLE + DSPF | Customers (load-all subfile, ERRMSG, logical delete, 8=Orders via LDA, 9=Types) |
| NW200R / NW200D | RPGLE + DSPF | Employees (page-at-a-time subfile, notes lines, 9=Territories) |
| NW300R / NW300D | RPGLE + DSPF | Suppliers ("copied from NW100R", screen fields REF the file) |
| NW400R / NW400D | RPGLE + DSPF | Products (list logic copied from NW200R, data-area numbering) |
| NW500R / NW500D | RPGLE + DSPF | One program for five code tables in one file (REG SHP CAT TER DEM) |
| NW510R / NW510D | RPGLE + DSPF | Employee territories (called from NW200R) |
| NW520R / NW520D | RPGLE + DSPF | Customer demographic types (line-for-line copy of NW510R) |
| NW190R / NW490R | RPGLE + DSPF | F4 select windows for customers / products (clones) |
| NW600R / NW600D | RPGLE + DSPF | Order entry: 10 fixed lines, arrays over screen fields, no commit |
| NW610R / NW610D | RPGLE + DSPF | Order inquiry: 4=Cancel, 5=Display, 6=Print |
| NW620C / NW620R | CLP + RPGLE | Invoice: OVRPRTF wrapper + program-described O-spec print |
| NW700C / NW700R | CLP + RPG/400 | Customer list by country: SBMJOB + RPG cycle with L1 break |
| DATCHK | /COPY member | Date check subroutine (used by NW600R only) |

Database (library **NWLEGDTA**):

| File | Contents |
|---|---|
| CUSMST | Customers |
| EMPMST | Employees |
| EMPNOT | Employee notes, in 60-character lines |
| SUPMST | Suppliers |
| PRDMST | Products |
| CODTBL | Regions, shippers, categories, territories and customer types |
| EMPTER | Employee territories |
| CUSDEM | Customer demographic types |
| ORDHDR | Order headers |
| ORDDTL | Order lines |

* Logical files: CUSMSTL1/L2, EMPMSTL1/L2, SUPMSTL1, PRDMSTL1, ORDHDRL1.
* Data areas: NWNXTORD (next order number), NWNXTPRD (next product number), NWCOMP (company name).

## Folder layout

```
qddssrc/   *.pf *.lf *.dspf      DDS (files and screens)
qrpglesrc/ *.rpgle               RPG IV fixed format (+ DATCHK copy member)
qrpgsrc/   *.rpg                 RPG/400 (RPG III)
qclsrc/    *.clp                 OPM CL
qsqlsrc/   nwlconv.sql           one-time data conversion  (setup only)
setup/     nwlbuild.clle         build program             (setup only)
```

## Set up

Prerequisite: the `NORTHWIND` schema is loaded, because the data is converted
from it.

1. Copy this folder to the IFS **root** file system, for example `/home/me/nwlegacy`.
   The root file system is case-insensitive, and the build relies on that.
2. Build:
   ```
   CRTLIB NWLEGPGM
   CRTSRCPF NWLEGPGM/QCLSRC RCDLEN(92)
   CPYFRMSTMF FROMSTMF('/home/me/nwlegacy/setup/nwlbuild.clle') +
              TOMBR('/QSYS.LIB/NWLEGPGM.LIB/QCLSRC.FILE/NWLBUILD.MBR') MBROPT(*REPLACE)
   CRTBNDCL NWLEGPGM/NWLBUILD SRCFILE(NWLEGPGM/QCLSRC)
   CALL NWLEGPGM/NWLBUILD PARM(('/home/me/nwlegacy' (*CHAR 128)))
   ```
   `NWLBUILD` performs these steps in order:
   1. It creates `NWLEGDTA` and `NWLEGPGM`. These names are hard-coded in the
      application, which is one of the legacy patterns.
   2. It copies the sources into source files.
   3. It creates the PFs, LFs and data areas.
   4. It runs the conversion script to load the data from NORTHWIND.
   5. It compiles the programs with `CRTBNDRPG DFTACTGRP(*YES)`, `CRTRPGPGM` and
      `CRTCLPGM`.
3. Run: `CALL NWLEGPGM/NW000C`.

`NWLBUILD` and `nwlconv.sql` are training scaffolding, not part of the legacy
application. They are written in modern style so the setup itself is
reliable. The application contains no SQL.

## Compiler notes

* The RPG IV members need `RCDLEN(112)`, because comments are kept in columns 81–100.
  RPG/400, DDS and CL members use `RCDLEN(92)`.
* All programs use the default activation group. They are plain `CALL`/`PARM`
  programs with no prototypes, as the original shop had.
* No IBM i system was available while this package was built. The sources were
  checked by script for column placement, overlapping screen fields, and that
  every name, tag and subroutine resolves.
