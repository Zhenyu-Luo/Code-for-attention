clear 
set more off
set type double, permanently

//set maxvar 10000


*chang mac
local dr "/Users/cc/Library/CloudStorage/Dropbox/Research Projects/Inflation Research/Hyperinflation/Hyperinflation in China/empirical_analysis"
*chang desktop
//local dr "C:\Users\ecslicha\Dropbox\Research Projects\Inflation Research\Hyperinflation\Hyperinflation in China\empirical_analysis"
//local dr "D:\research\inflation_price converge\20230727\20230727" // add your own directory here


local outdir "`dr'/output"
cd "`dr'/data/processed"


************************** processing weekly data *****************************

// uncomment if use raw price data
/*
replace rice_adj =logrice // rice_adj seasonally adjusted, logrice raw rice data
replace wheat_adj=logwheat 
*/



**collapse and merge into weekly data


use processed_data.dta, clear

collapse Num year weekly rice logrice rice_adj wheat logwheat wheat_adj Uphone Lphone Rphone Tele Wless logShanghai logChungking logKunming logCanton Pop Province, by (City Week)

merge 1:1 Week City using War.dta
drop _merge
merge m:1 City using geocontrol.dta
drop _merge

********************



**Calculated indicators of inflation and price dispersion
drop if Week < 196
format weekly %tw

**generate a variety of average price variables and inflation rate variables without population weights **生成无人口加权的各种价格均值变量 
bysort Week: egen RiceMA=mean(rice_adj) //National mean of rice prices 
bysort Week Province: egen RiceMP=mean(rice_adj) //Provincial mean of rice prices
bysort Week: egen WheatMA=mean(wheat_adj) //National mean of rice prices 
bysort Week Province: egen WheatMP=mean(wheat_adj) //Provincial mean of wheat prices

xtset City Week

****Shanghai, Chungking, Kunming, and Canton Week Inflation Rates Calculated by Wholesale Prices
*gen BPiShanghai=(logShanghai-l.logShanghai)*100 //上海批发物价指数计算的隔日环比通胀率
*gen BPiChungking=(logChungking-l.logChungking)*100 //重庆批发物价指数计算的隔日环比通胀率
*gen BPiKunming=(logKunming-l.logKunming)*100 //昆明批发物价指数计算的隔日环比通胀率
*gen BPiCanton=(logCanton-l.logCanton)*100 //广州批发物价指数计算的隔日环比通胀率

gen RicePiC=(rice_adj-l.rice_adj)*100 //City inflation rates calculated by rice prices at the city level
gen RicePiA=(RiceMA -l.RiceMA)*100 //National inflation rate calculated by national mean of rice prices
gen RicePiP=(RiceMP -l.RiceMP)*100 //Provincial inflation rates calculated by provincial mean of rice prices

gen RiceDMA=rice_adj-RiceMA //City rice price deviations from the national mean
gen RiceDMP=rice_adj-RiceMP //City rice price deviations from the provincial mean
//gen RiceDMPA=RiceMP-RiceMA //Provincial rice price mean deviations from the national mean


gen WheatPiC=(wheat_adj-l.wheat_adj)*100 //City inflation rates calculated by wheat prices at the city level
gen WheatPiA=(WheatMA -l.WheatMA)*100 //National inflation rate calculated by national mean of wheat prices
gen WheatPiP=(WheatMP -l.WheatMP)*100 //Provincial inflation rates calculated by provincial mean of wheat prices

gen WheatDMA=wheat_adj-WheatMA //City wheat price deviations from the national mean
gen WheatDMP=wheat_adj-WheatMP //City wheat price deviations from the provincial mean
//gen WheatDMPA=WheatMP-WheatMA //Provincial wheat price mean deviations from the national mean



**generate a variety of average price variables and inflation rate variables with population weights 生成人口加权的各种价格均值变量和通胀率变量 
gen RicePop=Pop*(rice_adj!=.) //生成当大米价格存在时的人口变量
replace RicePop=. if RicePop==0

gen WheatPop=Pop*(wheat_adj!=.) //生成当小麦价格存在时的人口变量
replace WheatPop=. if WheatPop==0

bysort Week: egen AllPop=sum(Pop) //生成总人口变量
replace AllPop=. if AllPop==0

bysort Week: egen AllRicePop=sum(RicePop) //生成当大米价格存在时的全国总人口变量
replace AllRicePop=. if AllRicePop==0

bysort Week: egen AllWheatPop=sum(WheatPop) //生成当小麦价格存在时的全国总人口变量
replace AllWheatPop=. if AllWheatPop==0


gen AllPWRice = RicePop/ AllRicePop*rice_adj //生成当大米价格存在时按各县占全国人口比重加权的大米价格
replace AllPWRice =. if AllPWRice==0

gen AllPWWheat = WheatPop/ AllWheatPop*wheat_adj //生成当小麦价格存在时按各县占全国人口比重加权的小麦价格
replace AllPWWheat =. if AllPWWheat==0


*** construct population weighted average prices 
bysort Week: egen PWRiceMA=sum(AllPWRice) //生成当大米价格存在时按人口比重加权的全国平均大米价格
replace PWRiceMA=. if PWRiceMA==0
bysort Week: egen PWWheatMA=sum(AllPWWheat) //生成当小麦价格存在时按人口比重加权的全国平均小麦价格
replace PWWheatMA=. if PWWheatMA==0


xtset City Week


gen PWRicePiA=(PWRiceMA - l.PWRiceMA)*100 //National inflation rate calculated by national mean of population-weighted rice prices
gen PWWheatPiA=(PWWheatMA - l.PWWheatMA)*100 //National inflation rate calculated by national mean of population-weighted wheat prices

gen PWRiceDMA=rice_adj-PWRiceMA //Population-weighted city rice price deviations from the national mean
gen PWWheatDMA=wheat_adj-PWWheatMA //Population-weighted city wheat price deviations from the national mean


*** absolute value
gen abs_rice_pi =abs(PWRicePiA) //absolute value of PWRicePiA, weighted wow national rice inflation 
gen abs_wheat_pi=abs(PWWheatPiA) //absolute value of PWWheatPiA



/*
// province level

bysort Week Province: egen ProvinceRicePop=sum(RicePop) //生成当大米价格存在时的各省总人口变量
replace ProvinceRicePop=. if ProvinceRicePop==0

bysort Week Province: egen ProvinceWheatPop=sum(WheatPop) //生成当小麦价格存在时的各省总人口变量
replace ProvinceWheatPop=. if ProvinceWheatPop==0

gen ProvincePWRice = RicePop/ ProvinceRicePop*rice_adj //生成当大米价格存在时按各县占所在省人口比重加权的大米价格
replace ProvincePWRice =. if ProvincePWRice==0

gen ProvincePWWheat = WheatPop/ ProvinceWheatPop*wheat_adj //生成当小麦价格存在时按各县占所在省人口比重加权的小麦价格
replace ProvincePWWheat =. if ProvincePWWheat==0

bysort Week Province: egen PWRiceMP=sum(ProvincePWRice) //生成当大米价格存在时按人口比重加权的省内平均大米价格
replace PWRiceMP=. if PWRiceMP==0
bysort Week Province: egen PWWheatMP=sum(ProvincePWWheat) //生成当小麦价格存在时按人口比重加权的省内平均小麦价格
replace PWWheatMP=. if PWWheatMP==0


gen PWRiceMPO=PWRiceMP-ProvincePWRice
replace PWRiceMPO=. if PWRiceMPO==0
gen PWWheatMPO=PWWheatMP-ProvincePWWheat
replace PWWheatMPO=. if PWWheatMPO==0

gen PWRicePiP=(PWRiceMP - l.PWRiceMP)*100 //Provincial inflation rates calculated by provincial mean of population-weighted rice prices
gen PWWheatPiP=(PWWheatMP - l.PWWheatMP)*100 //Provincial inflation rates calculated by provincial mean of population-weighted wheat prices

gen PWRiceDMP=rice_adj-PWRiceMP //Population-weighted city rice price deviations from the provincial mean
gen PWWheatDMP=wheat_adj-PWWheatMP //Population-weighted city wheat price deviations from the provincial mean

gen PWRiceDMAO=PWRiceMPO-PWRiceMA 
gen PWWheatDMAO=PWWheatMPO-PWWheatMA 

*/




