/* Generated Code (IMPORT) */
/* Source File: ffroilprice.xlsx */
/* Source Path: /home/u60818803/543/581 */
/* Code generated on: 4/22/23, 11:14 PM */

%web_drop_table(WORK.IMPORT);


FILENAME REFFILE '/home/u60818803/543/581/ffroilprice.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.IMPORT;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; RUN;


%web_open_table(WORK.IMPORT);

/*
 *
 * Task code generated by SAS Studio 3.8 
 *
 * Generated on '4/22/23, 11:16 PM' 
 * Generated by 'u60818803' 
 * Generated on server 'ODAWS03-USW2.ODA.SAS.COM' 
 * Generated on SAS platform 'Linux LIN X64 3.10.0-1062.9.1.el7.x86_64' 
 * Generated on SAS version '9.04.01M7P08062020' 
 * Generated on browser 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36' 
 * Generated on web client 'https://odamid-usw2.oda.sas.com/SASStudio/main?locale=en_US&zone=GMT-05%253A00&ticket=ST-29364-U6fH5zjVytnXnZlulYDu-cas' 
 *
 */

ods graphics / reset width=6.4in height=4.8in imagemap;
title1  "As of &sysdate  &systime";
proc sort data=WORK.IMPORT out=_SeriesPlotTaskData;
	by Month;
run;
title1  "As of &sysdate  &systime";


proc sgplot data=_SeriesPlotTaskData;
   series x=Month y=realoil  / lineattrs=(pattern=solid);
   series x=Month y=FEDFUNDS /y2axis lineattrs=(pattern=dash);
   yaxis label="Real Oil Price";
run;


/*
 *
 * Task code generated by SAS Studio 3.8 
 *
 * Generated on '4/25/23, 11:23 PM' 
 * Generated by 'u60818803' 
 * Generated on server 'ODAWS03-USW2.ODA.SAS.COM' 
 * Generated on SAS platform 'Linux LIN X64 3.10.0-1062.9.1.el7.x86_64' 
 * Generated on SAS version '9.04.01M7P08062020' 
 * Generated on browser 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36' 
 * Generated on web client 'https://odamid-usw2.oda.sas.com/SASStudio/main?locale=en_US&zone=GMT-05%253A00&ticket=ST-97321-1UGPRIV2fus3pvcwqGWD-cas' 
 *
 */

ods noproctitle;
ods graphics / imagemap=on;

proc means data=WORK.IMPORT chartype mean std min max median n vardef=df 
		qmethod=os;
	var realoil FEDFUNDS;
run;

/* Graph template to construct combination histogram/boxplot */
proc template;
	define statgraph histobox;
		dynamic AVAR ByVarInfo;
		begingraph;
		entrytitle "Distribution of " AVAR ByVarInfo;
		layout lattice / rows=2 columndatarange=union rowgutter=0 rowweights=(0.75 
			0.25);
		layout overlay / yaxisopts=(offsetmax=0.1) xaxisopts=(display=none);
		histogram AVAR /;
		endlayout;
		layout overlay /;
		BoxPlot Y=AVAR / orient=horizontal;
		endlayout;
		endlayout;
		endgraph;
	end;
run;

/* Macro to subset data and create a histobox for every by group */
%macro byGroupHistobox(data=, level=, num_level=, byVars=, num_byvars=, avar=);
	%do j=1 %to &num_byvars;
		%let varName&j=%scan(%str(&byVars), &j);
	%end;

	%do i=1 %to &num_level;

		/* Get group variable values */
		data _null_;
			i=&i;
			set &level point=i;

			%do j=1 %to &num_byvars;
				call symputx("x&j", strip(&&varName&j), 'l');
			%end;
			stop;
		run;

		/* Build proc sql where clause */
        %let dsid=%sysfunc(open(&data));
		%let whereClause=;

		%do j=1 %to %eval(&num_byvars-1);
			%let varnum=%sysfunc(varnum(&dsid, &&varName&j));

			%if(%sysfunc(vartype(&dsid, &varnum))=C) %then
				%let whereClause=&whereClause.&&varName&j.="&&x&j"%str( and );
			%else
				%let whereClause=&whereClause.&&varName&j.=&&x&j.%str( and );
		%end;
		%let varnum=%sysfunc(varnum(&dsid, &&varName&num_byvars));

		%if(%sysfunc(vartype(&dsid, &varnum))=C) %then
			%let whereClause=&whereClause.&&varName&num_byvars.="&&x&num_byvars";
		%else
			%let whereClause=&whereClause.&&varName&num_byvars.=&&x&num_byvars;
		%let rc=%sysfunc(close(&dsid));

		/* Subset the data set */
		proc sql noprint;
			create table WORK.tempData as select * from &data
            where &whereClause;
		quit;

		/* Build plot group info */
        %let groupInfo=;

		%do j=1 %to %eval(&num_byvars-1);
			%let groupInfo=&groupInfo.&&varName&j.=&&x&j%str( );
		%end;
		%let groupInfo=&groupInfo.&&varName&num_byvars.=&&x&num_byvars;

		/* Create histogram/boxplot combo plot */
		proc sgrender data=WORK.tempData template=histobox;
			dynamic AVAR="&avar" ByVarInfo=" (&groupInfo)";
		run;

	%end;
