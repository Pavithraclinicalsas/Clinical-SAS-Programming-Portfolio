Clinical SAS Programming Portfolio
-----------------------------------
Hi, I'm Pavithra, a fresher in Clinical SAS Programming with a B.Tech in Biotechnology and a Post-Baccalaureate Diploma in Clinical SAS Programming. This repository has the SAS programs I have written while learning clinical trial data handling and CDISC standards.

-------------------------------------------------------------------------------------------------------------------------------------------------------------
Project: SDTM to ADSL, Demographics and Adverse Event Outputs

File: cdisc_pilot_dm_adsl_ae.sas

Data: Public CDISC Alzheimer's pilot study data (306 subjects, 3 treatment arms). The SDTM datasets DM, EX and AE were provided as XPT files. I did not map them from raw data. The programming of ADSL and all the outputs is mine.

-------------------------------------------------------------------------------------------------------------------------------------------------------------

What the program does:

---------
1. DM
---------
Imported the XPT file, checked the structure and the treatment arms
Removed screen failures, because they were not treated and are not part of the analysis
Converted ISO 8601 character dates to numeric SAS dates.

---------
2. EX
---------
Kept only records where a dose was given
Took the first start date and last end date for each subject, because a subject has many EX records and exposure needs one start and one end date.

---------
3. ADSL
---------
Merged DM and EX to get one record per subject
Derived SAFFL, TRTSDT, TRTEDT, TRTDUR, TRT01P and AGEGR1

---------------
4. Demographics
---------------
Number of subjects, age summary, sex and race by treatment arm
Based on the safety population, as baseline tables normally are

-----------------
5. Adverse events
-----------------
AE listing, AE severity by treatment arm, and subjects with at least one AE (n and %)
Each subject is counted once, and the denominator is all safety subjects in the arm
Derivation notes
SAFFL = "Y" if the subject has at least one EX record with a dose
TRTDUR = TRTEDT - TRTSDT + 1 (the first day is counted)
AGEGR1: <65, 65-80, >80

----------------------
QC checks in the code
----------------------
Record count vs distinct USUBJID in DM and ADSL (one record per subject)
Frequency checks of SAFFL, AGEGR1 and treatment arm
Checking the log for errors, warnings and merge notes

----------------
SAS skills used
----------------
DATA step, MERGE with IN= and BY-group processing, FIRST. processing, INPUT with informats and date handling, PROC SQL, PROC SORT, PROC CONTENTS, PROC FREQ, PROC MEANS, PROC TABULATE, PROC REPORT, ODS PDF, macro variable (%let)

-------
Output
-------
Three PDF outputs: demographics, AE summary and AE listing.

-----------
How to run
-----------
Download dm.xpt, ex.xpt and ae.xpt from the public CDISC pilot dataset.
Change the %let path = ...; line at the top of the program to your own folder.
Run the program in SAS and check the log.

----------------------------------------
Limitations (what I'm still working on)
----------------------------------------
ADSL is basic and has only the main variables
Tables and listings are simple, without full TLF shell formatting
No exposure-adjusted AE rates yet
I'm still learning regression analysis and SAS macros

-------------------------------------------------------
Contact
Email: pavithrabaskaran11@gmail.com
LinkedIn: linkedin.com/in/pavithrabaskarancontact
-------------------------------------------------------
