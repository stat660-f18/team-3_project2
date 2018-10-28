*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
This file uses the following analytic dataset to address several research
questions regarding happiness, peace index and biocapacity / ecological-footprint 
Dataset Name: cotw_2016_analytic_file created in external file
STAT660-01 f18-team-3 project2 data preparation.sas, which is assumed to be
in the same directory as this file

See included file for dataset properties
;

* environmental setup;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";


* load external file that generates analytic datasets global_eco_2016 gpi_2008-2016 happy_2015 happy_2016;
%include 'STAT660-01 f18-team-3 project2 data preparation.sas';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: What are top 5 countries experienced biggest increase in happiness rank from 2016 to 2107?'
;

title2
'Rationale: This should help identify top countries that are potentially gaining more life satisfaction over year.'
;

footnote1
"According to this table, the top five countires top 5 countries that experienced biggest increase in happiness rank from 2015 to 2106 were Algeria, Latvia, Cameroon, Egypt and Romania"
;

footnote2
"These are all developing countries, 3 of which are in Europe and the other 2 are in Africa"
;

footnote3
"The biggest rank increase in happiness of these countries could be due to their good development potential, their recent changes in economy, infrastructure and so on"
;

*
Note:This compares the column “Happiness Rank” from happy_2015 to the column 
of the same name from happy_2016.

Methodology: When combining happy_2015 with happy_2016 during data preparation,
take the difference of values of "happiness_rank" for each
school and create a new variable called happiness_rank_yoy . Then,
use proc sort to create a temporary sorted table in descending by
happiness_rank_yoy. Finally, use proc print here to display the
first five rows of the sorted dataset.

Limitations: This methodology does not account for countries with missing data,
nor does it attempt to validate data in any way, like filtering for percentages
between 0 and 1.

Followup Steps: More carefully clean values in order to filter out any possible
illegal values, and better handle missing data, e.g., by using a previous year's
data or a rolling average of previous years' data as a proxy.
;

proc print
        data=cotw_2016_analytic_file_sort_hr(obs=5)
    ;
    id
        country
    ;
    var
        happiness_rank_yoy
    ;
run;

title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
"Research Question: Is "GPI" in a relationship with "Happiness Score" ?  "
;

title2
"Rationale: This will help determine if peace status of a country makes people happier"
;

footnote1
""
;

footnote2
""
;

footnote3
""
; 

*
Note:This compares the column “gpi” from gpi_2008-2016 to the column 
happiness_score from happy_2016.

Methodology:Use proc means to compute 5-number summaries of gpi 
and happiness_score. Then use proc format to create formats that bin both 
columns with respect to the proc means output.

Limitations: This methodology does not account for countries with missing data,
nor does it attempt to validate data in any way, like filtering for percentages
between 0 and 1.

Followup Steps: More carefully clean values in order to filter out any possible
illegal values, and better handle missing data, e.g., by using a previous year's
data or a rolling average of previous years' data as a proxy.
;

/*proc means
        min q1 median q3 max
        data= cotw_2016_analytic_file
    ;
    var 
        gpi
		happiness_score
    ;
run;*/

proc freq
        data=cotw_2016_analytic_file
    ;
    table
        gpi*happiness_score
    ;
        where
            not(missing(happiness_score))
    ;
    format
        gpi gpi_bins.
        happiness_score happiness_score_bins.
    ;
run;

title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Is there a correlation between “Biocapacity Deficit or Reserve” and “Happiness Score”? '
;

title2
"Rationale: Rationale: Biocapacity Deficit or Reserve reveals the sustainability status of a country, which can lead to a happier fulfilled life"
;

footnote1
"The result shows a negative relation between the 2 variables "
;

footnote2
"However, Pearson Chi-Sq Test shows p-value > 0.05, therefore there is not enough evidence to show the correlation between “Biocapacity Deficit or Reserve” and “Happiness Score”"
;

footnote3
""
;

*
Note: This compares the column biocapacity_deficit_or_reserve from eco_2016
to the column happiness_score in happy_2016.
    
*
Methodology: Use PROC CORR can to compute Pearson product-moment correlation 
coefficient between biocapacity_deficit_or_reserve and happiness_score, 
as well as Spearman's rank-order correlation, a nonparametric measures of 
association. PROC CORR also computes simple descriptive statistics.  

Limitations: This methodology does not account for countries with missing data,
nor does it attempt to validate data in any way, like filtering for values
outside of admissable values.

Followup Steps: More carefully clean the values of variables so that the
statistics computed do not include any possible illegal values, and better
handle missing data, e.g.,.
;

proc corr 
        pearson spearman
        data = cotw_2016_analytic_file 
    ;
    var 
        biocapacity_deficit_or_reserve
		happiness_score
    ;
run;
title;
footnote;

