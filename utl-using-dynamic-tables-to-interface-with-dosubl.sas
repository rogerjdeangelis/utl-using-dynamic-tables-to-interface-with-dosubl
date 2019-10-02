Using dynamic tables to interface with dosubl with parent datastep;                                                         
                                                                                                                            
This is purely an academic exercise.                                                                                        
                                                                                                                            
  Problem                                                                                                                   
     Given a list of numbers find the sum that is closest but less then or equal to a desired value.                        
                                                                                                                            
                                                                                                                            
   There are several coding techniques that are needed to get this to work                                                  
                                                                                                                            
   a. It is not possible using pure sas code to create a SAS dataset inside dosubl                                          
      and use that dataset in the parent datastep, without open=defer. I could not figure out how to                        
      close the SAS dataset inside dosubl, so I could not use it in the parent datastep. HASH?.                             
                                                                                                                            
   b. To overcome this I called WPS from SAS to create the SAS dataset. When WPS closed I could                             
      access the dataset in the parent datastep.                                                                            
                                                                                                                            
   c. The dataset created by WPS must exist prior to calling WPS. So you need to create a template dataset                  
      at compile time.                                                                                                      
                                                                                                                            
            if _n_=0 then do; %let rc=%sysfunc(dosubl('                                                                     
                 data want;                                                                                                 
                    attrib                                                                                                  
                      cap length=8                                                                                          
                      value length=8                                                                                        
                    ;                                                                                                       
                    cap=-1;                                                                                                 
                    value=-1;                                                                                               
                 run;quit;                                                                                                  
                 '));                                                                                                       
            end;                                                                                                            
                                                                                                                            
            set want; /* this will work now */                                                                              
                                                                                                                            
     d. This code uses three types of quotes. This is needed bcause                                                         
                                                                                                                            
             dosubl ('                                                                                                      
               %utl_submit_wps64("                                                                                          
                    proc R;                                                                                                 
                       `\`d:/sd1/have.sas7bdat\``  ** backtic quotes - escape backtick;                                     
                                                                                                                            
        I think this is the only reasonable way to call R within a SAS datastep.                                            
        Not sure if python supports this.                                                                                   
*_                   _                                                                                                      
(_)_ __  _ __  _   _| |_                                                                                                    
| | '_ \| '_ \| | | | __|                                                                                                   
| | | | | |_) | |_| | |_                                                                                                    
|_|_| |_| .__/ \__,_|\__|                                                                                                   
        |_|                                                                                                                 
;                                                                                                                           
                                                                                                                            
options validvarname=upcase;                                                                                                
libname sd1 "d:/sd1";                                                                                                       
Data sd1.have;                                                                                                              
   input vALUE;                                                                                                             
cards4;                                                                                                                     
500                                                                                                                         
985                                                                                                                         
689                                                                                                                         
951                                                                                                                         
147                                                                                                                         
653                                                                                                                         
566                                                                                                                         
658                                                                                                                         
;;;;                                                                                                                        
run;quit;                                                                                                                   
                                                                                                                            
                                                                                                                            
SD1.HAVE total obs=8                                                                                                        
                                                                                                                            
Obs    VALUE                                                                                                                
                                                                                                                            
 1      500                                                                                                                 
 2      985                                                                                                                 
 3      689                                                                                                                 
 4      951                                                                                                                 
 5      147                                                                                                                 
 6      653                                                                                                                 
 7      566                                                                                                                 
 8      658                                                                                                                 
                                                                                                                            
*            _               _                                                                                              
  ___  _   _| |_ _ __  _   _| |_                                                                                            
 / _ \| | | | __| '_ \| | | | __|                                                                                           
| (_) | |_| | |_| |_) | |_| | |_                                                                                            
 \___/ \__,_|\__| .__/ \__,_|\__|                                                                                           
                |_|                                                                                                         
;                                                                                                                           
                                                                                                                            
Up to 40 obs from WANT_FIN total obs=18                                                                                     
                                                                                                                            
Obs     CAP     VALUE                                                                                                       
                                                                                                                            
  1    2000       500                                                                                                       
  2    2000       689                                                                                                       
  3    2000       147                                                                                                       
  4    2000       653                                                                                                       
  5       0      1989  Sum closest to 2,000 but under                                                                       
                                                                                                                            
  6    3000       500                                                                                                       
  7    3000       985                                                                                                       
  8    3000       689                                                                                                       
  9    3000       147                                                                                                       
 10    3000       653                                                                                                       
 11       0      2974  Sum closest to 3,000 but under                                                                       
                                                                                                                            
 12    4000       500                                                                                                       
 13    4000       985                                                                                                       
 14    4000       689                                                                                                       
 15    4000       951                                                                                                       
 16    4000       147                                                                                                       
 17    4000       653                                                                                                       
 18       0      3925  Sum closest to 4,000 but under                                                                       
                                                                                                                            
                                                                                                                            
*                                                                                                                           
 _ __  _ __ ___   ___ ___  ___ ___                                                                                          
| '_ \| '__/ _ \ / __/ _ \/ __/ __|                                                                                         
| |_) | | | (_) | (_|  __/\__ \__ \                                                                                         
| .__/|_|  \___/ \___\___||___/___/                                                                                         
|_|                                                                                                                         
;                                                                                                                           
                                                                                                                            
libname sd1 "d:/sd1";                                                                                                       
                                                                                                                            
%symdel cap / nowarn;                                                                                                       
                                                                                                                            
proc datasets lib=work;                                                                                                     
 delete want;                                                                                                               
run;quit;                                                                                                                   
                                                                                                                            
proc datasets lib=sd1;                                                                                                      
 delete want_r;                                                                                                             
run;quit;                                                                                                                   
                                                                                                                            
data want_fin (where=(value ne -1));                                                                                        
                                                                                                                            
 * need this otherwise SAS will error on want in nainline below;                                                            
 if _n_=0 then do; %let rc=%sysfunc(dosubl('                                                                                
      data want;                                                                                                            
         attrib                                                                                                             
           cap length=8                                                                                                     
           value length=8                                                                                                   
         ;                                                                                                                  
         cap=-1;                                                                                                            
         value=-1;                                                                                                          
      run;quit;                                                                                                             
      '));                                                                                                                  
 end;                                                                                                                       
                                                                                                                            
 do cap=2000,3000,4000;                                                                                                     
                                                                                                                            
   call symputx('cap',cap);                                                                                                 
                                                                                                                            
   * three level quoting;                                                                                                   
                                                                                                                            
   rc=dosubl('                                                                                                              
      %utl_submit_wps64("                                                                                                   
      libname sd1 sas7bdat %qsysfunc(quote(d:/sd1));                                                                        
      proc r;                                                                                                               
      submit;                                                                                                               
      library(adagio);                                                                                                      
      library(haven);                                                                                                       
      library(SASxport);                                                                                                    
      have<-read_sas(substr(quote(`\`d:/sd1/have.sas7bdat\``),2,21));                                                       
      nums <- as.numeric(have$VALUE);                                                                                       
      wgts <- nums>0;                                                                                                       
      want <- as.data.frame(knapsack(nums, wgts, &cap));                                                                    
      want<-as.data.frame(cbind(have[want$indices,],cap=&CAP));                                                             
      endsubmit;                                                                                                            
      import r=want data=sd1.want_r;                                                                                        
      proc print data=sd1.want_r;                                                                                           
      run;quit;                                                                                                             
      ");                                                                                                                   
      proc append base=want data=sd1.want_r force;                                                                          
      run;quit;                                                                                                             
   ');                                                                                                                      
                                                                                                                            
 end;                                                                                                                       
                                                                                                                            
 do until (dne);                                                                                                            
   retain tot 0 cap;                                                                                                        
   set want end=dne;                                                                                                        
   by cap;                                                                                                                  
   tot+value;                                                                                                               
   output;                                                                                                                  
   if last.cap then do;                                                                                                     
       cap=0;                                                                                                               
       value=tot;                                                                                                           
       output;                                                                                                              
       tot=0;                                                                                                               
   end;                                                                                                                     
 end;                                                                                                                       
                                                                                                                            
run;quit;                                                                                                                   
                                                                                                                            
*_                                                                                                                          
| | ___   __ _                                                                                                              
| |/ _ \ / _` |                                                                                                             
| | (_) | (_| |                                                                                                             
|_|\___/ \__, |                                                                                                             
         |___/                                                                                                              
;                                                                                                                           
                                                                                                                            
The WPS System                                                                                                              
                                                                                                                            
Obs    VALUE     CAP                                                                                                        
                                                                                                                            
 1      500     4000                                                                                                        
 2      985     4000                                                                                                        
 3      689     4000                                                                                                        
 4      951     4000                                                                                                        
 5      147     4000                                                                                                        
 6      653     4000                                                                                                        
                                                                                                                            
NOTE: 10 records were read from the infile "wps_pgm.lst".                                                                   
      The minimum record length was 0.                                                                                      
      The maximum record length was 20.                                                                                     
NOTE: DATA statement used (Total process time):                                                                             
      real time           0.04 seconds                                                                                      
      cpu time            0.04 seconds                                                                                      
                                                                                                                            
                                                                                                                            
NOTE: Appending SD1.WANT_R to WORK.WANT.                                                                                    
NOTE: BASE file WORK.WANT.DATA set to record level control because there is at                                              
least one other open of this file. The append process may take longer to complete.                                          
NOTE: There were 6 observations read from the data set SD1.WANT_R.                                                          
NOTE: 6 observations added.                                                                                                 
NOTE: The data set WORK.WANT has 31 observations and 2 variables.                                                           
NOTE: PROCEDURE APPEND used (Total process time):                                                                           
      real time           0.01 seconds                                                                                      
      cpu time            0.01 seconds                                                                                      
                                                                                                                            
                                                                                                                            
NOTE: There were 16 observations read from the data set WORK.WANT.                                                          
NOTE: The data set WORK.WANT_FIN has 18 observations and 4 variables.                                                       
NOTE: DATA statement used (Total process time):                                                                             
      real time           23.06 seconds                                                                                     
      cpu time            3.66 seconds                                                                                      
                                                                                                                            
                                                                                                                            
