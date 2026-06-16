libname sdtm xport "C:\Users\91936\Downloads\dm (1).xpt";
proc copy in = sdtm out = work;
run;
proc contents data = work.dm ;
run;
proc freq data =work.dm;
tables arm;
run;

data work.dm_clean;
set work.dm;
where armcd ne "Scrnfail";
Rfstdt = input (rfstdtc, yymmdd10.);
format Rfstdt yymmdd10.;
Rfendt = input (rfendtc , yymmdd10.);
format Rfendt yymmdd10.;
run;

ods pdf file = "C:\Users\91936\Downloads\dm_output.pdf";
ods noproctitle ;

proc freq data= work.dm_clean;
tables arm / nocum nopercent;
title "Distribution of subjects across Treatment Arm ";
run;

proc freq data = work.dm_clean ;
tables race / nocum nopercent ;
title "Distribution of subjects across Race in Treatment Arms";
run;

proc tabulate data =work.dm_clean;
class arm sex ;
var age ;
tables arm*sex, age*mean all ;
title "Demogarphics of average age of subjects across Treatment Arms";
run;

ods pdf close ;

libname sdtm xport "C:\Users\91936\Downloads\ae.xpt";
proc copy in = sdtm out = work;
run;
proc contents data = work.ae;
run;

proc sort data = work.ae;
by usubjid;
run;

proc sort data =work.dm_clean;
by usubjid;
run;

ods pdf file = "C:\Users\91936\Downloads\ae_output.pdf";
ods noproctitle;

data work.ae_dm;
merge work.dm_clean(in = a)  work.ae(in=b);
by usubjid ;
if a and b ;
run;
proc print data = work.ae_dm;
run;

proc sql ;
create table work.ae_output as
select
arm,
count(aeterm) as ae_count ,
sum(rfendt - rfstdt) as tot_exposure_days,
(count(aeterm)/ sum(rfendt - rfstdt))*100 as incidence_rate
from work.ae_dm
group by arm;
quit;

proc print data = work.ae_output ;
title "Adverse events in 100 days of exposure ";
run;

proc report data = work.ae_dm nowd;
column arm aeterm aesev aeser;
define arm/ order  "Treatment ARM";
define aeterm/ display "Adverse Event";
define aesev / display  "SEVERITY";
define aeser / display "Level";
title "Classification of Adverse events across Treatment Arms";
run;
proc print data = work.ae_dm;
run;

ods pdf close ;

libname sdtm xport "C:\Users\91936\Downloads\ex.xpt";
proc copy in = sdtm out = work;
run;

proc contents data =work.ex ;
run;

proc sort data = work.ex nodupkey;
by usubjid;
run;

ods pdf file = "C:\Users\91936\Downloads\adsl.pdf" ;
ods noproctitle;

data work.ex_dm;
merge work.dm_clean (in=a ) work.ex(in = b);
by usubjid;
if a ;
if b then SAFFL = 'Y';
ELSE SAFFL = 'N';
run;
proc print data = work.ex_dm;
run;

data work.adsl;
set work.ex_dm;
TRTSDT = RFSTDT ;
FORMAT TRTSDT YYMMDD10.;
TRTEDT = RFENDT ;
FORMAT TRTEDT YYMMDD10.;
TRTDUR = TRTEDT - TRTSDT ;
TRT01P = ARM ;
IF AGE <65 THEN AGEGR1 = '< 65';
ELSE IF AGE <=80 THEN AGEGR1 = "65 - 80";
ELSE AGEGR1 = '>80';
RUN;
PROC PRINT DATA = WORK.ADSL;
RUN;

ods pdf close ;
