
*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;
/*
This file prepares the dataset described below for analysis.

[Dataset 1 Name] happy_2015

[Dataset Description] The World Happiness Report is a landmark survey of the 
state of global happiness. The happiness scores and rankings use data from the 
Gallup World Poll. The scores are based on answers to the main life evaluation 
question asked in the poll.

[Experimental Unit Description] Countries of the world in 2015

[Number of Observations] 158

[Number of Features] 12

[Data Source] https://www.kaggle.com/unsdsn/world-happiness#2015.csv

[Data Dictionary] https://www.kaggle.com/unsdsn/world-happiness/home

[Unique ID Schema] The column "country" is a unique id.

--
 
[Dataset 2 Name] happy_2016

[Dataset Description] The World Happiness Report is a landmark survey of the 
state of global happiness. The happiness scores and rankings use data from the 
Gallup World Poll. The scores are based on answers to the main life evaluation 
question asked in the poll.

[Experimental Unit Description] Countries of the world in 2016

[Number of Observations] 157

[Number of Features] 13

[Data Source] https://www.kaggle.com/unsdsn/world-happiness#2016.csv

[Data Dictionary] https://www.kaggle.com/unsdsn/world-happiness/home

[Unique ID Schema] The column "country" is a unique id.

--

[Dataset 3 Name] gpi_raw

[Dataset Description] This is a dataset scraped from global peace index 
wikipedia page and presents "relative position of nations' and regions' 
peacefulness".

[Experimental Unit Description] Countries of the world in 2008-2016 

[Number of Observations] 163

[Number of Features] 9

[Data Source] https://www.kaggle.com/kretes/gpi2008-2016

[Data Dictionary] https://www.kaggle.com/kretes/gpi2008-2016/home

[Unique ID Schema] The column "country" and "year" is a unique id.

--

[Dataset 4 Name] eco_2016

[Dataset Description] The ecological footprint measures the ecological assets 
that a given population requires to produce the natural resources it consumes 
(including plant-based food and fiber products, livestock and fish products, 
timber and other forest products, space for urban infrastructure) and to absorb 
its waste, especially carbon emissions. The footprint tracks the use of six 
categories of productive surface areas: cropland, grazing land, fishing grounds, 
built-up (or urban) land, forest area, and carbon demand on land.A nation’s 
biocapacity represents the productivity of its ecological assets, including 
cropland, grazing land, forest land, fishing grounds, and built-up land. These 
areas, especially if left unharvested, can also absorb much of the waste we 
generate, especially our carbon emissions.Both the ecological footprint and 
biocapacity are expressed in global hectares ó globally comparable, 
standardized hectares with world average productivity.

[Experimental Unit Description] Countries of the world in 2016

[Number of Observations] 188

[Number of Features] 21

[Data Source] https://www.kaggle.com/footprintnetwork/ecological-footprint

[Data Dictionary] https://www.kaggle.com/footprintnetwork/ecological-footprint/home

[Unique ID Schema] The column "country" is a unique id.

*******************************************************************************;
*/

*******************************************************************************;
* Environmental setup                                                          ;
*******************************************************************************;

* Create format output;
proc format;
    value gpi_bins
        low  -1.72 ="Q1 GPI"
        1.72<-2.02 ="Q2 GPI"
        2.02<-2.28 ="Q3 GPI"
        2.28<-high ="Q4 GPI"
    ;
    value happiness_score_bins
        low - 4.4 ="Q1 Happiness Score"
        4.4<- 5.3 ="Q2 Happiness Score"
        5.3<- 6.3 ="Q3 Happiness Score"
        6.3<- high="Q4 Happiness Score"
    ; 
    value happiness_score_yoy_bins
        low   --0.014="Q1 Happiness Score %"
       -0.014<- 0.000="Q2 Happiness Score %"
        0.000<- 0.021="Q3 Happiness Score %"
        0.021<- high ="Q4 Happiness Score %"
    ; 
run;

* setup environmental parameters;
%let inputDataset1URL =
    https://github.com/stat660/team-3_project2/blob/master/data/happy_2015.csv?raw=true
;
%let inputDataset1DSN = happy_2015;

%let inputDataset2URL =
    https://github.com/stat660/team-3_project2/blob/master/data/happy_2016.csv?raw=true
;
%let inputDataset2DSN = happy_2016;

