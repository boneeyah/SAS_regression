/* Generated Code (IMPORT) */
/* Source File: CaseStudy2-data.csv */
/* Source Path: /home/u60173286 */
/* Code generated on: 8/25/22, 9:49 PM */

%web_drop_table(WORK.IMPORT);


FILENAME REFFILE '/home/u60173286/CaseStudy2-data.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.IMPORT;
	GETNAMES=YES;
	Guessingrows=30;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; RUN;


%web_open_table(WORK.IMPORT);

/* Create categorical variables for finding group patterns */

data attrition;
set work.import;
length WorkYears $5;
length IncomeGroup $9;
if TotalWorkingYears <1 then WorkYears = '<1'; else
if TotalWorkingYears <3 then WorkYears = '1-3'; else
if TotalWorkingYears <5 then WorkYears = '3-5'; else
if TotalWorkingYears <7 then WorkYears = '5-7'; else
if TotalWorkingYears <10 then WorkYears = '7-10'; else
if TotalWorkingYears <15 then WorkYears = '10-15'; else
if TotalWorkingYears <20 then WorkYears = '15-20'; else
if TotalWorkingYears <30 then WorkYears = '20-30'; else
if TotalWorkingYears >=30 then WorkYears = '>30';
if MonthlyIncome <2000 then IncomeGroup = '1k-2k'; else
if MonthlyIncome <3000 then IncomeGroup = '2k-3k'; else
if MonthlyIncome <5000 then IncomeGroup = '3k-5k'; else
if MonthlyIncome <7500 then IncomeGroup = '5k-7.5k'; else
if MonthlyIncome <10000 then IncomeGroup = '7.5k-10k'; else
if MonthlyIncome <12500 then IncomeGroup = '10k-12.5k'; else
if MonthlyIncome <15000 then IncomeGroup = '12.5k-15k'; else
if MonthlyIncome <17500 then IncomeGroup = '15k-17.5k'; else
if MonthlyIncome >=17500 then IncomeGroup = '>17.5k';
run;

/* sort by total working years for plot */
proc sort data=attrition;
by TotalWorkingYears;
run;
title 'Attrition Rate for Total Working Years Groups';
proc sgplot data = attrition pctlevel=group;
vbar WorkYears/ group=Attrition stat=pct seglabel  grouporder=descending;
xaxis discreteorder=data;
run;

proc sort data = attrition;
by MonthlyIncome;
run;
title 'Attrition Rate for Monthly Income Groups';
proc sgplot data= attrition pctlevel=group;
vbar IncomeGroup/group=Attrition stat =pct seglabel grouporder=descending;
xaxis discreteorder=data;
run;

title 'Attrition Rate for Overtime';
proc sgplot data=attrition pctlevel=group;
vbar Overtime/group=Attrition stat=pct seglabel grouporder=descending;
run;

/* drop variables */
data attrition(drop= ID employeecount employeenumber over18 standardhours);
set attrition;
run;

/* fit a logistic regression model to classify attrition*/
proc logistic data=attrition;
class Attrition OverTime MaritalStatus JobRole;
model Attrition = MonthlyIncome TotalWorkingYears Overtime MaritalStatus JobRole YearsatCompany Distancefromhome/
selection=backward expb stb lackfit ctable pprob=(.80 to .90 by .01) outroc=rocdata;
output out =  temp p=new;
store attrition_logistic;
run;

/* linear regression model to predict salary */
proc glm data=attrition plots=all;
class _char_;
model MonthlyIncome = BusinessTravel Department Gender JobInvolvement
JobLevel JobRole JobSatisfaction MaritalStatus MonthlyRate NumCompaniesWorked Overtime PercentSalaryHike PerformanceRating
RelationshipSatisfaction stockoptionlevel trainingtimeslastyear worklifebalance yearsatcompany yearsincurrentrole yearssincelastpromotion
yearswithcurrmanager monthlyrate*maritalstatus distancefromhome HourlyRate MonthlyRate*joblevel Overtime*yearsatcompany workyears
yearsincurrentrole*jobinvolvement yearswithcurrmanager*jobsatisfaction Attrition/ clparm;
run;
