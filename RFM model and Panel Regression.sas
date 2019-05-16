/*Data Merging*/
PROC IMPORT OUT= WORK.drugStr 
            DATAFILE= "H:\toothbr\toothbr_drug_1114_1165.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="toothbr_drug_1114_1165$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc print data=WORK.drugStr(obs=10);run;4

libname l1 "H:\toothbr";
data l1.drugStr(drop=SY GE VEND ITEM);set WORK.drugStr;run;

PROC IMPORT OUT= WORK.grocStr1 
            DATAFILE= "C:\rxk173530\toothbr_groc_1114_1165_1.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="toothbr_groc_1114_1165$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= WORK.grocStr2 
            DATAFILE= "H:\toothbr\toothbr_groc_1114_1165_2.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="toothbr_groc_1114_1165$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= WORK.grocStr3
            DATAFILE= "H:\toothbr\toothbr_groc_1114_1165_3.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="toothbr_groc_1114_1165$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

libname l1 "H:\toothbr";
data drugStr; set l1.drugstr;run;

data WORK.grocStr(drop = SY GE VEND ITEM);
set WORK.grocStr1 WORK.grocStr2 WORK.grocStr3;run;

libname q1 "C:\rxk173530";
data q1.grocStr(drop = SY GE VEND ITEM);
set WORK.grocStr1 WORK.grocStr2 WORK.grocStr3;run;

data q1.strSales;
set q1.grocStr l1.drugstr;run;

data q1.strsales; set q1.strsales;
if F='NONE' then F=0;else if F ne 'NONE' then F=1;
if D ne 0 then D=1;run;

proc freq data=q1.strsales;table D F PR;run;

proc sort data=q1.strsales;
by UPC;run;
proc sort data=l1.productdata;
by UPC;run;

/*Merging the data*/
data q1.sales_merged;
merge q1.strsales l1.productdata;
by UPC;run;
proc print data=q1.sales_merged(obs=10);run;
proc contents;run;

DATA q1.stores;
Infile "h:\toothbr\Delivery_Stores.dat" MISSOVER firstobs=2 ;
INPUT IRI_KEY OU $ EST_ACV Market_Name $25. Open Clsd MskdName $;
RUN;
proc contents;run;
proc print data=q1.stores(obs=10);run;

data q1.sales_merged(drop = size bristle vol_eq user_info shape);set q1.sales_merged;
if colupc ne .;run;

proc sql;
select Brand, SUM(DOLLARS) as Dollar_sales, SUM(UNITS) as units_sold
from q1.sales_merged
group by Brand 
order by Dollar_sales desc;
quit;

data q1.sales_updated;set q1.sales_merged;
if brand in ('ORAL', 'COLGATE', 'REACH', 'PRIVATE', 'CREST');
if count ne 'T';
run;

proc contents data=q1.sales_updated;run;

data q1.sales_updated(drop = F COUNT); set q1.sales_updated;
F1 = input(F, best5.);
COUNT1 = input(COUNT, best5.);run;

proc sort data=q1.stores;
by IRI_KEY;run;
proc sort data=q1.sales_updated;
by IRI_KEY;run;

data q1.sales_master;
merge q1.stores q1.sales_updated;
by IRI_KEY;run;
proc print data=q1.sales_master(obs=10);run;
proc contents;run;

data q1.sales_master; set q1.sales_master;
if colupc ne .;
avg_price = DOLLARS/(UNITS*COUNT1);
run;

PROC IMPORT OUT= WORK.DR
            DATAFILE= "H:\toothbr\toothbr_PANEL_DR_1114_1165.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="toothbr_PANEL_DR_1114_1165$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
PROC IMPORT OUT= WORK.GR
            DATAFILE= "H:\toothbr\toothbr_PANEL_GR_1114_1165.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="toothbr_PANEL_GR_1114_1165$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
