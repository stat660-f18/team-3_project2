
*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
This file uses the following analytic dataset to address several research
questions regarding country's happiness.

Dataset Name: cotw_2016_analytic_file created in external file
STAT660-01_f18-team-3_project2_data_preparation.sas, which is assumed to be
in the same directory as this file

See included file for dataset properties
;

* environmental setup;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";


* load external file that generates analytic datasets cde_2014_analytic_file,
  cde_2014_analytic_file_sort_frpm, and cde_2014_analytic_file_sort_sat;
%include '.\STAT660-01_f18-team-3_project2_data_preparation.sas';

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question:  For the 20 largest countries, what are the top five countries that experienced the biggest decrease in "Happiness Score"ù between 2015 and 2016?'
;

title2
'Rationale: This will help identify countries that have decline in life satisfaction.'
;

footnote1
"Of the largest 20 countries, the top five countries with the greatest decreases in happiness score between 2015 and 2016 ranged between 2% and 8% decline."
;

footnote2
"Given the magnitude of these changes, further investigation should be performed to ensure no data errors are involved."
;

footnote3
"However, assuming there are no data issues underlying this analysis, possible explanations for such volatilities is due to the small population size. Note China has 1.4B people while U.S. has 320MM people."
;
*******************************************************************************;
*
Note: This compares the column "Happiness Score"ù from happy_2015 to the 
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
proc print 
    noobs label
    data = cotw_2016_analytic_file_sort_hs  (obs=5) 
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
 
title;
footnote;
proc sgplot 
    data = cotw_2016_analytic_file_sort_hs 
    ;
    hbar n_Country
        / response=happiness_score_yoy 
          dataskin=gloss 
          datalabel 
          nostatlabel
    ;       
	xaxis grid
	;
    yaxis grid 
        discreteorder=data 
        label='20 Largest Countries'
    ;
run;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: Can "GPI" predict the "Happiness Score" in 2016?'
; 

title2
'Rationale: This will help determine if peace status makes people happier.  Ideally, we want to find the potential drivers that may have caused the biggest decline in "Happiness Score".'
;

footnote1
"As can be seen, there was an extremely high correlation between GPI and Happiness Score."
;

footnote2
"Given this apparent correlation based on descriptive methodology, further investigation should be performed using inferential methodology to determine the level of statistical significance of the result."
;

*
Note: This compares the change in GPI between 2015 and 2016 in gpi_raw 
dataset to the column "Happiness Score" in happy_2016 dataset.

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
        gpi 
        gpi_yoy   
		happiness_score 
		happiness_score_yoy
    ;
run;

proc freq 
    data=COTW_2016_analytic_file
    ;
    table 
        gpi     * happiness_score
        gpi_yoy * happiness_score_yoy 
        / missing norow nocol nopercent 
    ;
    format 
        gpi                 gpi_bins. 
        gpi_yoy             gpi_yoy_bins. 
        happiness_score     happiness_score_bins.
        happiness_score_yoy happiness_score_yoy_bins.
    ;
run;
*/

proc glm  
    data= cotw_2016_analytic_file 
    ;
    model 
        happiness_score = gpi
        /solution
    ;
run; 
quit;

title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point                                    ;
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

*******************************************************************************;
*
Note: This compares the column ‚ÄúHDI‚Äù from eco_2016 to the column 
"Life Expectancy" in happy_2016.
    
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
*******************************************************************************;

proc corr 
    pearson spearman nomiss
    data = cotw_2016_analytic_file ;
	*plots= scatter (nvar=2 alpha=0.05) 
    ;
    var 
        hdi
        life_expectancy
    ;
run;

title;
footnote;

proc sgplot 
    data = COTW_2016_analytic_file 
    ; 
    scatter x = hdi  y = life_expectancy 
    ;
    loess   x = hdi  y = life_expectancy/nomarkers
    ;
    loess   x = hdi  y = life_expectancy/smooth = 1 nomarkers
    ;
    ellipse x = hdi  y = life_expectancy/type = predicted
    ; 
quit;
