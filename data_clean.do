*ssc install reghdfe
*ssc install ivreghdfe
*ssc install estout, replace //安装必需的package

clear 
set more off
set type double, permanently

local dr "D:\research\Attention to inflation\code-post lzt edit\20230727"
// add your own directory here
local outdir "`dr'\output"
cd "`dr'\"


**********************************Import data 数据导入************************

//cap log close
//log using "C:\Users\Zhihao Xu\Desktop\Hyperinflation Research_Chang&Zhihao\20230130\weekly\week-frequency results.smcl"

//set more off
//set maxvar 10000
//set excelxlsxlargefile on 


*import 1947 population 导入数据1947年人口数据 
import excel "Population1947.xlsx", sheet("Sheet1") firstrow clear
save Population1947.dta, replace

*import and merge Rice and Wheat Prices from 1941.4 to 1948.11 导入并合并1941年4至1948年11月间的大米和小麦数据


import excel "RicePrice1941-1948.xlsx", sheet("Sheet1") firstrow clear
save Rice.dta, replace 

**# Bookmark #1
import excel "WheatPrice1941-1948.xlsx", sheet("Sheet1") firstrow clear
save Wheat.dta, replace


merge 1:1 Date using Rice.dta
drop _merge

sort Date
gen Num=_n //generate `time' series variable(on every day before July 1944, and on alternative days after that) 生成大米小麦面板的时序变量（1944年7月前为每日时序，7月以后隔日时序）
save RiceWheat.dta, replace


*generate the panel of rice and wheat prices and wholesale price index information 合成粮食价格和物价指数面板
import excel "Wholesale Price Indices 1945-1949.xlsx", sheet("Sheet1") firstrow clear
merge 1:1 Date using RiceWheat.dta
drop _merg
save RiceWheatWholesale.dta, replace

*generate the panel of rice and wheat prices and battle information 合成粮食价格、物价指数和通讯信息总面板
import excel "telecommunication20230610.xlsx", sheet("telecommunication") firstrow clear
merge 1:1 Date using RiceWheatWholesale.dta
drop _merge
save RiceWheatWholesaleTele.dta, replace


**************Preliminary Data Processing 数据的基本处理*************************


******************************************************恶性通胀的大图景：四大城市的批发物价指数和通胀率
gen Day=_n  //1937.7.7 as the first day 
tsset Date
gen Week=ceil((Day+3)/7) 

drop if Day<1365
drop Day
gen Day=_n
*gen RiceSH=log(Rice7) //上海大米价格对数
*gen RiceCK=log(Rice2) //重庆大米价格对数
*gen RiceCT=log(Rice3) //广州大米价格对数
*gen RiceKM=log(Rice174) //昆明大米价格对数

*gen WheatSH=log(Wheat7) //上海小麦价格对数
*gen WheatCK=log(Wheat2) //重庆小麦价格对数
*gen WheatKM=log(Wheat174) //昆明小麦价格对数

replace Shanghai=Shanghai*3000000 if Day>2700 //上海批发物价指数调整，1948年8月19日以后，为金圆券计价，1金圆=3百万法币元
replace Chungking=Chungking*3000000 if Day>2700 //重庆批发物价指数调整，1948年8月19日以后，为金圆券计价，1金圆=3百万法币元
replace Kunming=Kunming*3000000 if Day>2700 //昆明批发物价指数调整，1948年8月19日以后，为金圆券计价，1金圆=3百万法币元
replace Canton=Canton*3000000 if Day>2700 //广州批发物价指数调整，1948年8月19日以后，为金圆券计价，1金圆=3百万法币元

gen logShanghai=log(Shanghai)
gen logChungking=log(Chungking)
gen logKunming=log(Kunming)
gen logCanton=log(Canton)

gen log10Shanghai=log10(Shanghai)
gen log10Chungking=log10(Chungking)
gen log10Kunming=log10(Kunming)
gen log10Canton=log10(Canton)

gen DPiShanghai=(logShanghai-l.logShanghai)*100 //上海批发物价指数计算的日环比通胀率
gen DPiChungking=(logChungking-l.logChungking)*100 //重庆批发物价指数计算的日环比通胀率
gen DPiKunming=(logKunming-l.logKunming)*100 //昆明批发物价指数计算的日环比通胀率
gen DPiCanton=(logCanton-l.logCanton)*100 //广州批发物价指数计算的日环比通胀率