PROC IMPORT OUT= WORK.MA
            DATAFILE= "H:\toothbr\toothbr_PANEL_MA_1114_1165.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="toothbr_PANEL_MA_1114_1165$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

libname q1 'c:\rxk173530';
data q1.panel_merged;
set dr gr ma;run;

proc sort data =q1.panel_merged;
by PANID;run;
proc sort data =q1.demo;
by PANID;run;

data q1.panel_master;
merge q1.panel_merged q1.demo;
by PANID;run;

PROC IMPORT OUT= WORK.productData 
            DATAFILE= "H:\toothbr\prod_tooth.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc print data=productData(obs=10);run;

data productData(keep = UPC COMPANY L5 BRAND VOL_EQ COUNT BRISTLE SIZE USER_INFO SHAPE);set productData;run;

libname l1 "H:\toothbr";
data l1.productData;set productData;run;
PROC IMPORT OUT= WORK.demo1 
            DATAFILE= "H:\toothbr\ads demo 1 - updated.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
PROC IMPORT OUT= WORK.DEMO3 
            DATAFILE= "H:\toothbr\ads demo 3 - updated.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data demo1 (drop = language hisp_cat);
set demo1;run;
data demo3 (drop = language hisp_cat);
set demo3;run;

proc contents data=demo1;run;

data demo(keep = Panelist_ID Combined_Pre_Tax_Income_of_HH Family_Size Type_of_residential_possession HH_AGE HH_EDU HH_OCC Marital_Status);
set demo1 demo3;run;

data demo_r;set demo(rename= (Panelist_ID=PANID Combined_Pre_Tax_Income_of_HH=Income HH_AGE=Age HH_EDU=Education HH_OCC=Occupation));
run;

proc print data = demo_r(obs=10);run;

data demo_s;set demo_r;
if Income>0 and Income<=6 then Income_l =1; else if Income>6 and Income<12 then Income_l=2; else if Income=12 then Income_l=3;
if Marital_Status>2 then Marital_Status=1;
if age=0 or age=7 then age_l=0; else if age>1 and age<=2 then age_l=1; else if age>2 and age<=4 then age_l=2; else if age>4 then age_l=3;
run;

proc freq data=demo_s;run;

libname q1 'c:\rxk173530';
data q1.demo;set demo_s;run;

libname q1 'c:\rxk173530';

data sales_master(keep = IRI_KEY WEEK UNITS DOLLARS D PR F1 UPC COLUPC BRAND COUNT1 avg_price);
set q1.sales_master;run;

/* Market share of each UPC */
proc sql;
create table UPC_ms as 
select IRI_KEY, WEEK, UPC, COLUPC, BRAND, COUNT1, avg_price, SUM(DOLLARS) as Sales
from sales_master
group by IRI_KEY, WEEK, BRAND, UPC;
quit;

proc sql;
create table UPC_ms1 as 
select IRI_KEY, WEEK, UPC, COLUPC, BRAND, COUNT1, avg_price,Sales, Sales/SUM(Sales) as Market_Share
from UPC_ms
group by IRI_KEY, WEEK, BRAND;
quit;

data q1.UPC_ms; set UPC_ms1;run;

data sales_master; set q1.sales_master;run;

data sales_fdpr(keep = IRI_KEY WEEK D PR F1 UPC BRAND COUNT1);set sales_master;run;

proc sort data=q1.UPC_ms;
by IRI_KEY WEEK BRAND UPC;run;

proc sort data=sales_fdpr;
by IRI_KEY WEEK BRAND UPC;run;

data sales_wtd_f;
merge sales_fdpr q1.UPC_ms;
by IRI_KEY WEEK BRAND UPC;run;

data sales_wtd;set sales_wtd_f;
F_wt = F1*Market_Share;
D_wt = D*Market_Share;
PR_wt = PR*Market_Share;
avg_price_wt = avg_price*Market_Share;
run;

