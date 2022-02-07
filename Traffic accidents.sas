%let outfolder = /folders/myfolders/statcomp2020/output;
/* %let outfolder = H:/statcomp2020//output; */

/* Q1. */
libname SASproj "/folders/myfolders/statcomp2020/data";
/* libname SASproj "H:/statcomp2020/data"; */

/* Q2. */
ods graphics on;
ods pdf file="&outfolder/reports.pdf" notoc startpage=never style=daisy;
options nodate;
ods noproctitle;

proc odstext;
	p 'SAS project report - group 14'/ style=[just=center 
		fontsize=14pt fontweight=bold];
	p 'Filip De Bel'/ style=[just=center];
	p 'Robrecht Dockx'/ style=[just=center];
	p 'Philippe Elskens'/ style=[just=center];
	p 'Matthias Vandekerckhove'/ style=[just=center];
	p '1. Introduction'/ style=[fontsize=13pt fontweight=bold textdecoration=underline];
run;

ods pdf text= "Each year 1.3 million people are killed and millions are seriously injured by traffic accidents.
The United States of America holds one of the world's most extensive carparks containing over 273 million cars. Furthermore, it has one of the world's 
highest frequencies of road fatalities resulting in an increased burden on society, 
the healthcare system and the economy. Obtaining and analyzing information concerning 
the location, weather conditions, and time of occurrence could help create more insight 
into the circumstances under which accidents occur and can thus 
help to predict or even prevent subsequent accidents. In this study, data of 3.5 
million traffic accidents were collected from February 2016 to June 2020 in 49 
states of the USA. This project aims to perform an exploratory data analysis and 
basic statistical procedures on the data collected in the state of North Carolina. More specifically, 
our main focus is on possible relations between time and weather circumstances on the one hand and on the other hand 
the severity level of the traffic accidents in the 10 counties with the highest number of accidents.";

proc odstext;
p '2. Data gathering and manipulation'/ style=[fontsize=13pt fontweight=bold textdecoration=underline];
p '2.a Data structure and cleaning'/ style=[fontsize=12pt fontweight=bold textdecoration=underline];
run; 

ods pdf text= "The dataset was loaded into SAS and its structure was assessed. 
It holds 23 variables, each with the right type and format, and 165 958 observations. The proc contents 
procedure was used to produce a table with the type, name and length of the variables (Table 1).
 Some variables (Temperature_F_, Wind_Chill_F_, Humidity___, 
Pressure_in_, Visibility_mi_, Wind_Speed_mph_, and Precipitation_in_) were renamed 
(Temp, WindChill, Humidity, Pressure, Visibility, WindSpeed, and Precip) and given an 
appropriate label (Temperature (F), Wind Chill (F), Humidity (%), Pressure (in), 
Visibility (mi), Wind Speed (mph), and Precipitation (in)) to improve readability. 
All duplicate rows (1013) were removed from the dataset. In this procedure, two datasets were 
created; one containing no duplicate rows and another containing only the duplicate rows. 
Both datasets were saved but only the first dataset was used for further 
manipulations and computations.";

ods select variables;
ods exclude all;

proc contents data=SASproj.group14_nc;
	ods output variables=variables_chars;
run;

ods exclude none;
ods select default;

proc odstext;
	p 'Table 1. Name, type and length of the variables'/ style=[just=center 
		fontsize=12pt fontweight=bold fontstyle=italic];
proc print data=variables_chars contents='';
	var variable type len;
run;

/* Q3. */
data accidents;
	set SASproj.group14_nc;
	rename Temperature_F_=Temp 
		Wind_Chill_F_=WindChill 
		Humidity___=Humidity 
		Pressure_in_=Pressure 
		Visibility_mi_=Visibility 
		Wind_Speed_mph_=WindSpeed 
		Precipitation_in_=Precip;
	label Temperature_F_='Temperature (F)' 
		Wind_Chill_F_='Wind Chill (F)' 
		Humidity___='Humidity (%)' 
		Pressure_in_='Pressure (in)' 
		Visibility_mi_='Visibility (mi)' 
		Wind_Speed_mph_='Wind Speed (mph)' 
		Precipitation_in_='Precipitation (in)';
