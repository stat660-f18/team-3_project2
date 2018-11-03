
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
"Research Question:  For the 20 largest countries, what are the top five countries that experienced the biggest decrease in Happiness Score between 2015 and 2016?"
;

title2
"Rationale: This will help identify countries that have decline in life satisfaction."
;

footnote1
"Of the largest 20 countries, the top five countries with the greatest decreases in happiness score between 2015 and 2016 ranged between 2% and 8% decline."
;

footnote2
"Nigeria had the largest decline in happiness score from 2015 to 2016.  This might be connected to Boko Haram kidnappings, Movement for Actualization of Biafra Repulic, and Niger Delta Avengers bombing pipelines in the country."
;

footnote3
"However, assuming there are no data issues underlying this analysis, possible explanations for such volatilities is due to the small population size. Note China has 1.4B people while U.S. has 320MM people."
;
*******************************************************************************;
*
Note: This compares the column Happiness Score from happy_2015 to the 
column of the same name from happy_2016.

Methodology: When combining happy_2016 with happy_2015 during data 
preparation, take the difference of values of happiness_score for each
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
        life_expectancy
        hdi
        gpi
    ;
    format 
        population_mm comma12.0
        happiness_score_yoy 
        life_expectancy percent15.1
        hdi
        gpi comma12.2
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
'Applying simple linear regression model, it can be seen, that 22% of the variability in happiness score can be explained by GPI. The lower the GPI the higher the Happiness Score.';
;

footnote2
'Since p-value <.0001 for GPI "Pr>|T|", we can conclude that GPI has significant linear effect on Happiness Score.'
;

footnote3
'A nation is considered more peaceful when the index score is lower.  The index is based on ongoing conflict, safety and security, and militarisation.'
;

*******************************************************************************;
*
Note: This compares the change in GPI between 2015 and 2016 in gpi_raw 
dataset to the column "Happiness Score" in happy_2016 dataset.

Methodology: Use proc glm to build simple linear regression y = b0 + b1x + e.
First check to see if the Y-Happiness Score and X - GPI are highly
correlated. If not continue to build model than check test model assumptions.
  Model Assumptions 
  1) Dependent variable must be continuous
  2) IID Criterion that means the error terms, e, are:
   a. independent from one another and
   b. identically distributed
   - Normally distributed residuals e (Residuals appear even band around 0)
   - Error variance is the same for all observations
  3) Y observations are not correlated with each other

Goal: Find straight line that minimizes sum of squared distances from actual 
weight to fitted line

Limitations: Here we only looked at one variable to predict happiness score.
Based on the results, there is negative linear effect on Happiness score. And
only 22% can be explained by GPI.  

Follow-up Steps: A possible follow-up is add additional X variables to improve
model predictiveness.
;
*******************************************************************************;
/*
Model Results
Happiness Score = 7.648 + (-1.104)*GPI

Results:
Type III SS p-value < 0.0001
22% of the variability in happiness score is explained by GPI
*/
*******************************************************************************;
/*
proc corr 
    pearson spearman nomiss
    data = cotw_2016_analytic_file 
    plots = scatter (nvar=2 alpha=0.05) 
    ;
    var 
        happiness_score gpi
    ;
run;
*/
*Results show -46.911% correlation. Thusly, not correlated can go to next step ;
  
proc glm   
    data= cotw_2016_analytic_file 
    ;
    model 
        happiness_score = gpi
        /solution   
    ;
    output 
        out=resids 
        r  =res
    ;
run; 
quit; 

/* Test of Normality Assumption*/
/*
proc univariate 
    data = resids normal plot
    ;
    var 
       res
    ;
run;
*/
/* Since Shapiro-Wilk 0.2089 >= 0.05, failed to reject Ho, residuals are normally distributed*/

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
'Life Expectancy and HDI (Human Development Index) have stastically significant linear relationship (r=0.91,p<0.0001).'
;

footnote2
"The direction of the relationship is positive, meaning the greater the HDI the greater the Life Expectancy."
;

footnote3
"We expect strong correlation since the human development index (HDI) is a composite statistic of life expectancy, education, and per capita income indicators."
;

*******************************************************************************;
*
Note: This compares the column "HDI" from eco_2016 to the column 
"Life Expectancy" in happy_2016. 
*
Methodology: Use PROC CORR can to compute Pearson product-moment correlation 
coefficient between hdi and life_expectancy, as well as Spearman's 
rank-order correlation, a nonparametric measures of association. PROC CORR 
also computes simple descriptive statistics.  

Limitations: Data dictionary is limited. The methodology does not account for 
countries with missing data, nor does it attempt to validate data in any way, 
like filtering for percentages between 0 and 1.

Possible Follow-up Steps: More carefully clean the values of the variables
so that the means computed do not include any possible illegal values. 
And use proc plot to generate a graph of the variable hdi against 
life expectancy.
;
*******************************************************************************;

proc corr 
    pearson spearman fisher(biasadj=no) nomiss 
    data = cotw_2016_analytic_file 
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


/*
proc glm   
    data= cotw_2016_analytic_file 
    ;
    model 
        happiness_score = gpi hdi
        /solution   
    ;
    output 
        out=resids 
        r  =res
    ;
run; 
quit; 
*/