proc sql;
	create table panel_demo as
	select t1.IRI_KEY, t1.WEEK,t1.UPC, t1.COLUPC, t1.BRAND,t2.PANID,t2.DOLLARS,t2.Income_p,t2.age_p,t2.Family_Size, t2.Type_of_Residential_Possession,t2.EDU,t2.occ,t2.Marital_status 
	from Sales_wtd as t1
	inner join q1.panel_master as t2 on t1.IRI_KEY = t2.IRI_KEY and t1.WEEK = t2.WEEK and t1.COLUPC = t2.COLUPC;
quit;

proc sql;
create table sales_wtd_brand as
select IRI_KEY, WEEK, BRAND, SUM(avg_price_wt) as Avg_Price, SUM(F_wt)as F, SUM(D_wt) as D, SUM(PR_wt) as PR
from sales_wtd
group by IRI_KEY,WEEK,BRAND;
quit;

data q1.wtd_sales_pr_wk_n_brnd;set sales_wtd_brand;run;

proc sql;
create table Panel_demo_1 as
select IRI_KEY, WEEK,BRAND,PANID,SUM(DOLLARS)as Dollar_Sales,Income_p,age_p,Family_Size,Type_of_Residential_Possession,EDU,occ,Marital_status 
from Panel_demo
group by PANID, IRI_KEY, WEEK, BRAND;quit;

proc sql;
create table Panel_reg_master as
select t1.IRI_KEY, t1.WEEK,t1.BRAND,t1.PANID,t1.Dollar_Sales,t1.Income_p,t1.age_p,t1.Family_Size,t1.Type_of_Residential_Possession,t1.EDU,t1.occ,t1.Marital_status,t2.Avg_Price,t2.F,t2.D,t2.PR
from Panel_demo_1 as t1
inner join sales_wtd_brand as t2 on t1.IRI_KEY = t2.IRI_KEY and t1.WEEK = t2.WEEK and t1.BRAND = t2.BRAND;
quit;

data q1.panel_reg_master;set Panel_reg_master;run;

/*RFM Model*/
libname q1 'c:\rxk173530';
data panel_master;set q1.panel_reg_master;run;

proc sql;
create table pan_M as
select PANID, BRAND, SUM(Dollar_Sales) as SUMAMT
from panel_master
group by PANID, BRAND;
quit;

proc sql;
create table pan_salesAmt as
select PANID, SUM(SUMAMT) as Total_Amt
from pan_M
group by PANID;
quit;

proc transpose data = pan_m out = pan_m_amt prefix = AMT_;
	by PANID;
	id BRAND;
	var SUMAMT;
run;

data pan_amt(drop=i);                                                    
  set pan_m_amt;                                                            
  array testmiss(*) _numeric_;                                            
  do i = 1 to dim(testmiss);                                              
    if testmiss(i)=. then testmiss(i)=0;                                    
  end;                                                                    
run;                                                                    

proc sql;
create table pan_lm as
select t1.PANID, t1.AMT_REACH,t1.AMT_ORAL,t1.AMT_CREST,t1.AMT_COLGATE,t1.AMT_PRIVATE,t2.Total_Amt
from pan_amt as t1
inner join pan_salesamt as t2 on t1.PANID=t2.PANID;
quit;

data pan_lm1; set pan_lm;
Reach_l = AMT_REACH/Total_Amt;
Oral_l = AMT_ORAL/Total_Amt;
Crest_l = AMT_CREST/Total_Amt;
Colgate_l = AMT_COLGATE/Total_Amt;
Private_l = AMT_PRIVATE/Total_Amt;run;

/*check*/
proc sql;
create table panel_check as
select t1.IRI_KEY, t1.WEEK, t1.COLUPC, t1.PANID, t2.BRAND
from q1.panel_master as t1 inner join q1.sales_master as t2 on t1.COLUPC = t2.COLUPC and t1.WEEK = t2.WEEK and t1.IRI_KEY = t2.IRI_KEY;
quit;

