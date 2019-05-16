/*Importing the Scanner data*/
libname WORK 'h:\Assignments';
DATA WORK.Toothbr;
Infile "h:\Datasets\toothbr_groc_1114_1165.dat" MISSOVER firstobs=2 ;
INPUT IRI_KEY WEEK SY GE VEND ITEM UNITS DOLLARS F $ D PR;
RUN;
proc contents;run;
proc print data=Toothbr(obs=10);run;

/*Importing the Product data*/
PROC IMPORT OUT= WORK.prod_tooth 
            DATAFILE= "H:\Datasets\prod_tooth.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
proc print data=WORK.prod_tooth(obs=10);run;

/*Creating the UPC code by merging data*/
data WORK.Toothbr(drop= SY GE VEND ITEM SY2 GE2 VEND2 ITEM2);
set WORK.Toothbr;
SY2=put(SY, z2.);
GE2=put(GE, z2.);
VEND2=put(VEND, z5.);
ITEM2=put(ITEM, z5.);
UPC = catx('-', SY2, GE2, VEND2, ITEM2);
run;
proc print data=Toothbr(obs=10);run;

proc sort data=WORK.Toothbr;
by UPC;run;
proc sort data=WORK.prod_tooth;
by UPC;run;


/*Merging the data*/
data WORK.Toothbr;
merge WORK.Toothbr WORK.prod_tooth;
by UPC;run;
proc print data=Toothbr(obs=10);run;
proc contents;run;

/*Removing the unnecessary variables*/
data WORK.Toothbr;set WORK.Toothbr(keep= IRI_KEY WEEK UNITS DOLLARS F D PR L3 L5);
run;

/*Creating the brand variable*/
data WORK.Toothbr;set WORK.Toothbr;
Brand = substr(L5, 1, 4);run;


/*Importing the store data*/
DATA WORK.store;
Infile "h:\Datasets\Delivery_Stores.dat" MISSOVER firstobs=2 ;
INPUT IRI_KEY OU $ EST_ACV Market_Name $25. Open Clsd MskdName $;
RUN;

proc print data=WORK.store(obs=10);run;

proc sort data=WORK.store;
by IRI_KEY;run;
proc sort data=WORK.Toothbr;
by IRI_KEY;run;

/*Merging the data*/
data WORK.Toothbr;
merge WORK.store WORK.Toothbr;
by IRI_KEY;run;
proc print data=WORK.Toothbr(obs=10);run;
proc contents;run;

/*Encoding the Display and Feature columns*/
data WORK.Toothbr;set WORK.Toothbr;
if D ne 0 then D=1;run;

data WORK.Toothbr;set WORK.Toothbr;
if F='NONE' then F=0;
else F=1;
run;

/*Convert feature to numeric*/
data WORK.Toothbr;set WORK.Toothbr;
Feature = input(F, best8.);
format DOLLARS dollar15.2;run;

/*Creating the average prices column*/
data WORK.Toothbr;set WORK.Toothbr;
avg_price = DOLLARS/UNITS;
format avg_price dollar15.2;run;

proc print data=WORK.Toothbr(obs=10);run;

/*Removing the unnecessary variables*/
data WORK.Toothbr;set WORK.Toothbr(keep= Market_Name MskdName WEEK UNITS DOLLARS D PR L3 L5 Brand Feature avg_price);
run;

/*1*/
proc sql outobs=6;
select Brand, SUM(DOLLARS) as Total_sales
from WORK.Toothbr
group by Brand 
order by Total_sales desc;
quit;

data ms;set WORK.Toothbr;if Brand in ('ORAL','COLG','REAC','PRIV','CRES','MENT');run;
proc tabulate data=ms;
class Brand;
var DOLLARS;
table Brand,DOLLARS*(SUM colpctn);run;
 
/*2*/
proc sql outobs=10;
select L3 as Company, SUM(DOLLARS) as Total_sales
from WORK.Toothbr
group by Company
order by Total_sales desc;
quit;

proc tabulate data=WORK.Toothbr;
class L3 Brand;
var DOLLARS;
table L3*Brand,DOLLARS*SUM;run;

/*3*/
data WORK.Toothbr; set WORK.Toothbr;
if Brand not in ('ORAL','COLG','REAC','PRIV','CRES','MENT')
then Brand = 'OTHER';run;

proc means data=WORK.Toothbr SUM MEAN STD;
var DOLLARS;class Brand;run;

proc print data=WORK.Toothbr(obs=10);run;


/*4*/
/*Average Prices of each brand*/
proc means data=WORK.Toothbr MEAN STD;
var avg_price;class Brand;run;

/*Average Display*/
proc means data=WORK.Toothbr SUM MEAN;
var D;class Brand;run;

/*Average Feature*/
proc means data=WORK.Toothbr SUM MEAN;
var Feature;class Brand;run;

