
*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
This file uses the following analytic dataset to address several research
questions regarding country's happiness.

Dataset Name: cotw_2016_analytic_file created in external file
STAT660-01 f18-team-3 project2 data preparation.sas, which is assumed to be
in the same directory as this file

See included file for dataset properties
;

* environmental setup;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";


* load external file that generates analytic datasets cde_2014_analytic_file,
  cde_2014_analytic_file_sort_frpm, and cde_2014_analytic_file_sort_sat;
%include '.\STAT660-01 f18-team-3 project2 data preparation.sas';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question:  For the 20 largest countries, what are the top five countries that experienced the biggest decrease in “Happiness Score” between 2015 and 2016?'
;

title2
'Rationale: This will help identify countries that have decline in life satisfaction.'
;


footnote1
"Of the five countries with the greatest decreases in happiness score between 2015 and 2016, the decrease in percent ranges from about 7% to about 17%."
;

footnote2
"Given the magnitude of these changes, further investigation should be performed to ensure no data errors are involved."
;

footnote3
"However, assuming there are no data issues underlying this analysis, possible explanations for such volatilities is due to the small population size. Note China has 1.4B people while U.S. has 320MM."
;
*******************************************************************************;
*
Note: This compares the column “Happiness Score” from happy_2015 to the 
column of the same name from happy_2016.

Methodology: When combining happy_2016 with happy_2015 during data 
preparation, take the difference of values of "happiness_score" for each
country and create a new variable called happiness_score_yoy. Then,
use proc sort to create a temporary sorted table in descending by
happiness_score_yoy. Finally, use proc print here to display the
first five rows of the sorted dataset.

Limitations: This methodology does not account for country's with missing data,
nor does it attempt to validate data in any way, like filtering for percentages
between 0 and 1.

Follow-up Steps: More carefully clean values in order to filter out any possible
illegal values, and better handle missing data, e.g., by using a previous 
year's data or a rolling average of previous years' data as a proxy.
;
proc sort data = cotw_2016_analytic_file nodupkey; by descending population_mm; run;
data _temp;
	set 
        cotw_2016_analytic_file 
    ;
	if _n_<=20
    ;
	contr = put(_n_,z2.)||"_"||country ;
run;
 
proc sort data = _temp nodupkey; by happiness_score_yoy; run;
proc print 
        noobs
        data=_temp (obs=5) label
    ;
    id 
        Country
    ;
    var 
        population_mm
        happiness_score_yoy 
    ;
	format 
        population_mm comma12.0
        happiness_score_yoy percent15.1
	;

run;

* Specify axis characteristics ;                                                                                                           
axis1 label=('Largest Countries')
;
axis2 label=('Happiness Score YOY %')
;   
* Add a title to the graph ;                                                                                                       
title1 'Happiness Score YOY %';  
footnote; 

proc gchart data = _temp  ;
   hbar contr  / 
        maxis=axis1 
        raxis=axis2 
        nostats  
        sumvar=happiness_score_yoy  
   ;
run;                                                                                                                                    
quit;  

title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: Can the change in "GPI" predict the "Happiness Score" in 2016?'
; 

title2
'Rationale: This will help determine if peace status makes people happier.  Ideally, we want to find the potential drivers that may have caused the biggest decline in "Happiness Score".'
;

footnote1
"As can be seen, there was an extremely high correlation between GPI YOY, with lower GPI YOY much more likely to caused decline in Happiness Score."
;

footnote2
;

footnote3
"Given this apparent correlation based on descriptive methodology, further investigation should be performed using inferential methodology to determine the level of statistical significance of the result."
;

*
Note: This compares the change in GPI between 2015 and 2016 in gpi_raw 
dataset to the column “Happiness Score” in happy_2016 dataset.

Methodology: Use proc means to compute 5-number summaries of "GPI YOY"
and "Happiness Score YOY."  Then use proc format to create formats that 
bin both columns with respect to the proc means output. Then use proc 
freq to create a cross-tab of the two variables with respect to the 
created formats.

Limitations: Even though predictive modeling is specified in the research
questions, this methodology solely relies on a crude descriptive technique
by looking at correlations along quartile values, which could be too coarse a
method to find actual association between the variables.

Follow-up Steps: A possible follow-up to this approach could use an inferential
statistical technique like linear regression.
;
/*
proc means 
        min q1 median q3 max 
        data=cotw_2016_analytic_file
    ;
    var 
        gpi_yoy   
		happiness_score_yoy
    ;
run;
*/
proc freq 
        data=COTW_2016_analytic_file
    ;
    table 
        gpi_yoy * happiness_score_yoy 
        / missing norow nocol nopercent 
    ;
    format 
        gpi_yoy             gpi_yoy_bins. 
        happiness_score_yoy happiness_score_yoy_bins.
    ;
run;
title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: Is there a strong correlation between "Life Expectancy" and "HDI (Human Development Index)"?'
;

title2
"Rationale: It is believed that improving HDI reduces health disparities, which can lead to a longer life."
;

footnote1
'Pearson Chi-Sq Test shows p-value < 0.05, therefore reject Ho s.t. there is enough evidence to show significant correlation between "Life Expectancy" and "HDI (Human Development Index)".'
;

footnote2
;

footnote3
;

*
Note: This compares the column “HDI” from eco_2016 to the column "Life Expectancy" 
in happy_2016.
    
*
Methodology: Use PROC CORR can to compute Pearson product-moment correlation 
coefficient between net_migration and deathrate, as well as Spearman's 
rank-order correlation, a nonparametric measures of association. PROC CORR 
also computes simple descriptive statistics.  
Limitations: Data dictionary is limited. The methodology does not account for 
countries with missing data, nor does it attempt to validate data in any way, 
like filtering for percentages between 0 and 1.

Possible Follow-up Steps: More carefully clean the values of the variable
net_migration so that the means computed do not include any possible
illegal values. Find correlations for combinations death rate, infant 
mortality, and net migration. And use proc plot to generate a graph of the 
variable net_migration against death rate.
;

proc corr 
        pearson spearman
        data = cotw_2016_analytic_file 
    ;
    var 
        hdi
        ife_expectancy
    ;
run;
title;
footnote;