proc freq data = panel_check; table BRAND;run;

/*rfm*/
data panel_mas(keep = PANID WEEK UNITS IRI_KEY COLUPC);set q1.panel_master;run;
proc sort data = panel_mas;
by IRI_KEY WEEK COLUPC;run;

data sales_master(keep = IRI_KEY WEEK COLUPC BRAND); set q1.sales_master;run;
proc sort data = sales_master;
by IRI_KEY WEEK COLUPC;run;

data panel_useless;
merge panel_mas sales_master;
by IRI_KEY WEEK COLUPC; run;

data panel_useful;set panel_useless;if PANID ne .;
if BRAND in ('ORAL', 'COLGATE', 'PRIVATE','REACH','CREST');
run;

proc sql;
create table pan_freq as
select PANID, BRAND, SUM(UNITS) as Freq, MAX(WEEK) as Rec
from Panel_useful
group by PANID, BRAND;
quit;

proc transpose data = pan_freq out = pan_freq1 prefix = FREQ_;
	by PANID;
	id BRAND;
	var FREQ;
run;

data pan_freq2(drop=i);                                                    
  set pan_freq1;                                                            
  array testmiss(*) _numeric_;                                            
  do i = 1 to dim(testmiss);                                              
    if testmiss(i)=. then testmiss(i)=0;                                    
  end;                                                                    
run;                                                                    

proc transpose data = pan_freq out = pan_rec prefix = REC_;
	by PANID;
	id BRAND;
	var REC;
run;

data pan_rec1(drop=i);                                                    
  set pan_rec;                                                            
  array testmiss(*) _numeric_;                                            
  do i = 1 to dim(testmiss);                                              
    if testmiss(i)=. then testmiss(i)=0;                                    
  end;                                                                    
run;                                                                    

data pan_lrfm;
merge pan_lm1 pan_freq2 pan_rec1;
by PANID;run;

data pan_lrfm1(keep = PANID AMT_REACH Reach_l FREQ_REACH REC_REACH);set pan_lrfm;
if AMT_REACH >0;
run;

data q1.panid_rfm;set pan_lrfm1;run;

libname q1 'c:\rxk173530';
data pan_rfm;set q1.panid_rfm;run;

proc rank data=pan_rfm out=b1 ties=low groups=5;var AMT_REACH;ranks rnk_monetary;run;
proc print data=b1 (obs=100);run;
proc freq data=b1;table rnkscore;run;

proc rank data=b1 out=b2 ties=low groups=5;var Reach_l;ranks rnk_loyalty;run;
proc print data=b2 (obs=100);run;

proc rank data=b2 out=b3 ties=low groups=5;var FREQ_REACH;ranks rnk_freq;run;
proc print data=b3 (obs=100);run;

proc rank data=b3 out=b4 ties=low groups=5;var REC_REACH;ranks rnk_rec;run;
proc print data=b4 (obs=100);run;

proc corr data=b4;run;

data q1.RFM_ranked;set b4;run;

/*Panel Regression*/
libname q1 'c:\rxk173530';

data wtd_notneeded(Keep = IRI_KEY WEEK BRAND Dollars); set q1.weighted_sales;run;
data wtd_useful; set q1.wtd_sales_pr_wk_n_brnd;run;

proc sort data = wtd_notneeded;
by IRI_KEY WEEK BRAND;run;

proc sort data = wtd_useful;
by IRI_KEY WEEK BRAND;run;

data store_level;
merge wtd_notneeded wtd_useful;
by IRI_KEY WEEK BRAND;run;

/*creating data for panel regression by pivoting values*/
proc transpose data = store_level out = store_level_price prefix = PRICE_;
	by IRI_KEY WEEK;
	id BRAND;
	var Avg_price;
run;



proc transpose data = store_level out = store_level_feat prefix = FEATURE_;
	by IRI_KEY WEEK;
	id BRAND;
	var F;