**generate rice and wheat price dispersion variables  

bysort Week: egen RiceADisp=sd(rice_adj) //Rice price dispersion at national level 
bysort Week: egen WheatADisp=sd(wheat_adj) //Wheat price dispersion at national level 

bysort Province Week: egen RicePDisp=sd(rice_adj) //Rice price dispersion at provincial level use processed_data.dta, clear
bysort Province Week: egen WheatPDisp=sd(wheat_adj) //Wheat price dispersion at provincial level


*** yoy inflation rates

xtset City Week
gen RicePiA_52= 100 * (exp(RiceMA-l52.RiceMA) - 1) //National inflation rate calculated by national mean of rice prices and their 52-week lags
gen WheatPiA_52=100 * (exp(WheatMA-l52.WheatMA) - 1) //National inflation rate calculated by national mean of wheat prices and their 52-week lags
gen PWRicePiA_52=100 * (exp(PWRiceMA -l52.PWRiceMA) - 1) //National inflation rate calculated by national mean of population-weighted rice prices and their 52-week lags
gen PWWheatPiA_52=100 * (exp(PWWheatMA -l52.PWWheatMA) - 1) //National inflation rate calculated by national mean of population-weighted wheat prices and their 52-week lags

gen RicePiC_52 = 100 * (exp(rice_adj  -l52.rice_adj) - 1)  //city-level yoy inflation
gen WheatPiC_52= 100 * (exp(wheat_adj -l52.wheat_adj) - 1) // city-level yoy inflation 

** calculate wholesale prices for some big cities
gen wholesale_sh=100 * (exp(logShanghai-l52.logShanghai) - 1)
gen wholesale_ck=100 * (exp(logChungking - l52.logChungking) - 1)


******** other control variables *********

gen rice20t = suit_rice_20 * Week  // suitability for growing rice 
gen wheat20t = suit_wheat_20 * Week // suitability for growing wheat


/*
***************the impact of communication across cities on price convergence ************

gen communication = 1 if Uphone==1 | Lphone==1 | Rphone==1 | Tele==1
replace communication = 0 if communication==.
replace communication = . if Uphone==. & Lphone==. & Rphone==. & Tele==.
*/



***********************************************************************************************
************************************************ graphs ***************************************
***********************************************************************************************


** one-year wholesale inflation rate v.s. rice and wheat for shanghai and chungking
twoway line wholesale_sh  weekly if Week>470 & Week<581  & City==7, clcolor(black) clpattern(solid) clwidth(medthick)  || ///
       line RicePiC_52    weekly if Week>470 & Week<581 & City==7, clcolor(gray) clpattern(dash) clwidth(medthick)  || ///
       line WheatPiC_52   weekly if Week>470 & Week<581 & City==7, clcolor(blue) clpattern(dot) clwidth(medthick)  ||, ///
 xtitle("Date", size(large)) ytitle("YoY Inflation (%)", size(large))   legend( label (1 "Wholesale") label (2 "Rice")  label (3 "Wheat") cols(1) region(lwidth(none)) ring(0) pos(10)) title("Inflation in Shanghai") ///
 graphregion(color(white)) ///
 yscale(log) ylabel(100 "10^2" 1000 "10^3" 10000 "10^4" , angle(0))
 graph export "`outdir'/shanghai_pi.eps", replace
 *470 is 1946w26, for the sake of graphs
 
 
 twoway line wholesale_ck  weekly if Week>470  & Week<581 & City==2, clcolor(black) clpattern(solid) clwidth(medthick)  || ///
       line RicePiC_52    weekly  if Week>470  & Week<581 & City==2, clcolor(gray) clpattern(dash) clwidth(medthick)  || ///
       line WheatPiC_52   weekly  if Week>470  & Week<581 & City==2, clcolor(blue) clpattern(dot) clwidth(medthick)  ||, ///
 xtitle("Date", size(large)) ytitle("YoY Inflation (%)", size(large))   legend( off) title("Inflation in Chungking") ///
 graphregion(color(white))
 graph export "`outdir'/chungking_pi.eps", replace
  *470 is 1946w26, for the sake of graphs


** year-over-year aggregate inflation rate, population weighted 
twoway line PWRicePiA_52  weekly  if Week > 235 & Week < 565 & City==1, clcolor(black) clpattern(solid) clwidth(medthick)  || ///
       line PWWheatPiA_52 weekly  if Week > 235 & Week < 565 & City==1, clcolor(gray) clpattern(solid) clwidth(medthick) ||, ///
 xtitle("Date", size(large)) ytitle("YoY Inflation (%)", size(large))   legend( label (1 "Rice") label (2 "Wheat")  cols(2)) ///
 xline(-749, lpattern(dash) lcolor(red)) /// 黑色虚线
 graphregion(color(white)) xlabel(-936(52)-624, angle(0)) yline(100, lpattern(dash) lcolor(gs8))
 graph export "`outdir'/inflation_yearly.eps", replace

** week over week inflation rate, population weighted 
twoway line PWRicePiA  weekly if Week>365  & City==1, clcolor(black) clpattern(solid) clwidth(medthick)  || ///
       line PWWheatPiA weekly if Week>365  & City==1, clcolor(gray) clpattern(solid) clwidth(medthick) ||, ///
 xtitle("Date", size(large)) ytitle("WoW Inflation (%)", size(large))   legend( label (1 "Rice") label (2 "Wheat")  cols(2)) ///
 graphregion(color(white))
 graph export "`outdir'/inflation_weekly.eps", replace
 
 
 ** raw plots of price dispersion and inflation 
 
/* 
twoway (scatter RiceADisp PWRicePiA if Week>365 & Week<581 & City==1 & PWRicePiA >-50 & PWRicePiA <50,   ms(oh) mc(black) mlwidth(thin) ) (lfit RiceADisp PWRicePiA if Week>365 & Week<581 & City==1 & PWRicePiA >-50 & PWRicePiA <50, clcolor(black) clpattern(solid) clwidth(medium)), xtitle("Inflation (%)", size(large)) ytitle("Dispersion", size(large)) legend(off) title("Rice Price Dispersion")  ///
graphregion(color(white))
graph export "`outdir'/rice_disp_fit.eps", replace
 
 
 twoway scatter RiceADisp PWRicePiA if Week>365 & Week<581 & City==1 & PWRicePiA >-50 & PWRicePiA <50,   ms(oh) mc(black) mlwidth(thin) xtitle("Inflation (%)", size(large)) ytitle("Dispersion", size(large)) legend(off) title("Rice Price Dispersion")  ///
 graphregion(color(white))
 graph export "`outdir'/rice_disp.eps", replace
 
 
twoway (scatter WheatADisp PWWheatPiA if Week>365 & Week<581 & City==1 & PWWheatPiA>-20, ms(oh) mc(black) mlwidth(thin) ) (lfit WheatADisp PWWheatPiA if Week>365 & Week<581 & City==1 & PWWheatPiA>-20, clcolor(black) clpattern(solid) clwidth(medium)), xtitle("Inflation (%)", size(large)) ytitle("Dispersion", size(large)) legend(off) title("Wheat Price Dispersion")  ///
graphregion(color(white))
graph export "`outdir'/wheat_disp_fit.eps", replace
 

twoway scatter WheatADisp PWWheatPiA if Week>365 & Week<581 & City==1 & PWWheatPiA>-20 , ms(oh) mc(black) mlwidth(thin) xtitle("Inflation (%)", size(large)) ytitle("Dispersion", size(large)) legend(off) title("Wheat Price Dispersion") ///
 graphregion(color(white))
 graph export "`outdir'/wheat_disp.eps", replace
 
 */
 
 ** a simple test of the relationship between price dispersion and inflation