/*5*/
proc sql outobs=5;
select Market_Name as Region, SUM(DOLLARS) as Total_sales
from WORK.Toothbr
group by Region
order by Total_sales desc;
quit;

/*6*/
proc sql outobs=10;
select MskdName as Store_chain, SUM(DOLLARS) as Total_sales
from WORK.Toothbr
group by Store_chain
order by Total_sales desc;
quit;

/*7*/
proc tabulate data=WORK.Toothbr;
class Brand WEEK;
var avg_price;
table WEEK,Brand*avg_price*MEAN;run;

/*Statistical Analysis*/
data WORK.brand1;set WORK.Toothbr;
if Brand='ORAL';run;
proc print data=WORK.brand1(obs=10);run;

/*9*/
data WORK.a2; set WORK.brand1;
if MskdName in ('Chain94','Chain124','Chain114') then MskdName='Top_3';
else if MskdName in ('Chain79','Chain10','Chain132') then MskdName='Bottom_3';run;

data WORK.a3;set a2;if MskdName='Top_3' or MskdName='Bottom_3';run;
proc ttest; var avg_price;class MskdName;run;

/*10*//*a*/
proc sql outobs=10;
select Market_Name as Region, SUM(DOLLARS) as Total_sales
from WORK.brand1
group by Region
order by Total_sales desc;
quit;

proc sql;
create table M_sales as
select WEEK, SUM(DOLLARS) as Dollar_sales, Market_Name
from WORK.brand1
group by WEEK,Market_Name
order by WEEK;
quit;

data WORK.b2; set WORK.M_sales;
if Market_Name in ('LOS ANGELES','NEW YORK','SAN FRANCISCO') then Market_Name='Top_3';
else if Market_Name in ('DALLAS, TX','BUFFALO/ROCHESTER','PHILADELPHIA') then Market_Name='Bottom_3';run;

data WORK.b3;set b2;if Market_Name='Top_3' or Market_Name='Bottom_3';run;
proc ttest data=WORK.b3; var Dollar_sales;class Market_Name;run;

/*b*/
proc sql;
select WEEK, SUM(UNITS) as Total_sales
from WORK.brand1
group by WEEK
order by Total_sales desc;
quit;

data WORK.Season_sales; set WORK.brand1;
if WEEK in (1140,1144) then WEEK=1;
else if WEEK in (1159,1163) then WEEK=2;run;

data WORK.c3;set Season_sales;if WEEK=1 or WEEK=2;run;
proc ttest; var DOLLARS;class WEEK;run;

/*c*/
data WORK.d2;set WORK.Toothbr;if Market_Name in ('LOS ANGELES', 'NEW YORK','SAN FRANCISCO','WASHINGTON, DC');
if L3 in ('PROCTER & GAMBLE','COLGATE PALMOLIVE');run;

proc ttest data = WORK.d2; var avg_price;class L3;run;

/*11*/
proc sql;
create table Weekly_sales as
select WEEK, count(WEEK) as no_of_observations, SUM(DOLLARS) as Dollar_sales, AVG(avg_price) as average_ppu, AVG(D) as average_display, AVG(Feature) as average_feature
from WORK.brand1
group by WEEK
order by WEEK;
quit;
proc print data=WORK.Weekly_sales;run;
data Weekly_sales;set Weekly_sales(firstobs=2);run;

proc reg data=Weekly_sales;
model Dollar_sales=average_ppu average_display average_feature;run;

/*d*/
proc sql;
select AVG(Dollar_sales) as Average_sales, AVG(average_ppu) as Mean_ppu
from Weekly_sales;

/*f*//*Interaction effects*/
data Weekly_sales;set Weekly_sales;
Display_Feature=average_display*average_feature;
Display_Price=average_display*average_ppu;
Feature_Price=average_feature*average_ppu;
PriceSq=average_ppu*average_ppu;
run;

proc reg data=Weekly_sales;
model Dollar_sales=average_ppu average_display average_feature Display_Feature Display_Price Feature_Price;run;

/*g*/
proc reg data=Weekly_sales;
model Dollar_sales=average_ppu average_display average_feature PriceSq;run;

/*h*/
proc reg data=Weekly_sales;
model Dollar_sales=average_ppu average_display average_feature /vif collin;run;

/*i*/
proc model data=Weekly_sales;
parms bo b1 b2 b3;
Dollar_sales=b0+b1*average_ppu+b2*average_display+b3*average_feature;
fit Dollar_sales/ White; Run;

/*WLS*/
proc model data=Weekly_sales;
parms bo b1 b2 b3;
average_feature_inv=1/average_feature;
Dollar_sales=b0+b1*average_ppu+b2*average_display+b3*average_feature;
fit Dollar_sales/ White;
weight average_feature_inv;
run;