run;


proc transpose data = store_level out = store_level_disp prefix = DISPLAY_;
	by IRI_KEY WEEK;
	id BRAND;
	var D;
run;

proc transpose data = store_level out = store_level_pr prefix = PR_;
	by IRI_KEY WEEK;
	id BRAND;
	var PR;
run;


proc transpose data = store_level out = store_level_sales prefix = DOLLARS_;
	by IRI_KEY WEEK;
	id BRAND;
	var Dollars;
run;


/*merge all dataset*/
data store_data;
	merge store_level_price store_level_feat store_level_disp store_level_pr store_level_sales;
run;

proc print data = store_data (obs = 10);
run;

data store_data(drop=i);                                                    
  set store_data;                                                            
  array testmiss(*) _numeric_;                                            
  do i = 1 to dim(testmiss);                                              
    if testmiss(i)=. then testmiss(i)=0;                                    
  end;                                                                    
run;                                                                    

/*considering only REACH sales data*/
data store_data;
	set store_data;
	drop DOLLARS_COLGATE;
	drop DOLLARS_ORAL;
	drop DOLLARS_PRIVATE;
	drop DOLLARS_CREST;
	rename DOLLARS_REACH = DOLLARS;
run;

proc sql; 
	create table weekly_sales as
	select IRI_KEY, WEEK, SUM(DOLLARS) as SALES,
	AVG(PRICE_REACH) as AVG_PR_REACH, AVG(PRICE_ORAL) as AVG_PR_ORAL, AVG(PRICE_COLGATE) as AVG_PR_COLGATE,  AVG(PRICE_CREST) as AVG_PR_CREST,
	AVG(FEATURE_REACH) as AVG_FEAT_REACH, AVG(FEATURE_ORAL) as AVG_FEAT_ORAL, AVG(FEATURE_COLGATE) as AVG_FEAT_COLGATE,  AVG(FEATURE_CREST) as AVG_FEAT_CREST,
	AVG(DISPLAY_REACH) as AVG_DISP_REACH, AVG(DISPLAY_ORAL) as AVG_DISP_ORAL, AVG(DISPLAY_COLGATE) as AVG_DISP_COLGATE, AVG(DISPLAY_CREST) as AVG_DISP_CREST,
	AVG(PR_REACH) as AVG_PRO_REACH, AVG(PR_ORAL) as AVG_PRO_ORAL, AVG(PR_COLGATE) as AVG_PRO_COLGATE,  AVG(PR_CREST) as AVG_PRO_CREST
	from store_data 
	group by IRI_KEY, WEEK
	order by SALES desc;
quit;



/*selecting top 50 stores based on net sales*/
proc sql outobs=50;
create table weekly_sales1 as 
select iri_key, sales from weekly_sales 
order by sales desc;quit;


proc sql;
create table final1 as 
select a1.* from weekly_sales a1
inner join weekly_sales1 a2
on a1.iri_key=a2.iri_key;


/*correlation between sales and average price for Purex */
proc corr data = final1;
	var SALES AVG_PR_REACH;
run;


/*creating interaction variables*/
data final1;set final1;
INT_ORAL = AVG_FEAT_ORAL*AVG_DISP_ORAL;
INT_COLGATE = AVG_FEAT_COLGATE*AVG_DISP_COLGATE;
INT_REACH = AVG_FEAT_REACH*AVG_DISP_REACH ;
INT_CREST = AVG_FEAT_CREST*AVG_DISP_CREST;run;


/*take unique sorted data for analysis*/
proc sql;
create table final2 as
select distinct  * from final1;


proc sort data=final2 out=final3;
by iri_key week;
run;

/* random effects model */