proc sort data=accidents out=accidents noduprecs dupout=accidents_dups;
	by _all_;
run;

/* Q4. */
proc odstext;
	p '';
	p '2.b Data manipulation, subsetting and missing values'/ style=[fontsize=12pt fontweight=bold textdecoration=underline];
run;
ods pdf text= "The mean and variance of the variables Humidity, Temp, WindChill, Pressure, Visibility, 
WindSpeed and Precip were calculated for each of the four accident severity levels. 
First, the macro variable weather_variables was created and defined as a list of the aforementioned variables. 
This macro variable was used in the proc tabulate procedure in order to calculate the means and variances. 
The class syntax was specified with the categorical variable severity so as to obtain the mean and variance 
for each severity level (Table 2). On the whole, the means are quite similar for each level whereas there 
are small to moderate differences between the variances.";

%let weather_variables = Humidity Temp WindChill Pressure Visibility WindSpeed Precip;

proc odstext;
	p 'Table 2. Mean and variance of weather variables by severity level'/ 
		style=[just=center fontsize=12pt fontweight=bold fontstyle=italic];
proc tabulate data=accidents;
	class severity;
	var &weather_variables;
	table &weather_variables, severity*(mean var);
run;

/* Q5a. */
proc sort data=accidents;
	by county;
data accidents_cumul;
	set accidents;
	by county;
	if first.county then
		cumul=0;
	cumul+1;
	if last.county;
proc sort data=accidents_cumul (keep=county cumul);
	by descending cumul;
run;

/* Q5b. */
proc odstext;
	p '';
run;

ods pdf text= "In order to obtain the ten counties in the state of North Carolina with the highest number of 
traffic accidents, the dataset was first sorted according to the variable county. Subsequently, either the 
first.variable method or the proc freq procedure were used to count the number of traffic accidents in each 
county. The ten counties with the highest number of accidents are presented in table 3. A new 
permanent dataset (top10) was created, containing only information on the traffic accidents that occurred in 
these ten counties. A horizontal bar chart was created from this permanent dataset so as to give a visual 
representation of the same information (graph 1). It can be seen from table 3 and graph 1 that the counties 
Mecklenburg and Wake have the highest number of accidents by far- at least seventeenfold higher than other 
counties. In the data analysis, we should give adequate consideration to the possibility that these 
frequencies are the consequence of errors that could have been made during the data registration process. 
To rule this out, contact should be established with the registration office in both counties. 
If the data is proven to be correct, then the data should be processed and analyzed as such. 
However, the fact that these 2 counties are located in the most densely populated areas of the state 
(the city centres of Charlotte and Raleigh) can be taken as an indication that this data is indeed correct.";

/* This proc sort step was already used for our first method (Q5a), but is left as a comment. */
/* proc sort data=accidents; */
/* 	by county; */
/* run; */

proc odstext;
	p 'Table 3. Ten counties with the highest number of accidents'/ 
	style=[just=center fontsize=12pt fontweight=bold fontstyle=italic];
proc freq data=accidents noprint order=freq;
	tables county / nocum nopercent
	out=accidents_county_freq (drop=percent);
proc print data=accidents_cumul (obs=10);
run;

/* Q5c. */
proc sort data=accidents_cumul (obs=10) 
	out=top10 (keep=county);
	by descending county;
run;

/* Q6. */
proc sort data=top10 out=top10_sorted;
	by county;
data SASproj.top10;
	merge top10_sorted (in=a) accidents;
	by county;
	if a;
run;

/* Q7. */
ods graphics / height=8cm width=12cm;
title "Graph 1. Total number of car accidents per County (top 10)";
proc sgplot data=SASproj.top10;
	hbar county / categoryorder=respdesc;
	xaxis label='Number of accidents' labelattrs=(size=12);
	yaxis label='County' labelattrs=(size=12);
run;
title;

/* Q8a. */
proc odstext;
	p '';
