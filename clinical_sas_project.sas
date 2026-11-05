%let path = C:\Users\91936\Downloads;

libname dmx xport "&path.\dm (1).xpt";                                                                                                  
proc copy in = dmx out = work;                                                                                                          
run;                                                                                                                                    
                                                                                                                                 
proc contents data = work.dm;                                                                                                           
run;                                                                                                                                                                                                                                                                           
proc freq data = work.dm;                                                                                                               
tables armcd;                                                                                                                           
run;                                                                                                                                    
                                                                                                               
data work.dm_clean;                                                                                                                     
    set work.dm;                                                                                                                        
    where upcase(armcd) ne "SCRNFAIL";                                                                                                  
                                                                                                                                        
    rfstdt = input(rfstdtc, yymmdd10.);                                                                                                 
    format rfstdt yymmdd10.;                                                                                                            
    rfendt = input(rfendtc, yymmdd10.);                                                                                                 
    format rfendt yymmdd10.;                                                                                                            
run;                                                                                                                                    
                                                                                                                                                                                                     
proc sql;                                                                                                                               
    select count(*) as n_records,                                                                                                       
           count(distinct usubjid) as n_subjects                                                                                        
    from work.dm_clean;                                                                                                                 
quit;                                                                                                                                   
                                                                                                                                                                                                                                                                     
libname exx xport "&path.\ex.xpt";                                                                                                      
proc copy in = exx out = work;                                                                                                          
run;                                                                                                                                    
                                                                                                                                        
proc contents data = work.ex;                                                                                                           
run;   

data work.ex_dates;                                                                                                                     
    set work.ex;                                                                                                                        
    exstdt = input(exstdtc, yymmdd10.);                                                                                                 
    format exstdt yymmdd10.;                                                                                                            
    exendt = input(exendtc, yymmdd10.);                                                                                                 
    format exendt yymmdd10.;                                                                                                         
    where exdose > 0;                                                                                                                   
run;                                                                                                                                    
                                                                                                                                   
proc sql;                                                                                                                               
    create table work.ex_summary as                                                                                                     
    select usubjid,                                                                                                                     
           min(exstdt) as first_exstdt format = yymmdd10.,                                                                              
           max(exendt) as last_exendt format = yymmdd10.                                                                                
    from work.ex_dates                                                                                                                  
    group by usubjid;                                                                                                                   
quit;                                                                                                                                   
                                                                                                                                        
                                                                                                                                   
proc sort data = work.dm_clean;                                                                                                         
    by usubjid;                                                                                                                         
run;                                                                                                                                    
                                                                                                                                        
proc sort data = work.ex_summary;                                                                                                       
    by usubjid;                                                                                                                         
run;                                                                                                                                    
                                                                                                                                        
data work.adsl;                                                                                                                         
    merge work.dm_clean (in = a)                                                                                                        
          work.ex_summary (in = b);                                                                                                     
    by usubjid;                                                                                                                         
    if a;                                                                                                                                                                                                                                  
    length agegr1 $8 saffl $1;                                                                                                                                                                                                                                                                                                                  
    if b then saffl = "Y";                                                                                                              
    else saffl = "N";                                                                                                                                                                                          
    trtsdt = first_exstdt;                                                                                                              
    trtedt = last_exendt;                                                                                                               
    format trtsdt trtedt yymmdd10.;                                                                                                     
    if not missing(trtsdt) and not missing(trtedt) then                                                                                                                                                                                             
    trt01p = arm;                                                                                                                                                                                                                                 
    if missing(age) then agegr1 = "";                                                                                                   
    else if age < 65 then agegr1 = "<65";                                                                                               
    else if age <= 80 then agegr1 = "65-80";                                                                                            
    else agegr1 = ">80";                                                                                                                                                                                                                                                     
    keep studyid usubjid subjid siteid arm trt01p age agegr1                                                                            
         sex race saffl trtsdt trtedt trtdur;                                                                                           
run;  

proc sql;                                                                                                                               
    select count(*) as n_records,                                                                                                       
           count(distinct usubjid) as n_subjects                                                                                        
    from work.adsl;                                                                                                                     
quit;                                                                                                                                   
                                                                                                                                        
proc freq data = work.adsl;                                                                                                             
tables saffl agegr1 trt01p;                                                                                                             
run;                                                                                                                                    
                                                                                                                                        
proc means data = work.adsl n mean min max;                                                                                             
var trtdur;                                                                                                                             
class trt01p;                                                                                                                           
run;                                                                                                                                    
                                                                                                                                
ods pdf file = "&path.\demog_output.pdf";                                                                                               
ods noproctitle;                                                                                                                        
                                                                                                                                        
title "Number of Subjects by Treatment Arm (Safety Population)";                                                                        
proc freq data = work.adsl;                                                                                                             
    where saffl = "Y";                                                                                                                  
    tables trt01p / nocum;                                                                                                              
