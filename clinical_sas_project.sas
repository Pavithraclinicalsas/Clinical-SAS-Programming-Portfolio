libname sdtm xport "C:\Users\91936\Downloads\dm (1).xpt";
proc copy in = sdtm out = work;
run;
proc contents data = work.dm ;
run;
proc freq data =work.dm;
tables armcd;
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
quit;

proc freq data = work.dm_clean ;
tables race / nocum nopercent ;
title "Distribution of subjects across Race in Treatment Arms";
quit;

proc tabulate data =work.dm_clean;
class arm sex ;
var age ;
tables arm*sex, age*mean all ;
title "Demographics of average age of subjects across Treatment Arms";
quit;

ods pdf close ;

libname sdtm xport "C:\Users\91936\Downloads\ae.xpt";
proc copy in = sdtm out = work;
run;
proc contents data = work.ae;
quit;

proc sort data = work.ae;
by usubjid;
quit;

proc sort data =work.dm_clean;
by usubjid;
quit;

ods pdf file = "C:\Users\91936\Downloads\ae_output.pdf";
ods noproctitle;

data work.ae_listing;
merge work.dm_clean(in = a)  work.ae(in=b);
by usubjid ;
if a and b ;
run;

data work.ae_dm;
merge work.dm_clean (in =a) work.ae(in = b);
by usubjid ;
if a;
if missing(aeterm) then ae_flag = 0;
else ae_flag = 1;
run;

proc sort data=work.ae_dm out=work.ae_subj nodupkey;
by usubjid;
run;

proc sql ;
create table work.ae_output as
select
arm,
sum(ae_flag) as ae_count,
sum(rfendt - rfstdt) as tot_exposure_days,
calculated ae_count / calculated tot_exposure_days * 100 as incidence_rate
from work.ae_subj
group by arm;
quit;

proc print data = work.ae_output ;
title "Adverse events in 100 days of exposure ";
run;

proc report data = work.ae_listing nowd;
column arm aeterm aesev aeser;
define arm/ order  "Treatment ARM";
define aeterm/ display "Adverse Event";
define aesev / display  "SEVERITY";
define aeser / display "Level";
title "Classification of Adverse events across Treatment Arms";
quit;
proc print data = work.ae_listing;
run;

ods pdf close ;

libname sdtm xport "C:\Users\91936\Downloads\ex.xpt";
proc copy in = sdtm out = work;
run;
proc contents data =work.ex ;
quit;

proc sort data = work.ex;
by usubjid exstdtc;
run;

data work.ex_summary;
set work.ex;
by usubjid;
retain first_exstdtc;
length first_exstdtc last_exendtc 8;
format first_exstdtc last_exendtc yymmdd10.;
exstdt_num = input(exstdtc, yymmdd10.);
exendt_num = input(exendtc, yymmdd10.);
if first.usubjid then first_exstdtc = exstdt_num;
last_exendtc = max(last_exendtc, exendt_num);
if last.usubjid;
run;

ods pdf file = "C:\Users\91936\Downloads\adsl.pdf" ;
ods noproctitle;
title "Exposure and Derived Safety Population (ADSL)";

data work.ex_dm;
merge work.dm_clean (in=a ) work.ex_summary(in = b);
by usubjid;
if a ;
if b then SAFFL = 'Y';
ELSE SAFFL = 'N';
run;
proc print data = work.ex_dm;
run;

data work.adsl;
set work.ex_dm;
length AGEGR1 $8;
TRTSDT = first_exstdtc ;
FORMAT TRTSDT YYMMDD10.;
TRTEDT = last_exendtc ;
FORMAT TRTEDT YYMMDD10.;
TRTDUR = TRTEDT - TRTSDT ;
TRT01P = ARM ;
IF AGE <65 THEN AGEGR1 = '< 65';
ELSE IF AGE <=80 THEN AGEGR1 = '65 - 80';
ELSE AGEGR1 = '>80';
RUN;
Proc print data = work.ADSL;
run;

ods pdf close ;