run;
ods pdf text= "The missing data points in the permanent dataset top10 were investigated for the weather 
variables by making use of the macro variable weather_variables. Initially, the proc mi procedure was used 
with the options nimpute set to zero and displaypattern to nomeans. The resulting table (not included in this 
report) shows the missing value pattern for the seven variables of our interest. Alternatively, the proc means 
procedure (with autoname option) was used to assess the number of missing values for the same variables 
(table 4). This table was saved as a temporary table (cmissing). Of the 156 253 observations in the top10 
dataset, over 90 000 are missing for the variables WindChill and Precip. The validity of these values 
should be confirmed with the observation post. There is, for example, the possibility that measurements of 
value zero were mistakenly registered as missing values. The same possibility exists for the variable 
WindSpeed, which holds over 20 000 missing values.";

/* In order to see the table produced by proc mi, don't run the statements 'ods exclude all;' and  */
/* 'ods exclude none'. Optionally, 'ods select misspattern;' can be used. */

ods exclude all;
/* ods select misspattern; */
proc mi data=SASproj.top10 nimpute=0 displaypattern=nomeans;
	var &weather_variables;
run;
ods exclude none;

/* Q8b. */
proc odstext;
	p 'Table 4. Number of missing values for each weather variable'/ 
	style=[just=center fontsize=12pt fontweight=bold fontstyle=italic];
proc means data=SASproj.top10 noprint;
	var &weather_variables;
	output out=cmissing nmiss= / autoname;
proc print data=cmissing label width=min;
proc odstext;
	p '';
run;

ods pdf text= "The dataset cmissing was transposed using a proc transpose step and subsequently used to create 
table 2. Graph 2 visually represents the same information, but here the bars are in descending order. 
Seven macro variables (nmiss1 to nmiss7) were created containing the values of the column nmiss. 
These values were displayed in the log.";

/* Q8c. */
proc transpose data=cmissing out=transpose (rename=(COL1=nmiss));
proc odstext;
	p 'Table 5. Number of missing values for each weather variable (transposed)'/ 
		style=[just=center fontsize=12pt fontweight=bold fontstyle=italic];
data transpose2;
	set transpose;
	where _NAME_ not in ("_TYPE_" "_FREQ_");
proc print data=transpose2;
run;

/* Q8d. */
proc sql noprint;
	select nmiss into :nmiss1 - :nmiss7 from transpose2;
	%put &nmiss1;
	%put &nmiss2;
	%put &nmiss3;
	%put &nmiss4;
	%put &nmiss5;
	%put &nmiss6;
	%put &nmiss7;
quit;

/* Q8e. */
ods pdf startpage=now; 
options orientation=landscape;
title "Graph 2. Number of Missing Values";
proc sgplot data=transpose2;
	vbar _label_ / response=nmiss categoryorder=respdesc;
	xaxis label='Weather variables' labelattrs=(size=12);
	yaxis display=(nolabel);
run;
title;

/* Q8f. */
proc odstext;
	p '';
run;
ods pdf text= "Table 6 shows the first 10 observations. It contains a colum cmissing that shows the number 
of missing variables for each observation. In order to make sure that this table retains clarity and 
overview, only those variables that are relevant to this report (ID, severity, start time, 
lattitudinal and longitudinal coordinates, seven weather variables, and sunrise_sunset) are included.";

proc odstext;
	p 'Table 6. First ten observations'/ 
		style=[just=center fontsize=12pt fontweight=bold fontstyle=italic];
data accidents_cmissing;
	set SASproj.top10 ;
	array vars{7} &weather_variables ;
	cmissing=cmiss(of vars[*]);
proc print data=accidents_cmissing (obs=10) width=min;
	var ID severity Start_Time Start_Lat Start_Lng &weather_variables Sunrise_Sunset cmissing;
run;

ods pdf startpage=now; 
options orientation=portrait;

/* Q8g. */
data SASproj.top10_cmiss;
	set accidents_cmissing;
	where cmissing LE 3;
run;