run;                                                                                                                                    
                                                                                                                                        
title "Age Summary by Treatment Arm (Safety Population)";                                                                               
proc means data = work.adsl n mean std median min max maxdec = 1;                                                                       
    where saffl = "Y";                                                                                                                  
    class trt01p;                                                                                                                       
    var age;                                                                                                                            
run;                                                                                                                                    
                                                                                                                                        
title "Sex by Treatment Arm (Safety Population)";                                                                                       
proc freq data = work.adsl;                                                                                                             
    where saffl = "Y";                                                                                                                  
    tables trt01p*sex / nocum nopercent;                                                                                                
run;                                                                                                                                    
                                                                                                                                        
title "Race by Treatment Arm (Safety Population)";                                                                                      
proc freq data = work.adsl;                                                                                                             
    where saffl = "Y";                                                                                                                  
    tables trt01p*race / nocum nopercent;                                                                                               
run;                                                                                                                                    
                                                                                                                                        
title "Mean Age by Treatment Arm and Sex (Safety Population)";                                                                          
proc tabulate data = work.adsl;                                                                                                         
    where saffl = "Y";                                                                                                                  
    class trt01p sex;                                                                                                                   
    var age;                                                                                                                            
    tables trt01p*sex, age*mean all;                                                                                                    
run;                                                                                                                                    
                                                                                                                                        
title;                                                                                                                                  
ods pdf close;   

libname aex xport "&path.\ae.xpt";                                                                                                      
proc copy in = aex out = work;                                                                                                          
run;                                                                                                                                    
                                                                                                                                        
proc contents data = work.ae;                                                                                                           
run;                                                                                                                                    
                                                                                                                                        
proc sort data = work.ae;                                                                                                               
    by usubjid;                                                                                                                         
run;    

data work.ae_listing;                                                                                                                   
    merge work.adsl (in = a keep = usubjid trt01p saffl)                                                                                
          work.ae (in = b drop = studyid domain);                                                                                       
    by usubjid;                                                                                                                         
    if a and b and saffl = "Y";                                                                                                         
run;                                                                                                                                    
                                                                                                                                   
data work.ae_subj;                                                                                                                      
    set work.ae;                                                                                                                        
    by usubjid;                                                                                                                         
    if first.usubjid;                                                                                                                   
    ae_flag = 1;                                                                                                                        
    keep usubjid ae_flag;                                                                                                               
run;                                                                                                                                    
                                                                                                                                        
data work.adsl_ae;                                                                                                                      
    merge work.adsl (in = a)                                                                                                            
          work.ae_subj (in = b);                                                                                                        
    by usubjid;                                                                                                                         
    if a;                                                                                                                               
    if saffl = "Y";                                                                               
    if missing(ae_flag) then ae_flag = 0;                                                                                               
run;                                                                                                                                    
                                                                                                                                   
proc sql;                                                                                                                               
    create table work.ae_output as                                                                                                      
    select trt01p as arm,                                                                                                               
           count(*) as n_subj,                                                                                                          
           sum(ae_flag) as n_ae_subj,                                                                                                   
           calculated n_ae_subj / calculated n_subj * 100                                                                               
               as pct format = 5.1                                                                                                      
    from work.adsl_ae                                                                                                                   
    group by trt01p;                                                                                                                    
quit;                                                                                                                                   
                                                                                                                                        
ods pdf file = "&path.\ae_output.pdf";                                                                                                  
ods noproctitle;                                                                                                                        
                                                                                                                                        
title "Subjects with at least One Adverse Event (Safety Population)";                                                                   
proc print data = work.ae_output noobs label;                                                                                           
    label arm = "Treatment Arm"                                                                                                         
          n_subj = "N"                                                                                                                  
          n_ae_subj = "Subjects with AE"                                                                                                
          pct = "%";                                                                                                                    
run;                                                                                                                                    
                                                                                                                                        
title "Adverse Events by Severity and Treatment Arm";                                                                                   
proc freq data = work.ae_listing;                                                                                                       
    tables trt01p*aesev / nocum nopercent;                                                                                              
run;                                                                                                                                    
                                                                                                                                        
title "Adverse Event Listing";                                                                                                          
proc report data = work.ae_listing nowd;                                                                                                
    column trt01p usubjid aeterm aesev aeser;                                                                                           
    define trt01p / order "Treatment Arm";                                                                                              
    define usubjid / display "Subject ID";                                                                                              
    define aeterm / display "Adverse Event";                                                                                            
    define aesev / display "Severity";                                                                                                  
    define aeser / display "Serious (Y/N)";                                                                                             
run;                                                                                                                                    
                                                                                                                                        
title;                                                                                                                                  
ods pdf close;                                                                                                                          
                                                             