%let inputDataset3URL =
    https://github.com/stat660/team-3_project2/blob/master/data/gpi_2008-2016.csv?raw=true
;
%let inputDataset3DSN = gpi_raw;

%let inputDataset4URL =
    https://github.com/stat660/team-3_project2/blob/master/data/global_eco_2016.csv?raw=true
;
%let inputDataset4DSN = eco_2016;

%let inputDatasetType = CSV;

*load raw files over the wire;
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
    %put &=dsn;
    %put &=url;
    %put &=filetype;
    %if
        %sysfunc(exist(&dsn.)) = 0
    %then
        %do;
            %put Loading dataset &dsn. over the wire now...;
            filename tempfile "%sysfunc(getoption(work))/tempfile.xlsx";
            proc http
                method="get"
                url="&url."
                out=tempfile
                ;
            run;
            proc import
                file=tempfile
                out=&dsn.
                dbms=&filetype.;
            run;
            filename tempfile clear;

*******************************************************************************;
* Since data are from various sources, the naming convention of country
  is inconsistent, therefore we use happy dataset country naming convention 
  in order to merge the other two datasets ;
*******************************************************************************;
            data &dsn;
                set 
                    &dsn
		;
                if country = 'Palestinian Territorie'   
                    then country = 'Palestinian Territories'
		;
                if country = 'Somaliland region'        
                    then country = 'Somalia'
		; 
                if country = 'Taiwan Province of China' 
                    then country = 'Taiwan'
		;
                if country = 'Congo, Democratic Republ' 
                    then country = 'Congo (Kinshasa)'
		;
                if country = 'Congo'                    
                    then country = 'Congo (Brazzaville)'
		;
                if country = 'Iran, Islamic Republic o' 
                    then country = 'Iran'
		;
                if country = "Lao People's Democratic"  
                    then country = 'Laos'
		;
                if country = 'Macedonia TFYR'           
                    then country = 'Macedonia'
		;
                if country = 'Korea, Republic of'       
                    then country = 'South Korea'
		;
                if country = 'Korea, Democratic People' 
                    then country = 'North Korea'
		;
                if country = 'Syrian Arab Republic'     
                    then country = 'Syria'
		;
                if country = 'Tanzania, United Republi' 
                    then country = 'Tanzania'
		;
                if country = 'United States of America' 
                    then country = 'United States'
		;
                if country = 'Venezuela, Bolivarian Re' 
                    then country = 'Venezuela'
		;
                if country = 'Viet Nam' 				
                    then country = 'Vietnam'
		;	
                if country = 'Palestine'                
                    then country = 'Palestinian Territories'
		;
                if country = 'Republic of the Congo'    
                    then country = 'Congo (Kinshasa)'  
		;
            run;

***************************************************************************;
* Check raw dataset for duplicates with respect to primary key (country )  ;
***************************************************************************;
            proc sort
                nodupkey
                data=&dsn
                ;
                by 
                    country 
                ;
            run ;
        %end;
    %else
        %do;
            %put Dataset &dsn. already exists. Please delete and try again.;
        %end;
%mend;

%loadDataIfNotAlreadyAvailable(
    &inputDataset1DSN.,
    &inputDataset1URL.,
    &inputDatasetType.
);

%loadDataIfNotAlreadyAvailable(
    &inputDataset2DSN.,
    &inputDataset2URL.,
    &inputDatasetType.
);

%loadDataIfNotAlreadyAvailable(
    &inputDataset3DSN.,
    &inputDataset3URL.,
    &inputDatasetType.
);

%loadDataIfNotAlreadyAvailable(
    &inputDataset4DSN.,
    &inputDataset4URL.,
    &inputDatasetType.
);
  

*******************************************************************************;
* Combining Vertical Happy_2016 and Happy_2015	dataset 		       ;
*******************************************************************************;

proc sql;
    create table happy_raw as
        (
            select
                 *
                ,2016 AS year
            from
                happy_2016
        )
        union all corr
        (
            select
                 *
                ,2015 AS year
            from
                happy_2015
        )
	order by 
	    country
	    ,year  
    ;
quit; 
 