/* Q9a. */
proc odstext;
	p '3. Statistical analysis'/ style=[fontsize=13pt fontweight=bold textdecoration=underline];
	p "3.a Relation between time and severity level of a traffic accident? "/ style=[fontsize=12pt fontweight=bold textdecoration=underline];
run;

ods pdf text="The severity of a traffic accident can be categorized as either low, mild, 
severe or very severe with a numerical value of 1 up to 4 respectively. 
For analysis, this four-level categorical variable (severity) was reduced to a 
binary categorical variable (severity4) with the levels non-severe and severe. 
The non-severe level represents all accidents with a severity level of 1 up to
3, whereas the level severe only represents the accidents of severity level 4. 
The number of accidents for each level of severity4 for the past five years 
are displayed in table 7. When constructing this table, we assured ourselves that there 
were no missing values for severity. 
As seen from this table, we observe a lower number of accidents in 2016 
compared to the following years. Most accidents (>97%) have severity scores 1-3. 
In each year, less than 3% of accidents are severe. When interpreting table 7 the following 
has to be taken into consideration. In the year 2016, only 5667 accidents were registered, 
in contrast to the years 2017-2019 where over 30 000 accidents were registered. 
This could be an error in the registration or, potentially, it might have something to due with the fact 
that registration started later in 2016 (February). In 2020, we observe once again a relatively low 
amount of accidents, this could be because only data up until June was included. 
Nevertheless, almost the same amount of severe accidents occurred in 2020 as in 2019. 
Graph 3 teaches us that these time-dependent differences are solely due to Mecklenburg and Wake. 
In these counties, the number of accidents reaches a maximum in 2018. 
Factors causing this rise should be further investigated. The number of accidents for the other shown 
counties remains fairly constant over this time period (Graph 3).";
 
proc format;
	value sevfmt 0='non-severe (1-3)' 1='severe (4)';
data SASproj.top10_cmiss;
	set SASproj.top10_cmiss;
	if severity=4 then severity4=1;
	else severity4=0;
	format severity4 sevfmt.;
run;

/* Q9b. */
proc odstext;
	p 'Table 7. Frequency plot per year for non-severe and severe accidents'/ style=[just=center 
		fontsize=12pt fontweight=bold fontstyle=italic];
proc freq data=SASproj.top10_cmiss;
	format Start_Time dtyear4.;
	table Start_Time*severity4 / nocum nopercent nocol;
run;

/* Q9c. */
title  "Graph 3. Number of accidents per county per year";
proc sgplot data=SASproj.top10_cmiss;
	format Start_Time dtyear4.;
	vline Start_Time /group=County curvelabel curvelabelloc=OUTSIDE;
	xaxis label="Year";
	yaxis label="Number of accidents";
run;
title;

/* Q9d. */
proc format;
	value monthname 1='Jan' 2='Feb' 3='Mar' 4='Apr' 5='May' 6='Jun' 7='Jul' 8='Aug' 
		9='Sep' 10='Oct' 11='Nov' 12='Dec';
run;

proc format;
	value weekdayname 1='Sun' 2='Mon' 3='Tue' 4='Wed' 5='Thu' 6='Fri' 7='Sat';
run;

data sasproj.top10_cmiss;
	set sasproj.top10_cmiss;
	month=month(datepart(start_time));
	day=weekday(datepart(start_time));
	hour=hour(start_time);
	format day weekdayname.;
	format month monthname.;
run;

/* Q9e. */
ods pdf startpage=now; 
ods pdf text="Graph 4, 5, and 6 show the number of non-severe and severe 
accidents per month, day of the week, and hour of day respectively. Although 
a monthly variation in the number accidents can be suspected (for example 
more non-severe accidents in August compared to June; graph 4), at this point of 
the analysis, it is unclear whether these are due to coincidence or some 
other factor. In case this will be analyzed in the future, consideration should 
be given to the fact that for 2016 and 2020 the data is not present 
for every month. Graph 5 shows a lower number of accidents during the weekend 
than during the working week. Graph 6 indicates that more accidents occur 
during the day than at night. This relation is properly statistically 
analyzed in the next section.";