proc panel data = final3;
	ID IRI_KEY WEEK;
	model SALES = AVG_PR_ORAL AVG_PR_COLGATE AVG_PR_REACH AVG_PR_CREST AVG_FEAT_ORAL AVG_FEAT_COLGATE AVG_FEAT_REACH AVG_FEAT_CREST
	AVG_DISP_ORAL AVG_DISP_COLGATE AVG_DISP_REACH AVG_DISP_CREST INT_ORAL INT_COLGATE INT_CREST INT_REACH / ranone;
run;

proc panel data = final3;
	ID IRI_KEY WEEK;
	model SALES = AVG_PR_ORAL AVG_PR_COLGATE AVG_PR_REACH AVG_PR_CREST AVG_FEAT_ORAL AVG_FEAT_COLGATE AVG_FEAT_REACH AVG_FEAT_CREST
	AVG_DISP_ORAL AVG_DISP_COLGATE AVG_DISP_REACH AVG_DISP_CREST INT_ORAL INT_COLGATE INT_CREST INT_REACH / rantwo;
run;

/*MDC Model*/
/*We created the data but we kept getting the same error*/
libname q1 'c:\rxk173530';

data panel(keep = PANID WEEK IRI_KEY COLUPC Income_p age_p Family_Size);set q1.panel_master;run;
proc sort data = panel;
by IRI_KEY WEEK COLUPC;run;

data sales(keep = IRI_KEY WEEK COLUPC BRAND); set q1.sales_master;run;
proc sort data = sales;
by IRI_KEY WEEK COLUPC;run;

data panel_no_f;
merge panel sales;
by IRI_KEY WEEK COLUPC; run;

proc sort data=panel_no_f;
by IRI_KEY WEEK BRAND;run;

data wtd_fdpr;set q1.wtd_sales_pr_wk_n_brnd;run;
proc sort data=wtd_fdpr;
by IRI_KEY WEEK BRAND;run;

data panel_wtd_merged;
merge panel_no_f wtd_fdpr;
by IRI_KEY WEEK BRAND;run;

data panel_wtd1(drop = COLUPC);set panel_wtd_merged;
if PANID ne .;if BRAND in ('ORAL', 'COLGATE', 'PRIVATE','REACH','CREST');
run;

proc sort data = panel_wtd1;
by PANID IRI_KEY WEEK;run;

data q1.mnl_initial;set panel_wtd1;run;

data wtd_values;set q1.wtd_sales_pr_wk_n_brnd;run;

proc transpose data = wtd_values out = wtd_avg_price prefix = PRICE_;
	by IRI_KEY WEEK;
	id BRAND;
	var avg_price;
run;


proc transpose data = wtd_values out = wtd_feat prefix = F_;
	by IRI_KEY WEEK;
	id BRAND;
	var F;
run;


proc transpose data = wtd_values out = wtd_disp prefix = D_;
	by IRI_KEY WEEK;
	id BRAND;
	var D;
run;

proc transpose data = wtd_values out = wtd_pr prefix = PR_;
	by IRI_KEY WEEK;
	id BRAND;
	var PR;
run;

/*merge all dataset*/
data wtd_data;
	merge wtd_avg_price wtd_feat wtd_disp wtd_pr;
run;

proc print data = wtd_data (obs = 10);
run;

data wtd_data_c(drop=i);                                                    
  set wtd_data;                                                            
  array testmiss(*) _numeric_;                                            
  do i = 1 to dim(testmiss);                                              
    if testmiss(i)=. then testmiss(i)=0;                                    
  end;                                                                    
run;                                                                    

data q1.wtd_weekly_br;set wtd_data_c;run;

PROC IMPORT OUT= WORK.mnl_initial 
            DATAFILE= "H:\toothbr\mnl_final.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

data mnl_initial_1(drop = Avg_Price F D PR);set mnl_initial;run;

proc sort data = mnl_initial_1;
by IRI_KEY WEEK; run;

libname q1 'c:\rxk173530';
data wtd_val; set q1.wtd_weekly_br;run;

proc sort data = wtd_val;
by IRI_KEY WEEK; run;