/*
eststo clear

eststo: reg RiceADisp  l.RiceADisp  PWRicePiA  if City==1   // nationwide dispersion v.s. weighted nationwide inflation
eststo: reg RiceADisp  l.RiceADisp  RicePiA  if City==1   // nationwide dispersion v.s. unweighted nationwide inflation
eststo: reg WheatADisp l.WheatADisp PWWheatPiA if City==1  // nationwide dispersion v.s. weighted nationwide inflation
eststo: reg WheatADisp l.WheatADisp WheatPiA if City==1  // nationwide dispersion v.s. unweighted nationwide inflation

esttab using "`outdir'/disp_national.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{disp_national}) ///
 mtitles("rice" "rice unweighted"  "wheat" "wheat unweighted") replace
*/


** making plots based on the regression above

*** rice
reg RiceADisp  l.RiceADisp  PWRicePiA  if City==1
gen dispersion_gap = RiceADisp - _b[l.RiceADisp]*l.RiceADisp

/*
** all sample
twoway (scatter dispersion_gap PWRicePiA if City==1 ,   ms(oh) mc(black) mlwidth(thin) ) (lfit dispersion_gap PWRicePiA if City==1, clcolor(black) clpattern(solid) clwidth(medium)), xtitle("Inflation (%)", size(large)) ytitle("Price Dispersion", size(large)) legend(off) title("Rice Price Dispersion")  ///
graphregion(color(white))
graph export "`outdir'/rice_disp_fit.eps", replace


**  1944.7-1948.8, remove outlier
twoway (scatter dispersion_gap PWRicePiA if City==1 & Week>365 & Week<581 & PWRicePiA >-50 & PWRicePiA <50,   ms(oh) mc(black) mlwidth(thin) ) (lfit dispersion_gap PWRicePiA if City==1 & Week>365 & Week<581 & PWRicePiA >-50 & PWRicePiA <50 , clcolor(black) clpattern(solid) clwidth(medium)), xtitle("Inflation (%)", size(large)) ytitle("Price Dispersion", size(large)) legend(off) title("Rice Price Dispersion")  ///
graphregion(color(white))
graph export "`outdir'/rice_disp_fit.eps", replace

*/


** 1944.7 - 1948.8
twoway (scatter dispersion_gap PWRicePiA if City==1 & Week>365 & Week<581,   ms(oh) mc(black) mlwidth(thin) ) (lfit dispersion_gap PWRicePiA if City==1 & Week>365 & Week<581, clcolor(black) clpattern(solid) clwidth(medium)), xtitle("Inflation (%)", size(large)) ytitle("Price Dispersion", size(large)) legend(off) title("Rice Price Dispersion")  ///
graphregion(color(white))
graph export "`outdir'/rice_disp_fit.eps", replace


*** Wheat
reg WheatADisp  l.WheatADisp  PWWheatPiA  if City==1
replace dispersion_gap = WheatADisp - _b[l.WheatADisp]*l.WheatADisp



/*
** all sample
twoway (scatter dispersion_gap PWWheatPiA if City==1 ,   ms(oh) mc(black) mlwidth(thin) ) (lfit dispersion_gap PWWheatPiA if City==1, clcolor(black) clpattern(solid) clwidth(medium)), xtitle("Inflation (%)", size(large)) ytitle("Price Dispersion", size(large)) legend(off) title("Wheat Price Dispersion")  ///
graphregion(color(white))
graph export "`outdir'/wheat_disp_fit.eps", replace



**  1944.7-1948.8, remove outlier (-50 -- 50 )
twoway (scatter dispersion_gap PWWheatPiA if City==1 & Week>365 & Week<581 & PWWheatPiA >-50 & PWWheatPiA <50,   ms(oh) mc(black) mlwidth(thin) ) (lfit dispersion_gap PWWheatPiA if City==1 & Week>365 & Week<581 & PWWheatPiA >-50 & PWWheatPiA <50, clcolor(black) clpattern(solid) clwidth(medium)), xtitle("Inflation (%)", size(large)) ytitle("Price Dispersion", size(large)) legend(off) title("Wheat Price Dispersion")  ///
graphregion(color(white))
graph export "`outdir'/wheat_disp_fit.eps", replace
*/


**  1944.7-1948.8
twoway (scatter dispersion_gap PWWheatPiA if City==1 & Week>365 & Week<581,   ms(oh) mc(black) mlwidth(thin) ) (lfit dispersion_gap PWWheatPiA if City==1 & Week>365 & Week<581, clcolor(black) clpattern(solid) clwidth(medium)), xtitle("Inflation (%)", size(large)) ytitle("Price Dispersion", size(large)) legend(off) title("Wheat Price Dispersion")  ///
graphregion(color(white))
graph export "`outdir'/wheat_disp_fit.eps", replace

 


***********************************************************************************************
******************************************  Tables  *******************************************
***********************************************************************************************

 
/*baseline result*/
//Note:City fixed effect, clustered Province, using 20km buffer to calculate control variables

eststo clear
*rice
eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d ///
c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway, ///
a(City Week) cluster(Province)   
   
eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway if Week>286, a(City Week) cluster(Province)  
 
eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway if Week>365, a(City Week) cluster(Province)  
 
eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway if Week>365 & Week<581, a(City Week) cluster(Province)   

*wheat
eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d ///
c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway, ///
a(City Week) cluster(Province) 

eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway if Week>286, a(City Week) cluster(Province) 

eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway if Week>365, a(City Week) cluster(Province) 

eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway if Week>365 & Week<581, a(City Week) cluster(Province) 

esttab using "`outdir'/baseline_clp.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(2) title( \label{baseline_clp}) ///
 mtitles("All"">1942.12" ">1944.7" "1944.7-1948.8" "" "" "" "" ) replace 



 
/*Table 4*/
//Note:Province fixed effect, clustered City, using 20km buffer to calculate control variables

eststo clear
* rice 
eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway, a(Province Week) cluster(City)

eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway if Week>286, a(Province Week) cluster(City) 
  
eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway if Week>365, a(Province Week) cluster(City)   

eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway if Week>365 & Week<581, a(Province Week) cluster(City)   

*wheat
eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway, a(Province Week) cluster(City)

eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway if Week>286, a(Province Week) cluster(City) 

eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway if Week>365, a(Province Week) cluster(City)

eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway if Week>365 & Week<581, a(Province Week) cluster(City) 

esttab using "`outdir'/baseline_clc.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(2) title( \label{baseline_clc}) ///
 mtitles("All"">1942.12" ">1944.7" "1944.7-1948.8" "" "" "" "" ) replace

 
 