ods graphics / height=7cm width=20.32cm;
%let timepoint = month;

title "Graph 4. Number of accidents for each month of the year";
proc sgplot data=sasproj.top10_cmiss;
	vbar &timepoint / group=severity4 groupdisplay=cluster datalabel; 
	xaxis display=(nolabel);
run;
title;

%let timepoint = day;

title "Graph 5. Number of accidents for each day of the week";
proc sgplot data=sasproj.top10_cmiss;
	vbar &timepoint / group=severity4 groupdisplay=cluster datalabel;
	xaxis display=(nolabel);
run;
title;

%let timepoint = hour;

title "Graph 6. Number of accidents for each hour of the day";
proc sgplot data=sasproj.top10_cmiss;
	vbar &timepoint / group=severity4 groupdisplay=cluster datalabel;
run;
title;

/* Q10. */
proc odstext;
	p '';
run;

ods pdf text="In order to determine an association between the level of severity and whether or not 
it is day or night, 
a Chi-Square test was performed on the variables severity4 and sunrise_sunset. 
Both variables are binary (non-severe and severe; day and night respectively). 
Based on the Chi-square value (231.1802, df = 1, p-value <0.0001), 
we can conclude that there is an association between both variables. 
This suggests that at night accidents are relatively more severe compared to during the day. 
An Oddsratio of 2.33 with a 95%-confidence interval between 2.08 and 2.60 was obtained. 
This implies that the odds of having a severe accident at night is 2.08-2.60 times the odds of 
having a severe accident during the day. Since 1 is not contained in
this interval, this ratio is statistically significant.";

ods exclude all;
ods trace ON;

proc freq data=sasproj.top10_cmiss;
	tables sunrise_sunset*severity4 / chisq plots=freqplot oddsratio expected;
	ods output RelativeRisks=odds_CI;
run;

ods trace OFF;

proc sort data= SASproj.top10_cmiss out=tmp_sorted_severity;
	by descending severity4;
proc freq data=tmp_sorted_severity;
	tables severity4 * Sunrise_Sunset / nocum nocol norow nopercent expected chisq oddsratio;
run;
ods exclude none;

/* Q11. */
proc odstext;
	p "3.b Does location affect the number of traffic accidents?"/ 
	style=[fontsize=12pt fontweight=bold textdecoration=underline];
run;

ods pdf text="Both graph 7 and 8 display a bimodal distribution for the relative number of accidents. 
Visual inspection of a population density map of the state of North Carolina shows us that these peaks 
coincide with the more populated urban centers. The city with the highest population (>900,000) is Charlotte. 
Its coordinates are 35.22° N, 80.84° W, which coincides with the highest peaks of both graphs. 
The second peak on graph 4 corresponds to the second largest city Raleigh(78.64° W) and the sixth 
largest city Fayetteville (78.88° W). Although Raleigh (35.78° N) definitely corresponds with the 
second peak of graph 8, the third, fourth and fifth largest cities (Greensboro, Durham and Winston-Salem) 
also contribute to it. The small shoulder on graph 4 shows the lattitude of Greensboro (36.07° N). 
This confirms our findings from question 7.";

ods graphics / height=8cm width=12cm;
ods graphics on;
proc univariate data=sasproj.top10_cmiss noprint;
	histogram start_lat/ kernel
	odstitle="Graph 7. Percentage of car accidents for lattitudinal coordinates";
	label start_lat = lattitude (° N);
run;

proc univariate data=sasproj.top10_cmiss noprint;
	histogram start_lng/ kernel
	odstitle="Graph 8. Percentage of car accidents for longitudinal coordinates";
	label start_lng = longitude (° W);
run;

/* Q12a. */
ods pdf startpage=now; 
proc odstext;
	p '3.c Relation between weather condition and severe traffic accidents?'/ 
	style=[fontsize=12pt fontweight=bold textdecoration=underline];
