PROC IMPORT OUT= WORK.INDICATORS_RAW 
            DATAFILE= "\\tsclient\HL\Desktop\Mys Video\ms\stat660\team-3_project2\Indicators.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
PROC IMPORT OUT= WORK.COUNTRY 
            DATAFILE= "\\tsclient\HL\Desktop\Mys Video\ms\stat660\team-3_project2\Country.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

proc sort data=WORK.COUNTRY  	   			   nodupkey ; by countrycode; run;
proc sort data=WORK.INDICATORS_RAW dupout= dup nodupkey ; by countrycode year indicatorcode; run;

data temp ;
	merge COUNTRY (in=a keep = countrycode shortname rename=(shortname=Country)) 
		  INDICATORS_RAW ;
	by countrycode;
	if a & year>=2010; 
    indicatorcode = tranwrd(indicatorcode,".", "_"); 
	if substr(indicatorcode,1,2) in ("BM","EG","IT","NE","SP") ;
run;

proc sort data=temp nodupkey ; by countrycode country year indicatorcode; run;
proc transpose data=temp out=cotw_ind (drop=_name_) ;
	 by      countrycode country year; 
	 id      indicatorcode;
     idlabel indicatorname;
	 var     value;
run;

proc export data=cotw_ind
   outfile= "\\tsclient\HL\Desktop\Mys Video\ms\stat660\team-3_project2\cotw_ind.csv" 
   dbms=csv
   replace;
run;