/*Table 5*/
/*IV result*/
//Note:clustered at Province level, using 50km buffer to calculate control variables
//tab Week, generate(Wk)
//mata: mata set matafavor speed, perm
//xtabond2 PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway Wk*, ///
//gmm(l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d, lag(2 3) eq(diff)) ///
//cluster(Province)
//xtabond2 PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway Wk* if Week > 286, ///
//gmm(l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d, lag(3 3) eq(diff)) ///
//cluster(Province)
//xtabond2 PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway Wk* if Week > 365, ///
//gmm(l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d, lag(4 4) eq(diff)) ///
//cluster(Province)
//xtabond2 PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway Wk* if Week>365 & Week<581, ///
//gmm(l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d, lag(3 3) eq(diff)) ///
//cluster(Province)


//xtabond2 PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway Wk*, ///
//gmm(l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d, lag(3 4) eq(diff)) ///
//cluster(Province)
//xtabond2 PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway Wk* if Week > 286, ///
//gmm(l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d, lag(4 5) eq(diff)) ///
//cluster(Province)
//xtabond2 PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway Wk* if Week > 365, ///
//gmm(l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d, lag(4 4) eq(diff)) ///
//cluster(Province)
//xtabond2 PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway Wk* if Week>365 & Week<581, ///
//gmm(l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d, lag(3 3) eq(diff)) ///
//cluster(Province)

//ds
//local prefix = "WK"
//foreach var of varlist * {
//    if regexm("`var'", "^`prefix'") {
//        drop `var'
//    }
//}



/*Table 6*/
/*Inflation-square Robust Result*/
//Note:clustered at Province level, using 50km buffer to calculate control variables
gen PWWheatPiA2 = PWWheatPiA*PWWheatPiA
gen PWRicePiA2 = PWRicePiA*PWRicePiA

eststo clear
*rice
eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.PWRicePiA2 c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway,  a(City Week) cluster(Province) 
     
eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.PWRicePiA2 c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway if Week>286, a(City Week) cluster(Province)  
 
eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.PWRicePiA2 c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway if Week>365, a(City Week) cluster(Province)  
 
eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.PWRicePiA2 c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway if Week>365 & Week<581, a(City Week) cluster(Province)  

*wheat
eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.PWWheatPiA2 c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway, a(City Week) cluster(Province) 

eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.PWWheatPiA2 c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway if Week>286, a(City Week) cluster(Province) 

eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.PWWheatPiA2 c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway if Week>365, a(City Week) cluster(Province) 

eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.PWWheatPiA2 c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway if Week>365 & Week<581, a(City Week) cluster(Province) 

esttab using "`outdir'/inflation square.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(2) title(\label{inflation square}) ///
 mtitles("All"">1942.12" ">1944.7" "1944.7-1948.8" "" "" "" ""  ) replace

 
 
/*Table 7*/
/*Missing Rate Robust*/
//Note:clustered at Province level, using 50km buffer to calculate control variables


**generate missing rate
**生成缺失比率变量
//Note:在其中标注了说明：为什么要这么写
gen rice_missing = 0
replace rice_missing = 1 if rice == .
bysort City: egen misrice_period01 = mean(rice_missing) 
bysort City: egen misrice_period0 = mean( misrice_period01 )
drop misrice_period01

//Note:下面第一行能生成在我们规定的范围内计算的缺失比率，但是只会在"Week>286"的部分后面生成这个新数据，而第二行就是使得这个值可以在这个城市的所有时间后铺开
bysort City: egen misrice_period11 = mean(rice_missing) if Week>286
bysort City: egen misrice_period1 = mean( misrice_period11 )
drop misrice_period11
bysort City: egen misrice_period22 = mean(rice_missing) if Week>365
bysort City: egen misrice_period2 = mean( misrice_period22 )
drop misrice_period22 
bysort City: egen misrice_period33 = mean(rice_missing) if Week>365 & Week<581
bysort City: egen misrice_period3 = mean( misrice_period33 )
drop misrice_period33

gen wheat_missing = 0
replace wheat_missing = 1 if wheat == .
bysort City: egen miswheat_period01 = mean(wheat_missing) 
bysort City: egen miswheat_period0 = mean( miswheat_period01 )
drop miswheat_period01
bysort City: egen miswheat_period11 = mean(wheat_missing) if Week>286
bysort City: egen miswheat_period1 = mean( miswheat_period11 )
drop miswheat_period11
bysort City: egen miswheat_period22 = mean(wheat_missing) if Week>365
bysort City: egen miswheat_period2 = mean( miswheat_period22 )
drop miswheat_period22 
bysort City: egen miswheat_period33 = mean(wheat_missing) if Week>365 & Week<581
bysort City: egen miswheat_period3 = mean( miswheat_period33 )
drop miswheat_period33

drop rice_missing wheat_missing



sort City Week
eststo clear  // using missing rate <= 0.8 as a bar
*rice
eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if misrice_period0 <= 0.8 ,  a(City Week) cluster(Province) 
     
eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t  c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if misrice_period1 <= 0.8 &Week>286 ,  a(City Week) cluster(Province)   

eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if misrice_period2 <= 0.8 &Week>365 ,  a(City Week) cluster(Province)   

eststo: reghdfe PWRiceDMA l.PWRiceDMA c.l.PWRiceDMA#c.PWRicePiA c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if misrice_period3 <= 0.8 &Week>365 & Week<581 ,  a(City Week) cluster(Province)  

*wheat
eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway  if misrice_period0 <= 0.8, a(City Week) cluster(Province) 

eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway if misrice_period1 <= 0.8 &Week>286 , a(City Week) cluster(Province) 

eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway if misrice_period2 <= 0.8 &Week>365 , a(City Week) cluster(Province) 

eststo: reghdfe PWWheatDMA l.PWWheatDMA c.l.PWWheatDMA#c.PWWheatPiA c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway if misrice_period3 <= 0.8 &Week>365 & Week<581, a(City Week) cluster(Province) 

esttab using "`outdir'/missing robust.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(2) title( \label{missing robust}) ///
 mtitles("All"">1942.12" ">1944.7" "1944.7-1948.8" "" "" "" "" ) replace


 
 
/*Table 8*/
/*Unweighted Robust*/


eststo clear
*rice 
eststo: reghdfe RiceDMA l.RiceDMA c.l.RiceDMA#c.RicePiA c.l.RiceDMA#c.War_W0_50_d c.l.RiceDMA#c.rug_20 c.l.RiceDMA#c.river_20 rice20t c.l.RiceDMA#c.treaty c.l.RiceDMA#c.coast c.l.RiceDMA#c.railway,  a(City Week) cluster(Province)      

eststo: reghdfe RiceDMA l.RiceDMA c.l.RiceDMA#c.RicePiA c.l.RiceDMA#c.War_W0_50_d c.l.RiceDMA#c.rug_20 c.l.RiceDMA#c.river_20 rice20t c.l.RiceDMA#c.treaty c.l.RiceDMA#c.coast c.l.RiceDMA#c.railway if Week>286,  a(City Week) cluster(Province)   

eststo: reghdfe RiceDMA l.RiceDMA c.l.RiceDMA#c.RicePiA c.l.RiceDMA#c.War_W0_50_d c.l.RiceDMA#c.rug_20 c.l.RiceDMA#c.river_20 rice20t c.l.RiceDMA#c.treaty c.l.RiceDMA#c.coast c.l.RiceDMA#c.railway if Week>365,  a(City Week) cluster(Province)   

eststo: reghdfe RiceDMA l.RiceDMA c.l.RiceDMA#c.RicePiA c.l.RiceDMA#c.War_W0_50_d c.l.RiceDMA#c.rug_20 c.l.RiceDMA#c.river_20 rice20t c.l.RiceDMA#c.treaty c.l.RiceDMA#c.coast c.l.RiceDMA#c.railway if Week>365 & Week<581,  a(City Week) cluster(Province)  

