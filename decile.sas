/******************* Decile Macro **************************
Last Updated: Sep 14, 2009

decile(indata=, decile_var=, num_groups=, outvar=, outdata=);

Inputs:
1) indata: input dataset
2) decile_var: variable used for deciling (TRxs etc)
3) num_groups: number of groups to be created. num_groups = 10 for deciling, = 5 for quintiling
4) outvar: variable to store the decile information. This variable will be added in the output dataset. Should be different from all vars in input dataset.
5) outdata: output dataset
******************* Decile Macro **************************/

%macro decile(indata=, decile_var=, num_groups=, outvar=, outdata=);


/* Get the sum of the deciling variable assigned to each decile */
proc sql;
   select sum(&decile_var.)/&num_groups. into: decile_sum_var
   from &indata.;
quit;

%put Total across all respondents is &decile_sum_var.;

/* Sort the data in the descending order of the variable used for deciling */
proc sort data=&indata. out=&outdata.;
   by descending &decile_var.;
run;

/* Assign deciles */
data &outdata.;
   set &outdata.;

   retain cumul_sum;
   retain prev_value;
   retain &outvar.;

   if _N_ = 1 then do;
      cumul_sum = 0;
	  prev_value = 0;
	  &outvar. = &num_groups;
   end;
   
   /* When the cumulative value of the variable crosses another threshold, update the decile value.
      However, if the variable value is same as of the previous record, keep the same decile to avoid 
      assigning different decile values for 2 records with same value for the decile variable */
      
   if  cumul_sum > (1+ &num_groups. - &outvar.)* &decile_sum_var. then do;
       if &decile_var. ne prev_value then &outvar. = &outvar. - 1;
   end;

   cumul_sum = cumul_sum + &decile_var.;

   prev_value = &decile_var.;

   /* Set the decile to 0 for all nonwriters */
   if &decile_var. <= 0 then &outvar. = 0;

   drop cumul_sum prev_value;
run;

/* Run decile summary */
proc means data = &outdata. nway noprint missing;
   class &outvar. ;
   var &decile_var.;
   output out=&outvar._summ sum= min= max= N= / autoname;
run;

%export_excel (dataset_name = &outvar._summ);

%mend decile;