*****************************************图示：上海重庆昆明广州批发物价指数*******************************************************
/*
tw (line log10Shanghai log10Chungking log10Kunming log10Canton Date if Day>1687, sort cmissing(n n n n)), ///
   title("Wholesale Price Indices in Four Leading Cities") ///
   subtitle("1945.11-1949.4; Jan-June,1937=100 ") ///
   ytitle("Price Indices, log10 scale") xtitle("Date") ///
   legend(ring(0) pos(10) cols(1) label(1 "Shanghai") label(2 "Chungking") label(3 "Kunming") label(4 "Canton")) ///
   saving(FourCitiesWholesalePrices2)

*****************************************图示：上海重庆昆明广州批发物价计算的日环比通胀率*****************************************
tw (line DPiShanghai Date if Day>1819, sort cmissing(n)), title("Shanghai Daily Inflation Rate") ytitle("Inflation Rate") xtitle("Date") saving(ShanghaiWholesaleDailyInflation)
tw (line DPiChungking Date if Day>1687, sort cmissing(n)), title("Chungking Daily Inflation Rate") ytitle("Inflation Rate") xtitle("Date") saving(ChungkingWholesaleDailyInflation) 
tw (line DPiKunming Date if Day>2132, sort cmissing(n)), title("Kunming Daily Inflation Rate") ytitle("Inflation Rate") xtitle("Date") saving(KunmingWholesaleDailyInflation) 
tw (line DPiCanton Date if Day>2132, sort cmissing(n)), title("Canton Daily Inflation Rate") ytitle("Inflation Rate") xtitle("Date") saving(CantonWholesaleDailyInflation) 
graph combine ShanghaiWholesaleDailyInflation.gph ChungkingWholesaleDailyInflation.gph KunmingWholesaleDailyInflation.gph CantonWholesaleDailyInflation.gph,saving(FourCitiesWholesaleDailyInflation)
*/

gen month=month(Date) //month dummies
gen year=year(Date)
gen weekly=yw(year(Date), week(Date))


*reshape
reshape long Rice Wheat Uphone Lphone Rphone Tele Wless, i(Date) j(City)

*generate log values of price levels
rename Rice rice
gen logrice=log(rice)  // rice means the price level of rice

rename Wheat wheat
gen logwheat=log(wheat)

***drop pre-1943.11.19 data and the remaining data are of bi-daily frequency 剔除1943年11月19日以前的数据，此后数据较密集
*keep if Num>=635

***drop pre-1944.7 data and the remaining data are of bi-daily frequency 剔除1944年7月以前和1948年8月18日（金圆券改革）以后数据
*keep if (Num>=860)&(Num<1601)

***drop pre-1944.7 data and the remaining data are of bi-daily frequency 剔除1944年7月以前的数据，此后的为隔日统计的大米小麦价格
*keep if Num>=860  //data for pre-1944 Jul data are omitted because of low quality

drop if Num==.
xtset City Num

***seasonally adjustment using month dummies; residuals retained 做月度调整，取残差
reghdfe logrice, a(City#month) residual(rice_adj)
reghdfe logwheat, a(City#month) residual(wheat_adj)

local adjustment="Adjusted"

*** merge with population data ***
sort Num City
merge m:1 City using Population1947.dta
drop _merge

*generate province variable 生成省份变量
gen Province=0 //特别市哑变量
replace Province=1 if (City>10)&(City<25)
replace Province=2 if (City>24)&(City<43)
replace Province=3 if (City>42)&(City<58)
replace Province=4 if (City>57)&(City<78)
replace Province=5 if (City>77)&(City<94)
replace Province=6 if (City>93)&(City<112)
replace Province=7 if (City>111)&(City<155)
replace Province=8 if (City>154)&(City<158)
replace Province=9 if (City>157)&(City<170)
replace Province=10 if (City>169)&(City<183)
replace Province=11 if (City>182)&(City<202)
replace Province=12 if (City>201)&(City<217)
replace Province=13 if (City>216)&(City<232)
replace Province=14 if (City>231)&(City<243)
replace Province=15 if (City>242)&(City<249)
replace Province=16 if (City>248)&(City<263)
replace Province=17 if (City>262)&(City<268)
replace Province=18 if (City>267)&(City<279)
replace Province=19 if (City>278)&(City<289)
replace Province=20 if (City>288)&(City<292)
replace Province=21 if (City>291)&(City<299)
replace Province=22 if (City==299)
replace Province=23 if (City>299)&(City<305)
replace Province=24 if (City>304)&(City<309)
replace Province=25 if (City>308)&(City<313)
replace Province=26 if (City==313)
replace Province=27 if (City==314)

sort Date City

save processed_data.dta, replace

//erase RiceWheatWholesale.dta
//erase RiceWheatWholesaleTele.dta
//erase Rice.dta
//erase RiceWheat.dta
//erase Wheat.dta
//erase Population1947.dta



************************** end of data processing for the raw sample ***************************


//log close




