*wheat
eststo: reghdfe WheatDMA l.WheatDMA c.l.WheatDMA#c.WheatPiA c.l.WheatDMA#c.War_W0_50_d c.l.WheatDMA#c.rug_20 c.l.WheatDMA#c.river_20 wheat20t c.l.WheatDMA#c.treaty c.l.WheatDMA#c.coast c.l.WheatDMA#c.railway , a(City Week) cluster(Province) 

eststo: reghdfe WheatDMA l.WheatDMA c.l.WheatDMA#c.WheatPiA c.l.WheatDMA#c.War_W0_50_d c.l.WheatDMA#c.rug_20 c.l.WheatDMA#c.river_20 wheat20t c.l.WheatDMA#c.treaty c.l.WheatDMA#c.coast c.l.WheatDMA#c.railway if Week>286, a(City Week) cluster(Province) 

eststo: reghdfe WheatDMA l.WheatDMA c.l.WheatDMA#c.WheatPiA c.l.WheatDMA#c.War_W0_50_d c.l.WheatDMA#c.rug_20 c.l.WheatDMA#c.river_20 wheat20t c.l.WheatDMA#c.treaty c.l.WheatDMA#c.coast c.l.WheatDMA#c.railway if Week>365, a(City Week) cluster(Province) 

eststo: reghdfe WheatDMA l.WheatDMA c.l.WheatDMA#c.WheatPiA c.l.WheatDMA#c.War_W0_50_d c.l.WheatDMA#c.rug_20 c.l.WheatDMA#c.river_20 wheat20t c.l.WheatDMA#c.treaty c.l.WheatDMA#c.coast c.l.WheatDMA#c.railway if Week>365 & Week<581, a(City Week) cluster(Province) 

esttab using "`outdir'/unweighted.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(2) title( \label{unweighted}) ///
 mtitles("All"">1942.12" ">1944.7" "1944.7-1948.8" "" "" "" "" ) replace


 
/*Table 9*/
/* Classification based on Gradient Distance to metropolis */
//Note: 这个表是按照距离到直辖市的距离，将所有城市分为三类，看前面的回归在这三类城市中效果分别如何

merge n:n City using neardirect.dta //this is a dta with nearest metropolis' name and distance.
drop _merge
xtset City Week
egen neardirect_percentile1 = pctile(neardirect),p(33.33)
egen neardirect_percentile2 = pctile(neardirect),p(66.67)

**generate a indicator about groups divided by the distance to nearest metropolis
gen dis_indicator = 0
replace dis_indicator = 1 if neardirect <= neardirect_percentile1
replace dis_indicator = 2 if neardirect > neardirect_percentile1 & neardirect <= neardirect_percentile2
replace dis_indicator = 3  if neardirect > neardirect_percentile2


******
eststo clear

*rice
eststo: reghdfe PWRiceDMA l.PWRiceDMA  c.l.PWRiceDMA#c.PWRicePiA  c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if Week>365 & Week < 581 & dis_indicator == 1 , a(City Week) cluster(Province) // near

eststo: reghdfe PWRiceDMA l.PWRiceDMA  c.l.PWRiceDMA#c.PWRicePiA  c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if Week>365 & Week < 581 & dis_indicator == 2 , a(City Week) cluster(Province) // medium

eststo: reghdfe PWRiceDMA l.PWRiceDMA  c.l.PWRiceDMA#c.PWRicePiA  c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if Week>365 & Week < 581 & dis_indicator == 3 , a(City Week) cluster(Province) // far



*wheat
eststo: reghdfe PWWheatDMA l.PWWheatDMA  c.l.PWWheatDMA#c.PWWheatPiA  c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway  if Week>365 & Week < 581 & dis_indicator == 1 , a(City Week) cluster(Province) // near 

eststo: reghdfe PWWheatDMA l.PWWheatDMA  c.l.PWWheatDMA#c.PWWheatPiA  c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway  if Week>365 & Week < 581 & dis_indicator == 2 , a(City Week) cluster(Province) // medium 

eststo: reghdfe PWWheatDMA l.PWWheatDMA  c.l.PWWheatDMA#c.PWWheatPiA  c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway  if Week>365 & Week < 581 & dis_indicator == 3 , a(City Week) cluster(Province) // far

esttab using "`outdir'/distance_national.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(2) title( \label{distance_national}) ///
 mtitles( "Near" "Medium" "Distant" "Near" "Medium" "Distant" ) replace



/* before organizing*/