%mend;

proc sgrender data=WORK.IMPORT template=histobox;
	dynamic AVAR="realoil" ByVarInfo="";
run;

proc sgrender data=WORK.IMPORT template=histobox;
	dynamic AVAR="FEDFUNDS" ByVarInfo="";
run;

proc datasets library=WORK noprint;
	delete tempData;
	run;











/*correlatiom Test*/
PROC CORR DATA=WORK.IMPORT PLOTS=SCATTER(NVAR=all);
   VAR realoil FEDFUNDS;
RUN;


/*
 * Model with FFR and time
 * Task code generated by SAS Studio 3.8 
 *
 * Generated on '4/29/23, 11:01 AM' 
 * Generated by 'u60818803' 
 * Generated on server 'ODAWS04-USW2.ODA.SAS.COM' 
 * Generated on SAS platform 'Linux LIN X64 3.10.0-1062.9.1.el7.x86_64' 
 * Generated on SAS version '9.04.01M7P08062020' 
 * Generated on browser 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36' 
 * Generated on web client 'https://odamid-usw2.oda.sas.com/SASStudio/main?locale=en_US&zone=GMT-05%253A00&ticket=ST-19578-YnzV0xibDucSP2llcOQE-cas' 
 *
 */
title1  "As of &sysdate  &systime";
ods noproctitle;
ods graphics / imagemap=on;

proc reg data=WORK.IMPORT alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	model realoil=Month FEDFUNDS /;
	run;
quit;



/*
 * Model with FFR and time
 * Task code generated by SAS Studio 3.8 
 *
 * Generated on '4/29/23, 11:01 AM' 
 * Generated by 'u60818803' 
 * Generated on server 'ODAWS04-USW2.ODA.SAS.COM' 
 * Generated on SAS platform 'Linux LIN X64 3.10.0-1062.9.1.el7.x86_64' 
 * Generated on SAS version '9.04.01M7P08062020' 
 * Generated on browser 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36' 
 * Generated on web client 'https://odamid-usw2.oda.sas.com/SASStudio/main?locale=en_US&zone=GMT-05%253A00&ticket=ST-19578-YnzV0xibDucSP2llcOQE-cas' 
 *
 */
title1  "As of &sysdate  &systime";
ods noproctitle;
ods graphics / imagemap=on;

proc reg data=WORK.IMPORT alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	model realoil= FEDFUNDS /;
	run;
quit;

/*Granger Test*/

   data causal;
     set WORK.IMPORT;

     Oil_1 = lag(realoil);
    Oil_2 = lag2(realoil);

     FFR_1 = lag(FEDFUNDS);
     FFR_2 = lag2(FEDFUNDS);
   run;


   *   unrestricted model;
   proc autoreg data=causal;
      model realoil =  Oil_1 Oil_2 FFR_1 FFR_2;
      output out=out1 r=e1;   /* output residuals */
   run;


   *   restricted model;
   proc autoreg data=out1;
      model realoil = Oil_1 Oil_2;
      output out=out2 r=e0;    /* output residuals */
   run;
 *These residuals can then be read into vectors in PROC IML and used to calculate the test statistics with matrix algebra.;



   ods select Iml._LIT1010
              Iml.TEST1_P_VAL1
              Iml.TEST2_P_VAL2;

   ods html body='/home/u60818803/543/581/output/exgran01.htm';

   *   compute test;
   proc iml;

      start main;

      use out1;
      read all into e1 var{e1};
      close out1;

      use out2;
      read all into e0 var{e0};
      close out2;


      p = 2;           /* # of lags         */
      T = nrow(e1);    /* # of observations */

      sse1 = ssq(e1);
      sse0 = ssq(e0);

      * F test;
      test1 = ((sse0 - sse1)/p)/(sse1/(T - 2*p - 1));
      p_val1 = 1 - probf(test1,p,T - 2*p - 1);

      * asymtotically equivalent test;
      test2 = (T * (sse0 - sse1))/sse1;
      p_val2 = 1 - probchi(test2,p);

      print "Granger Test",, test1 p_val1,,
                           test2 p_val2;
      finish;
   run;
   quit;

   ods html close;



/*
 *
 * Task code generated by SAS Studio 3.8 
 *
 * Generated on '4/27/23, 8:58 PM' 
 * Generated by 'u60818803' 
 * Generated on server 'ODAWS03-USW2.ODA.SAS.COM' 
 * Generated on SAS platform 'Linux LIN X64 3.10.0-1062.9.1.el7.x86_64' 
 * Generated on SAS version '9.04.01M7P08062020' 
 * Generated on browser 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36' 
 * Generated on web client 'https://odamid-usw2.oda.sas.com/SASStudio/main?locale=en_US&zone=GMT-05%253A00&ticket=ST-142037-FRzapAS6XY6PcVPTdoXL-cas' 
 *
 */
title1  "As of &sysdate  &systime";
ods noproctitle;
ods graphics / imagemap=on;

proc sort data=WORK.IMPORT out=Work.preProcessedData;
	by Month;
run;

proc varmax data=Work.preProcessedData plots=none;
	id Month interval=month;
	model realoil=FEDFUNDS / p=1;
	output lead=12 back=0 alpha=0.05;
run;

proc delete data=Work.preProcessedData;
run;