run;
ods pdf text="Via a proc freq step we created a table that shows the number of accidents for each value 
of the categorical variable weather condition. This table (not included) showed that the most accidents 
happened during fair weather. It is important to note that this does not mean that there is a positive 
association between this weather condition and the occurrence of traffic accidents. To check this, 
we would have to take into account how often every weather condition occurs. Then, we calculated 
the Pearson correlation coefficient for the seven numerical weather variables. Table 8 shows the results 
for those 3 variables (Pressure, WindChill, WindSpeed) with the strongest (positive or negative) correlation. Lastly a macro was created 
to plot a histogram, a bar chart, and the statistics for a weather variable. Then, this macro was run 
for forementioned 3 variables (graphs and tables not included in this report).";

ods exclude all;
proc freq data=sasproj.top10_cmiss order=freq; 
	tables Weather_Condition * severity/ nocol norow nocum;
	where severity EQ 4; 
run;
ods exclude none;

/* Q12b. */
ods graphics/  reset=all imagemap;
ods trace ON;
proc odstext;
	p 'Table 8. Pearson correlation coefficient between number of accidents and the 3 most relevant weather variables'/ 
	style=[just=center fontsize=12pt fontweight=bold fontstyle=italic];
proc corr data=sasproj.top10_cmiss  nosimple rank best=3; 
	with severity4;
	var &weather_variables; 
	ods output PearsonCorr=Best3; 
ods select PearsonCorr;
run;
ods trace OFF; 
ods select all;

options mprint;

proc odstext;
	p '4. Conclusion'/ 
	style=[fontsize=13pt fontweight=bold textdecoration=underline];
run;

ods pdf text="In this report we discussed the results of our data analysis 
of data about car accidents in North Carolina, USA, between February 2016 
and June 2020. We made an initial exploration of the data with a proc 
contents step. The next step involved manipulation of our data set. 
Some variables were renamed, the data set was subset according to the 
county were the accidents happened. The pattern of missing variables 
was analyzed for numerical variables that contain information about 
the weather. For the statistical analysis, we searched for 
possible relations between the number of accidents (and their 
severity) and time (year, month, day of the week, hour, sunrise/sunset), 
place (lattitude and longitude) and weather conditions. The generated graphs and tables
allowed us to suspect relations with place (more accidents 
happened in densely populated areas) and time (less accidents 
during the weekend; more accidents occurred during the day). 
The results of a Chi-square test confirmed that there is a statistical 
difference (95%-confidence interval for the oddsratio = 2.08 and 2.60) between the number of accidents that 
happened during day or night time.";

proc odstext;
	p '5. Who did what?'/ 
	style=[fontsize=13pt fontweight=bold textdecoration=underline];
run;

ods pdf text="This project was a joint collaboration between Robrecht Dockx, Philippe Elskens, and Matthias 
Vandekerckhove. We agreed that this was an excellent opportunity to sharpen our SAS programming skills and 
attempted to solve each question individually. In a second stage, our three codes were compiled into one. 
Here, our strategy demonstrated its strength. For a small number of questions, only one or two people had 
found a correct answer. For a number of other questions, we found two or even three working solutions. Here, 
comparing the advantages and disadvantages of each method was a great learning experience. In the last stage, 
in which communication was even more frequent, the finalization of the code and PDF was accomplished by 
dividing the work. For a particular paragraph, a first person briefly explained his point of view, a 
second person wrote a text, and the third person edited it. Unfortunately, communication with Filip De Bel 
proved to be difficult. ";

/* Q12c. */
options mprint;

%macro analyse(var_list);
%local i next_var;
%do i=1 %to %sysfunc(countw(&var_list));
   %let next_var = %scan(&var_list, &i,' ');
   %DO ;

proc sgplot data = sasproj.top10_cmiss;
	vbox &next_var / category=severity4;
proc sgplot data=sasproj.top10_cmiss;
	histogram &next_var / group= severity4;
proc ttest data=sasproj.top10_cmiss;
var &next_var;
class severity4;
run;
   %end;
%end;
%mend analyse;

ods exclude all;
%let var_list = pressure windchill windspeed;
%analyse(&var_list);

options nomprint;

ods pdf close;