/*
**0-33%near metropolis cluster P
eststo clear

eststo: reghdfe PWRiceDMA l.PWRiceDMA  c.l.PWRiceDMA#c.PWRicePiA  c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway if dis_indicator == 1 , a(City Week) cluster(Province)   

eststo: reghdfe PWRiceDMA l.PWRiceDMA  c.l.PWRiceDMA#c.PWRicePiA  c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if Week>286 & dis_indicator == 1, a(City Week) cluster(Province)  
   
eststo: reghdfe PWRiceDMA l.PWRiceDMA  c.l.PWRiceDMA#c.PWRicePiA  c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if Week>365 & dis_indicator == 1, a(City Week) cluster(Province)   
  
eststo: reghdfe PWRiceDMA l.PWRiceDMA  c.l.PWRiceDMA#c.PWRicePiA  c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if Week>365 & Week < 581 & dis_indicator == 1 , a(City Week) cluster(Province)     

eststo: reghdfe PWWheatDMA l.PWWheatDMA  c.l.PWWheatDMA#c.PWWheatPiA  c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway if dis_indicator == 1 , a(City Week) cluster(Province) 

eststo: reghdfe PWWheatDMA l.PWWheatDMA  c.l.PWWheatDMA#c.PWWheatPiA  c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway  if Week>286 & dis_indicator == 1, a(City Week) cluster(Province)   
  
eststo: reghdfe PWWheatDMA l.PWWheatDMA  c.l.PWWheatDMA#c.PWWheatPiA  c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway  if Week>365 & dis_indicator == 1, a(City Week) cluster(Province) 

eststo: reghdfe PWWheatDMA l.PWWheatDMA  c.l.PWWheatDMA#c.PWWheatPiA  c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway  if Week>365 & Week < 581 & dis_indicator == 1 , a(City Week) cluster(Province)     

esttab using "33% near metropolis cluster P.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("All"">1942.12" ">1944.7" "1944.7-1948.8" "" "" "" "" ) replace

**33%-67%near metropolis cluster P
eststo clear
eststo: reghdfe PWRiceDMA l.PWRiceDMA  c.l.PWRiceDMA#c.PWRicePiA  c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway if dis_indicator == 2 , a(City Week) cluster(Province)   
eststo: reghdfe PWRiceDMA l.PWRiceDMA  c.l.PWRiceDMA#c.PWRicePiA  c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if Week>286 & dis_indicator == 2, a(City Week) cluster(Province)     
eststo: reghdfe PWRiceDMA l.PWRiceDMA  c.l.PWRiceDMA#c.PWRicePiA  c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if Week>365 & dis_indicator == 2, a(City Week) cluster(Province)     
eststo: reghdfe PWRiceDMA l.PWRiceDMA  c.l.PWRiceDMA#c.PWRicePiA  c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if Week>365 & Week < 581 & dis_indicator == 2 , a(City Week) cluster(Province)     

eststo: reghdfe PWWheatDMA l.PWWheatDMA  c.l.PWWheatDMA#c.PWWheatPiA  c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway if dis_indicator == 2 , a(City Week) cluster(Province) 
eststo: reghdfe PWWheatDMA l.PWWheatDMA  c.l.PWWheatDMA#c.PWWheatPiA  c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway  if Week>286 & dis_indicator == 2, a(City Week) cluster(Province)     
eststo: reghdfe PWWheatDMA l.PWWheatDMA  c.l.PWWheatDMA#c.PWWheatPiA  c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway  if Week>365 & dis_indicator == 2, a(City Week) cluster(Province) 
eststo: reghdfe PWWheatDMA l.PWWheatDMA  c.l.PWWheatDMA#c.PWWheatPiA  c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway  if Week>365 & Week < 581 & dis_indicator == 2 , a(City Week) cluster(Province)     

esttab using "33%-67% near metropolis cluster P.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("All"">1942.12" ">1944.7" "1944.7-1948.8" "" "" "" "" ) replace

**67%-100%near metropolis cluster P
eststo clear
eststo: reghdfe PWRiceDMA l.PWRiceDMA  c.l.PWRiceDMA#c.PWRicePiA  c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway if dis_indicator == 3 , a(City Week) cluster(Province)   
eststo: reghdfe PWRiceDMA l.PWRiceDMA  c.l.PWRiceDMA#c.PWRicePiA  c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if Week>286 & dis_indicator == 3, a(City Week) cluster(Province)     
eststo: reghdfe PWRiceDMA l.PWRiceDMA  c.l.PWRiceDMA#c.PWRicePiA  c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if Week>365 & dis_indicator == 3, a(City Week) cluster(Province)     
eststo: reghdfe PWRiceDMA l.PWRiceDMA  c.l.PWRiceDMA#c.PWRicePiA  c.l.PWRiceDMA#c.War_W0_50_d c.l.PWRiceDMA#c.rug_20 c.l.PWRiceDMA#c.river_20 rice20t c.l.PWRiceDMA#c.treaty c.l.PWRiceDMA#c.coast c.l.PWRiceDMA#c.railway  if Week>365 & Week < 581 & dis_indicator == 3 , a(City Week) cluster(Province)     

eststo: reghdfe PWWheatDMA l.PWWheatDMA  c.l.PWWheatDMA#c.PWWheatPiA  c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway if dis_indicator == 3 , a(City Week) cluster(Province) 
eststo: reghdfe PWWheatDMA l.PWWheatDMA  c.l.PWWheatDMA#c.PWWheatPiA  c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway  if Week>286 & dis_indicator == 3, a(City Week) cluster(Province)     
eststo: reghdfe PWWheatDMA l.PWWheatDMA  c.l.PWWheatDMA#c.PWWheatPiA  c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway  if Week>365 & dis_indicator == 3, a(City Week) cluster(Province) 
eststo: reghdfe PWWheatDMA l.PWWheatDMA  c.l.PWWheatDMA#c.PWWheatPiA  c.l.PWWheatDMA#c.War_W0_50_d c.l.PWWheatDMA#c.rug_20 c.l.PWWheatDMA#c.river_20 wheat20t c.l.PWWheatDMA#c.treaty c.l.PWWheatDMA#c.coast c.l.PWWheatDMA#c.railway  if Week>365 & Week < 581 & dis_indicator == 3 , a(City Week) cluster(Province)     

esttab using "67%-100% near metropolis cluster P.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("All"">1942.12" ">1944.7" "1944.7-1948.8" "" "" "" "" ) replace
 */
 
 
 
 
/*Table 10*/
/* Classification based on Gradient Distance to metropolis */
/* Using each central metropolis' price to replace average price */
/* Spacially dividing 314 cities in several economic cycles */
//Note:clustered at Province level, using 50km buffer to calculate control variables
//Note: 这个表是按照距离到直辖市的距离，将所有城市分为三类，看前面的回归在这三类城市中效果分别如何，同时使用中心城市价格替代全国平均价格


**Integrate (Beijing and Tianjin), (Nanjing and Shanghai) in two whole economic cycles
**将北京天津，南京上海合并为一个经济圈
replace nearcity = 1 if nearcity == 9
replace nearcity = 7 if nearcity == 5

**利用到离自己最近的特别市距离为0的条件，单独挑出所有的特别市的价格，并使不是特别市的价格变成缺失
//Note:这个代码在处理我们前面合并的北京天津，南京上海时，会自动计算两者的平均值
bysort Week nearcity: egen RiceMA_Center1=mean(rice_adj) if neardirect == 0 
bysort Week nearcity: egen WheatMA_Center1=mean(wheat_adj) if neardirect == 0 

**下面的代码，将所有属于同一个经济圈的城市的价格替换为中心城市的价格
bysort Week nearcity: egen RiceMA_Center=max(RiceMA_Center1)
bysort Week nearcity: egen WheatMA_Center=max(WheatMA_Center1)

xtset City Week
gen RicePiA_Center=(RiceMA_Center - l.RiceMA_Center)*100
gen WheatPiA_Center=(WheatMA_Center - l.WheatMA_Center)*100
gen RiceDMA_Center=rice_adj-RiceMA_Center
gen WheatDMA_Center=wheat_adj-WheatMA_Center



******
eststo clear

*rice
eststo: reghdfe RiceDMA_Center l.RiceDMA_Center  c.l.RiceDMA_Center#c.RicePiA_Center  c.l.RiceDMA_Center#c.War_W0_50_d c.l.RiceDMA_Center#c.rug_20 c.l.RiceDMA_Center#c.river_20 rice20t c.l.RiceDMA_Center#c.treaty c.l.RiceDMA_Center#c.coast c.l.RiceDMA_Center#c.railway  if Week>365 & Week < 581 & dis_indicator == 1 , a(City Week) cluster(Province)    // near 

eststo: reghdfe RiceDMA_Center l.RiceDMA_Center  c.l.RiceDMA_Center#c.RicePiA_Center  c.l.RiceDMA_Center#c.War_W0_50_d c.l.RiceDMA_Center#c.rug_20 c.l.RiceDMA_Center#c.river_20 rice20t c.l.RiceDMA_Center#c.treaty c.l.RiceDMA_Center#c.coast c.l.RiceDMA_Center#c.railway  if Week>365 & Week < 581 & dis_indicator == 2 , a(City Week) cluster(Province)    // medium

eststo: reghdfe RiceDMA_Center l.RiceDMA_Center  c.l.RiceDMA_Center#c.RicePiA_Center  c.l.RiceDMA_Center#c.War_W0_50_d c.l.RiceDMA_Center#c.rug_20 c.l.RiceDMA_Center#c.river_20 rice20t c.l.RiceDMA_Center#c.treaty c.l.RiceDMA_Center#c.coast c.l.RiceDMA_Center#c.railway  if Week>365 & Week < 581 & dis_indicator == 3 , a(City Week) cluster(Province)    // far



*wheat
eststo: reghdfe WheatDMA_Center l.WheatDMA_Center  c.l.WheatDMA_Center#c.WheatPiA_Center  c.l.WheatDMA_Center#c.War_W0_50_d c.l.WheatDMA_Center#c.rug_20 c.l.WheatDMA_Center#c.river_20 wheat20t c.l.WheatDMA_Center#c.treaty c.l.WheatDMA_Center#c.coast c.l.WheatDMA_Center#c.railway  if Week>365 & Week < 581 & dis_indicator == 1 , a(City Week) cluster(Province)  // near 

