%let macrodir= E:\HCP\macros;
filename mymacs "&macrodir";
%include mymacs ('*.sas');

options OBS=max;
options mprint;
libname datadir 'E:\HCP';
%let excel_folder=E:\HCP\excel;


/* Import primary data  */
PROC IMPORT
  DATAFILE='E:\HCP\PD_HCP_Universe_Condensed.xlsx'
  OUT=datadir.PD_HCP_Universe_Condensed
  DBMS=xlsx REPLACE;
  SHEET="Sheet1";
  GETNAMES=YES;
RUN;

data PD_HCP_Universe_Condensed_1;
length NpiName_unique $80;
   Set datadir.PD_HCP_Universe_Condensed(rename=(NPI__=NPI));
   if name='JOSEPH HORMES' then NPI='1497848444';
   if name='ALBERT KIM' then NPI='1235203670';
   COMT_TRx_num=input(COMT_TRx,best.);
   PD_TRx_num=input(PD_TRx,best.);
   CD_LD_TRx_num=input(CD_LD_TRx,best.);
   Total_TRx=sum(COMT_TRx_num,PD_TRx_num,CD_LD_TRx_num);
   other= PD_TRx_num-sum(COMT_TRx_num,CD_LD_TRx_num);
   NpiName_unique=catx('_',NPI,Name);
   put _all_;
   run;

Proc summary data=work.PD_HCP_Universe_Condensed_1 nway;

    class NpiName_unique;

    var COMT_TRx_num PD_TRx_num CD_LD_TRx_num Total_TRx other;

    output out = want sum=;

run;

data PD_HCP_Universe_Condensed_2;
 set work.want;
run;

PROC EXPORT DATA=PD_HCP_Universe_Condensed_2
            OUTFILE= "E:\HCP\step51111.xls"
            DBMS=excel4 REPLACE;
run;


%decile(indata=PD_HCP_Universe_Condensed_2, decile_var=COMT_TRx_num, num_groups=10, outvar=COMT_TRx_dec,
outdata=PD_HCP_Universe_Condensed_3);


%decile(indata=PD_HCP_Universe_Condensed_3, decile_var=PD_TRx_num, num_groups=10, outvar=PD_TRx_dec,
outdata=PD_HCP_Universe_Condensed_4);


%decile(indata=PD_HCP_Universe_Condensed_4, decile_var=CD_LD_TRx_num, num_groups=10, outvar=CD_LD_TRx_dec,
outdata=PD_HCP_Universe_Condensed_5);

%decile(indata=PD_HCP_Universe_Condensed_5, decile_var=Total_TRx, num_groups=10, outvar=Total_TRx_dec,
outdata=PD_HCP_Universe_Condensed_Final);


PROC EXPORT DATA=PD_HCP_Universe_Condensed_Final
            OUTFILE= "E:\HCP\PD_HCP_Universe_Condensed_Final.xls"
            DBMS=excel4 REPLACE;
run;

data PD_HCP_Universe_Condensed_3;
length NpiName_unique $80;
   Set datadir.PD_HCP_Universe_Condensed(rename=(NPI__=NPI) drop=COMT_TRx PD_TRx CD_LD_TRx) ;
   NpiName_unique=catx('_',NPI,Name);
   put _all_;
   run;

proc sort data=PD_HCP_Universe_Condensed_3;
by NpiName_unique;
run;

proc sort data=PD_HCP_Universe_Condensed_Final;
by NpiName_unique;
run;

data PD_HCP_Universe_Condensed_Final1;
   merge  PD_HCP_Universe_Condensed_3(IN=a) PD_HCP_Universe_Condensed_Final(IN=b)  ;
   by  NpiName_unique;
   IF a = 1 and b = 1;
run;

PROC EXPORT DATA=PD_HCP_Universe_Condensed_Final1
            OUTFILE= "E:\HCP\PD_HCP_Universe_Condensed_Final1.xls"
            DBMS=excel4 REPLACE;
run;