*******************************************************************************;
* Compute year-over-year change in Happiness_rank and Happiness_score          ;
*******************************************************************************;
data happy_raw_with_yoy_change;
    retain
        country 
        year 
        happiness_rank 
        happiness_rank_yoy
        happiness_score 
        happiness_score_yoy
        life_expectancy 
        gdp
        hr 
        hs
    ;
    length
        country $24.
    ;
    set happy_raw (rename =( Health__Life_Expectancy_=life_expectancy
                             Economy__GDP_per_Capita_=gdp))
    ;
    by 
        country 
        year
    ;
    if 
        first.country  
    then
        do;
            hr = happiness_rank 
	    ;
	    hs = happiness_score
	    ;
        end;
    else 
        do;			
            happiness_rank_yoy =  hr - happiness_rank
	    ;
            happiness_score_yoy= (happiness_score /hs)-1
	    ;
            hr = happiness_rank 
	    ;
	    hs = happiness_score
	    ;
	    format 
                happiness_score_yoy percent15.2
            ;
            if 
                year = 2016 
            then 
                do; 
                    output; 
                end;
        end; 
run;


*******************************************************************************;
* Add Year column to eco_2016                                                  ;
*******************************************************************************;
data eco_2016;
    length 
        country $24.
    ;
    set
        eco_2016 (rename = (population__millions_=population_mm))
    ;
    by 
        country
    ; 
    year = 2016
    ;
run;

*******************************************************************************;
* Transpose data and keep 2016 year                                            ;
*******************************************************************************;
data gpi_raw;
    set
        gpi_raw
    ;
    gpi_yoy = score_2016/score_2015 - 1
    ;
run;

data gpi_2016;
    set 
        gpi_raw (keep = country score_2016 gpi_yoy rename=(score_2016=gpi))
    ;
    year = 2016
    ;
run;

*******************************************************************************;
* Build analytic dataset with the least number of columns and
  minimal cleaning/transformation needed to address research questions in
  corresponding data-analysis files                                            ;
* Data limitation only retain countries listed in all three files              ;
*******************************************************************************;

data cotw_2016_analytic_file;
    retain
        country 
        year 
        population_mm
        happiness_rank 
        happiness_rank_yoy 
        happiness_score 
        happiness_score_yoy 
        life_expectancy 
        gdp
        gpi
        hdi 
        biocapacity_deficit_or_reserve
    ;
    keep
        country 
        year 
        population_mm
        happiness_rank 
        happiness_rank_yoy 
        happiness_score 
        happiness_score_yoy 
        life_expectancy 
        gdp
        gpi
        hdi 
        biocapacity_deficit_or_reserve
    ;
    label 
        country            = "Country"
        year               = "Year"
        population_mm      = "Population (MM)"
        happiness_rank     = "Happiness Rank"
        happiness_rank_yoy = "Happiness Rank YOY Change"
        happiness_score    = "Happiness Score"
        happiness_score_yoy= "Happiness Score YOY %"
        life_expectancy    = "Life Expectancy Rate"
        gdp                = "Gross Domestic Product (GDP)"
        gpi                = "Global Peace Index"
        hdi                = "Human Development Index"
        biocapacity_deficit_or_reserve = "Biocapacity Deficit/Reserve"
    ;
    merge 
        happy_raw_with_yoy_change  (in=a)
        gpi_2016  (in=b)
        eco_2016  (in=c)
    ;
    by 
        country 
        year 
    ;
    if a & b & c
    ;
run;

*******************************************************************************;
* use proc sort to sort the analytic data file, making a new file named 
  cotw_2016_analytic_file_sort_hr by descending happiness_rank_yoy             ;
*******************************************************************************;
proc sort 
    data=cotw_2016_analytic_file
    out=cotw_2016_analytic_file_sort_hr
    ;
    by descending 
        happiness_rank_yoy
    ;
run;

*******************************************************************************;
* use proc sort to sort the analytic data file, making a new file named 
  cotw_2016_analytic_file_sort_hs by descending happiness_score_yoy  
  for largest 20 countries                                                     ;
*******************************************************************************;
proc sort nodupkey 
    data = cotw_2016_analytic_file 
    ; 
    by descending 
        population_mm
    ; 
run;

data cotw_2016_analytic_file_sort_hs;
    set 
        cotw_2016_analytic_file
    ;
    if _n_<=20
    ;
    n_country = put(_n_,z2.)||"_"||country 
    ;
run;

proc sort nodupkey
    data = cotw_2016_analytic_file_sort_hs 
    ; 
    by 
        happiness_score_yoy
    ; 
run;