eststo: reghdfe WheatDMA_Center l.WheatDMA_Center  c.l.WheatDMA_Center#c.WheatPiA_Center  c.l.WheatDMA_Center#c.War_W0_50_d c.l.WheatDMA_Center#c.rug_20 c.l.WheatDMA_Center#c.river_20 wheat20t c.l.WheatDMA_Center#c.treaty c.l.WheatDMA_Center#c.coast c.l.WheatDMA_Center#c.railway  if Week>365 & Week < 581 & dis_indicator == 2 , a(City Week) cluster(Province) // medium 

eststo: reghdfe WheatDMA_Center l.WheatDMA_Center  c.l.WheatDMA_Center#c.WheatPiA_Center  c.l.WheatDMA_Center#c.War_W0_50_d c.l.WheatDMA_Center#c.rug_20 c.l.WheatDMA_Center#c.river_20 wheat20t c.l.WheatDMA_Center#c.treaty c.l.WheatDMA_Center#c.coast c.l.WheatDMA_Center#c.railway  if Week>365 & Week < 581 & dis_indicator == 3 , a(City Week) cluster(Province)  // far

esttab using "`outdir'/distance_center.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(2) title( \label{distance_center}) ///
 mtitles("Near" "Medium" "Distant" "Near" "Medium" "Distant" ) replace