data mnl_merged; 
merge mnl_initial_1 wtd_val;
by IRI_KEY WEEK;run;

data mnl_merged_nn;set mnl_merged;
if PANID ne .;run;

proc sort data = mnl_merged_nn;
by PANID IRI_KEY WEEK;run;

data mnl_kk;set mnl_merged_nn;
if BRAND = 'ORAL' then CHOICE = 3;
else if BRAND = 'COLGATE' then CHOICE = 1;
else if BRAND = 'REACH' then CHOICE = 4;
else if BRAND = 'CREST' then CHOICE = 2;

data q1.mnl_kk;set mnl_kk;run;

libname q1 'c:\rxk173530';

data mnl;set q1.mnl_kk;run;

proc freq;table brand;run;

data mnl_np;set mnl;
if BRAND ne 'PRIVATE';
if PRICE_COLGATE ne 0;
if PRICE_CREST ne 0;
if PRICE_ORAL ne 0;
if PRICE_REACH ne 0;
run;

data mnl_np1(drop = PRICE_PRIVATE F_PRIVATE D_PRIVATE PR_PRIVATE);set mnl_np;
if BRAND = 'COLGATE' then CHOICE = 1;
else if BRAND = 'CREST' then CHOICE = 2;
else if BRAND = 'ORAL' then CHOICE = 3;
else if BRAND = 'REACH' then CHOICE = 4;
run;

data mnl_np2;set mnl_np1;
if F_COLGATE > 0 then F1 = 1;else F1 = 0;
if F_CREST > 0 then F2 = 1;else F2 = 0;
if F_ORAL > 0 then F3 = 1;else F3 = 0;
if F_REACH > 0 then F4 = 1;else F4 = 0;
if D_COLGATE > 0 then D1 = 1;else D1 = 0;
if D_CREST > 0 then D2 = 1;else D2 = 0;
if D_ORAL > 0 then D3 = 1;else D3 = 0;
if D_REACH > 0 then D4 = 1;else D4 = 0;
if PR_COLGATE > 0 then PR1 = 1;else PR1 = 0;
if PR_CREST > 0 then PR2 = 1;else PR2 = 0;
if PR_ORAL > 0 then PR3 = 1;else PR3 = 0;
if PR_REACH > 0 then PR4 = 1;else PR4 = 0;run;

proc surveyselect data=mnl_np2
   n=1500 out=Sample;
run;

/*2*/
data a2(keep=panid decision mode c1 c2 c3 p d f pr inc1 inc2 inc3 fam1 fam2 fam3); 
   set sample; 
   	array pvec{4} price_colgate price_crest price_oral price_reach; 
    array dvec{4} D1 - D4;
	array fvec{4} F1 - F4;
	array prvec{4} PR1 - PR4;
array s1{4}(1 0 0 0); 
array s2{4}(0 1 0 0);
array s3{4}(0 0 1 0);

   retain panid 0; 
   panid + 1; 
/*   if brand=1 then d1=1;else d1=0;
if brand=2 then d2=1;else d2=0;
if brand=3 then d3=1;else d3=0;
if brand=4 then d4=1;else d4=0;
   */
   do i = 1 to 4; 
      mode = i; 
    p = pvec{i}; 
	d = dvec{i}; 
	f = fvec{i}; 
	pr = prvec{i};
	c1 = s1{i};
	c2 = s2{i};
	c3 = s3{i};
	inc1 = income_p * c1;
	inc2 = income_p * c2;
	inc3 = income_p * c3;
	fam1 = Family_Size * c1;
	fam2 = Family_Size * c2;
	fam3 = Family_Size * c3;
      decision = ( choice = i ); 
      output; 
   end; 
run;
proc print data=a2(obs=10);run;
proc mdc data=a2; 
   model decision =p/ 
            type=clogit 
            nchoice=4
            optmethod=qn 
            covest=hess; 
   id panid; 
run;