/*
**0-33%near metropolis cluster P
eststo clear
eststo: reghdfe RiceDMA_Center l.RiceDMA_Center  c.l.RiceDMA_Center#c.RicePiA_Center  c.l.RiceDMA_Center#c.War_W0_50_d c.l.RiceDMA_Center#c.rug_20 c.l.RiceDMA_Center#c.river_20 rice20t c.l.RiceDMA_Center#c.treaty c.l.RiceDMA_Center#c.coast c.l.RiceDMA_Center#c.railway if dis_indicator == 1 , a(City Week) cluster(Province)   
eststo: reghdfe RiceDMA_Center l.RiceDMA_Center  c.l.RiceDMA_Center#c.RicePiA_Center  c.l.RiceDMA_Center#c.War_W0_50_d c.l.RiceDMA_Center#c.rug_20 c.l.RiceDMA_Center#c.river_20 rice20t c.l.RiceDMA_Center#c.treaty c.l.RiceDMA_Center#c.coast c.l.RiceDMA_Center#c.railway  if Week>286 & dis_indicator == 1, a(City Week) cluster(Province)     
eststo: reghdfe RiceDMA_Center l.RiceDMA_Center c.l.RiceDMA_Center#c.RicePiA_Center  c.l.RiceDMA_Center#c.War_W0_50_d c.l.RiceDMA_Center#c.rug_20 c.l.RiceDMA_Center#c.river_20 rice20t c.l.RiceDMA_Center#c.treaty c.l.RiceDMA_Center#c.coast c.l.RiceDMA_Center#c.railway  if Week>365 & dis_indicator == 1, a(City Week) cluster(Province)     
eststo: reghdfe RiceDMA_Center l.RiceDMA_Center  c.l.RiceDMA_Center#c.RicePiA_Center  c.l.RiceDMA_Center#c.War_W0_50_d c.l.RiceDMA_Center#c.rug_20 c.l.RiceDMA_Center#c.river_20 rice20t c.l.RiceDMA_Center#c.treaty c.l.RiceDMA_Center#c.coast c.l.RiceDMA_Center#c.railway  if Week>365 & Week < 581 & dis_indicator == 1 , a(City Week) cluster(Province)     

eststo: reghdfe WheatDMA_Center l.WheatDMA_Center  c.l.WheatDMA_Center#c.WheatPiA_Center  c.l.WheatDMA_Center#c.War_W0_50_d c.l.WheatDMA_Center#c.rug_20 c.l.WheatDMA_Center#c.river_20 wheat20t c.l.WheatDMA_Center#c.treaty c.l.WheatDMA_Center#c.coast c.l.WheatDMA_Center#c.railway if dis_indicator == 1 , a(City Week) cluster(Province) 
eststo: reghdfe WheatDMA_Center l.WheatDMA_Center  c.l.WheatDMA_Center#c.WheatPiA_Center  c.l.WheatDMA_Center#c.War_W0_50_d c.l.WheatDMA_Center#c.rug_20 c.l.WheatDMA_Center#c.river_20 wheat20t c.l.WheatDMA_Center#c.treaty c.l.WheatDMA_Center#c.coast c.l.WheatDMA_Center#c.railway  if Week>286 & dis_indicator == 1, a(City Week) cluster(Province)     
eststo: reghdfe WheatDMA_Center l.WheatDMA_Center  c.l.WheatDMA_Center#c.WheatPiA_Center  c.l.WheatDMA_Center#c.War_W0_50_d c.l.WheatDMA_Center#c.rug_20 c.l.WheatDMA_Center#c.river_20 wheat20t c.l.WheatDMA_Center#c.treaty c.l.WheatDMA_Center#c.coast c.l.WheatDMA_Center#c.railway  if Week>365 & dis_indicator == 1, a(City Week) cluster(Province) 
eststo: reghdfe WheatDMA_Center l.WheatDMA_Center  c.l.WheatDMA_Center#c.WheatPiA_Center  c.l.WheatDMA_Center#c.War_W0_50_d c.l.WheatDMA_Center#c.rug_20 c.l.WheatDMA_Center#c.river_20 wheat20t c.l.WheatDMA_Center#c.treaty c.l.WheatDMA_Center#c.coast c.l.WheatDMA_Center#c.railway  if Week>365 & Week < 581 & dis_indicator == 1 , a(City Week) cluster(Province)     

esttab using "33% near metropolis cluster P (metropolis' price).tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("All"">1942.12" ">1944.7" "1944.7-1948.8" "" "" "" "" ) replace

**33%-67%near metropolis cluster P
eststo clear
eststo: reghdfe RiceDMA_Center l.RiceDMA_Center  c.l.RiceDMA_Center#c.RicePiA_Center  c.l.RiceDMA_Center#c.War_W0_50_d c.l.RiceDMA_Center#c.rug_20 c.l.RiceDMA_Center#c.river_20 rice20t c.l.RiceDMA_Center#c.treaty c.l.RiceDMA_Center#c.coast c.l.RiceDMA_Center#c.railway if dis_indicator == 2 , a(City Week) cluster(Province)   
eststo: reghdfe RiceDMA_Center l.RiceDMA_Center  c.l.RiceDMA_Center#c.RicePiA_Center  c.l.RiceDMA_Center#c.War_W0_50_d c.l.RiceDMA_Center#c.rug_20 c.l.RiceDMA_Center#c.river_20 rice20t c.l.RiceDMA_Center#c.treaty c.l.RiceDMA_Center#c.coast c.l.RiceDMA_Center#c.railway  if Week>286 & dis_indicator == 2, a(City Week) cluster(Province)     
eststo: reghdfe RiceDMA_Center l.RiceDMA_Center c.l.RiceDMA_Center#c.RicePiA_Center  c.l.RiceDMA_Center#c.War_W0_50_d c.l.RiceDMA_Center#c.rug_20 c.l.RiceDMA_Center#c.river_20 rice20t c.l.RiceDMA_Center#c.treaty c.l.RiceDMA_Center#c.coast c.l.RiceDMA_Center#c.railway  if Week>365 & dis_indicator == 2, a(City Week) cluster(Province)     
eststo: reghdfe RiceDMA_Center l.RiceDMA_Center  c.l.RiceDMA_Center#c.RicePiA_Center  c.l.RiceDMA_Center#c.War_W0_50_d c.l.RiceDMA_Center#c.rug_20 c.l.RiceDMA_Center#c.river_20 rice20t c.l.RiceDMA_Center#c.treaty c.l.RiceDMA_Center#c.coast c.l.RiceDMA_Center#c.railway  if Week>365 & Week < 581 & dis_indicator == 2 , a(City Week) cluster(Province)     

eststo: reghdfe WheatDMA_Center l.WheatDMA_Center  c.l.WheatDMA_Center#c.WheatPiA_Center  c.l.WheatDMA_Center#c.War_W0_50_d c.l.WheatDMA_Center#c.rug_20 c.l.WheatDMA_Center#c.river_20 wheat20t c.l.WheatDMA_Center#c.treaty c.l.WheatDMA_Center#c.coast c.l.WheatDMA_Center#c.railway if dis_indicator == 2 , a(City Week) cluster(Province) 
eststo: reghdfe WheatDMA_Center l.WheatDMA_Center  c.l.WheatDMA_Center#c.WheatPiA_Center  c.l.WheatDMA_Center#c.War_W0_50_d c.l.WheatDMA_Center#c.rug_20 c.l.WheatDMA_Center#c.river_20 wheat20t c.l.WheatDMA_Center#c.treaty c.l.WheatDMA_Center#c.coast c.l.WheatDMA_Center#c.railway  if Week>286 & dis_indicator == 2, a(City Week) cluster(Province)     
eststo: reghdfe WheatDMA_Center l.WheatDMA_Center  c.l.WheatDMA_Center#c.WheatPiA_Center  c.l.WheatDMA_Center#c.War_W0_50_d c.l.WheatDMA_Center#c.rug_20 c.l.WheatDMA_Center#c.river_20 wheat20t c.l.WheatDMA_Center#c.treaty c.l.WheatDMA_Center#c.coast c.l.WheatDMA_Center#c.railway  if Week>365 & dis_indicator == 2, a(City Week) cluster(Province) 
eststo: reghdfe WheatDMA_Center l.WheatDMA_Center  c.l.WheatDMA_Center#c.WheatPiA_Center  c.l.WheatDMA_Center#c.War_W0_50_d c.l.WheatDMA_Center#c.rug_20 c.l.WheatDMA_Center#c.river_20 wheat20t c.l.WheatDMA_Center#c.treaty c.l.WheatDMA_Center#c.coast c.l.WheatDMA_Center#c.railway  if Week>365 & Week < 581 & dis_indicator == 2 , a(City Week) cluster(Province)     

esttab using "33%-67% near metropolis cluster P (metropolis' price).tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("All"">1942.12" ">1944.7" "1944.7-1948.8" "" "" "" "" ) replace

 
**67%-100%near metropolis cluster P
eststo clear
eststo: reghdfe RiceDMA_Center l.RiceDMA_Center  c.l.RiceDMA_Center#c.RicePiA_Center  c.l.RiceDMA_Center#c.War_W0_50_d c.l.RiceDMA_Center#c.rug_20 c.l.RiceDMA_Center#c.river_20 rice20t c.l.RiceDMA_Center#c.treaty c.l.RiceDMA_Center#c.coast c.l.RiceDMA_Center#c.railway if dis_indicator == 3 , a(City Week) cluster(Province)   
eststo: reghdfe RiceDMA_Center l.RiceDMA_Center  c.l.RiceDMA_Center#c.RicePiA_Center  c.l.RiceDMA_Center#c.War_W0_50_d c.l.RiceDMA_Center#c.rug_20 c.l.RiceDMA_Center#c.river_20 rice20t c.l.RiceDMA_Center#c.treaty c.l.RiceDMA_Center#c.coast c.l.RiceDMA_Center#c.railway  if Week>286 & dis_indicator == 3, a(City Week) cluster(Province)     
eststo: reghdfe RiceDMA_Center l.RiceDMA_Center c.l.RiceDMA_Center#c.RicePiA_Center  c.l.RiceDMA_Center#c.War_W0_50_d c.l.RiceDMA_Center#c.rug_20 c.l.RiceDMA_Center#c.river_20 rice20t c.l.RiceDMA_Center#c.treaty c.l.RiceDMA_Center#c.coast c.l.RiceDMA_Center#c.railway  if Week>365 & dis_indicator == 3, a(City Week) cluster(Province)     
eststo: reghdfe RiceDMA_Center l.RiceDMA_Center  c.l.RiceDMA_Center#c.RicePiA_Center  c.l.RiceDMA_Center#c.War_W0_50_d c.l.RiceDMA_Center#c.rug_20 c.l.RiceDMA_Center#c.river_20 rice20t c.l.RiceDMA_Center#c.treaty c.l.RiceDMA_Center#c.coast c.l.RiceDMA_Center#c.railway  if Week>365 & Week < 581 & dis_indicator == 3 , a(City Week) cluster(Province)     

eststo: reghdfe WheatDMA_Center l.WheatDMA_Center  c.l.WheatDMA_Center#c.WheatPiA_Center  c.l.WheatDMA_Center#c.War_W0_50_d c.l.WheatDMA_Center#c.rug_20 c.l.WheatDMA_Center#c.river_20 wheat20t c.l.WheatDMA_Center#c.treaty c.l.WheatDMA_Center#c.coast c.l.WheatDMA_Center#c.railway if dis_indicator == 3 , a(City Week) cluster(Province) 
eststo: reghdfe WheatDMA_Center l.WheatDMA_Center  c.l.WheatDMA_Center#c.WheatPiA_Center  c.l.WheatDMA_Center#c.War_W0_50_d c.l.WheatDMA_Center#c.rug_20 c.l.WheatDMA_Center#c.river_20 wheat20t c.l.WheatDMA_Center#c.treaty c.l.WheatDMA_Center#c.coast c.l.WheatDMA_Center#c.railway  if Week>286 & dis_indicator == 3, a(City Week) cluster(Province)     
eststo: reghdfe WheatDMA_Center l.WheatDMA_Center  c.l.WheatDMA_Center#c.WheatPiA_Center  c.l.WheatDMA_Center#c.War_W0_50_d c.l.WheatDMA_Center#c.rug_20 c.l.WheatDMA_Center#c.river_20 wheat20t c.l.WheatDMA_Center#c.treaty c.l.WheatDMA_Center#c.coast c.l.WheatDMA_Center#c.railway  if Week>365 & dis_indicator == 3, a(City Week) cluster(Province) 
eststo: reghdfe WheatDMA_Center l.WheatDMA_Center  c.l.WheatDMA_Center#c.WheatPiA_Center  c.l.WheatDMA_Center#c.War_W0_50_d c.l.WheatDMA_Center#c.rug_20 c.l.WheatDMA_Center#c.river_20 wheat20t c.l.WheatDMA_Center#c.treaty c.l.WheatDMA_Center#c.coast c.l.WheatDMA_Center#c.railway  if Week>365 & Week < 581 & dis_indicator == 3 , a(City Week) cluster(Province)     

esttab using "67%-100% near metropolis cluster P (metropolis' price).tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("All"">1942.12" ">1944.7" "1944.7-1948.8" "" "" "" "" ) replace
 
*/


/*
***********************************************************************************************
****************************************** summary statistics *********************************
***********************************************************************************************

outreg2 using "`outdir'\summary.tex", sum(detail) keep(RicePiC WheatPiC RicePiC_52 WheatPiC_52 RicePiA WheatPiA RicePiA_52 WheatPiA_52 PWRicePiA PWWheatPiA PWRicePiA_52 PWWheatPiA_52) sortvar(RicePiC WheatPiC RicePiC_52 WheatPiC_52 RicePiA WheatPiA RicePiA_52 WheatPiA_52 PWRicePiA PWWheatPiA PWRicePiA_52 PWWheatPiA_52) replace eqkeep(mean p50 max min sd N) dec(0) title(Summary Statistics)
*/
