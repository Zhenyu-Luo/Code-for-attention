
********
clear
set more off
use processed_data.dta
gen ignore = 0
// 对数据按城市进行排序
sort City Week
xtset City Date
tsfill, full
drop Week
sort City Date
egen DateOrder = group(Date)

gen Week1 = 196 + (DateOrder+1)/7
gen Week = int(Week1)
drop DateOrder Week1

replace ignore = 1 if rice == .& rice[_n-1] == . & rice[_n-2] == . ///
& rice[_n-3] == . & rice[_n-4] == . & rice[_n-5] == . 
replace rice = rice[_n-6] if rice == .& rice[_n-1] == . & rice[_n-2] == . ///
& rice[_n-3] == . & rice[_n-4] == . & rice[_n-5] == . & ignore[_n-6] == 0 & City == City[_n-6]

replace ignore = 1 if rice == .& rice[_n-1] == . & rice[_n-2] == . ///
& rice[_n-3] == . & rice[_n-4] == .  
replace rice = rice[_n-5] if rice == .& rice[_n-1] == . & rice[_n-2] == . ///
& rice[_n-3] == . & rice[_n-4] == . & ignore[_n-5] == 0 & City == City[_n-5]

replace ignore = 1 if rice == .& rice[_n-1] == . & rice[_n-2] == . ///
& rice[_n-3] == .   
replace rice = rice[_n-4] if rice == .& rice[_n-1] == . & rice[_n-2] == . ///
& rice[_n-3] == . & ignore[_n-4] == 0 & City == City[_n-4]

replace ignore = 1 if rice == .& rice[_n-1] == . & rice[_n-2] == . 
replace rice = rice[_n-3] if rice == .& rice[_n-1] == . & rice[_n-2] == . & ignore[_n-3] == 0 & City == City[_n-3]

replace ignore = 1 if rice == .& rice[_n-1] == .  
replace rice = rice[_n-2] if rice == .& rice[_n-1] == . & ignore[_n-2] == 0 & City == City[_n-2]

replace ignore = 1 if rice == .
replace rice = rice[_n-1] if rice == . & ignore[_n-1] == 0 & City == City[_n-1]

gen rice_change = 0
replace rice_change =1 if rice != rice[_n-1] & City == City[_n-1] & rice[_n-1] != . & rice != .

bysort City Week: egen fre_change_rice = sum(rice_change)

gen rice_exist = 0
replace rice_exist = 1 if rice != .  & ignore == 0
bysort City Week: egen fre_exist_rice = sum(rice_exist)
gen if_calculate_rice = 0
replace if_calculate_rice = 1 if fre_exist_rice > 2

keep Week City fre_change_rice fre_exist_rice if_calculate_rice year
bysort Week: egen Year = min(year)
drop year
duplicates drop
keep if if_calculate_rice == 1

bysort Week : egen avgfre_change_rice = mean(fre_change_rice)
bysort Week : egen avgfre_exist_rice = mean(fre_exist_rice)
keep Week avgfre_change_rice avgfre_exist_rice Year
duplicates drop
merge n:n Week using PWPiA_overlap_unadj.dta
*merge n:n Week using PWPiA_outlier_unadj.dta

gen fre_ratio_rice = avgfre_change_rice/avgfre_exist_rice

reghdfe fre_ratio_rice, a(Year) residual(fre_ratio_rice_adj)
reghdfe avgfre_change_rice, a(Year) residual(avgfre_change_rice_adj)

keep if Week > 286 & Week < 597

sort Week
twoway bar fre_ratio_rice Week, ///
    fintensity(0) lcolor(midblue) lwidth(thin) ///
	ytitle("") ///
	l2title("Ratio of price change", size(large)) || ///
 line PWRicePiA Week, cmissing(n) ///
	clcolor(maroon) clpattern(solid) clwidth(medthin)  yaxis(2) ///
	ytitle("Inflation Rate (%)", size(large) axis(2) color(maroon)) ||,   ///
	xtitle("Week", size(large)) legend( label(1 " Ratio of price change ") ///
	label (2 "Weekly Inflation") cols(1) ring(0) pos(10) region(lwidth(none))  size(*.7))  ///
    graphregion(color(white)) ///
 title("Ratio of price change vs. Inflation Rate of Rice",size(*.8)) 
 graph export "priceinfoq_Shanghai_w_title.eps", replace 
*q stands for quantity of news, w stands for week of time unit

sort Week
twoway line PWRicePiA Week, ///
    fintensity(0) lcolor(midblue) lwidth(thin) ///
	ytitle("") ///
	l2title("Inflation Rate (%)", size(large)) || ///
 line fre_ratio_rice_adj Week, cmissing(n) ///
	fintensity(0) lcolor(maroon) lwidth(thin) yaxis(2) ///
	ytitle("Ratio of price change", size(large) axis(2) color(maroon)) ||,   ///
	xtitle("Week", size(large)) legend( label(1 " Weekly Inflation ") ///
	label (2 "Ratio of price change") cols(1) ring(0) pos(10) region(lwidth(none))  size(*.7))  ///
    graphregion(color(white)) ///
 title("Ratio of price change (year adjusted) vs. Inflation Rate of Rice",size(*.8)) 
 graph export "priceinfoq_Shanghai_w_title.eps", replace 
*q stands for quantity of news, w stands for week of time unit


sort Week
twoway bar avgfre_change_rice Week , ///
    fintensity(0) lcolor(midblue) lwidth(thin) ///
	ytitle("") ///
	l2title("Frequency of Price Change", size(large)) || ///
 line PWRicePiA Week , cmissing(n) ///
	clcolor(maroon) clpattern(solid) clwidth(medthin)  yaxis(2) ///
	ytitle("Inflation Rate (%)", size(large) axis(2) color(maroon)) ||,   ///
	xtitle("Week", size(large)) legend( label(1 " Frequency of Price Change ") ///
	label (2 "Weekly Inflation") cols(1) ring(0) pos(10) region(lwidth(none))  size(*.7))  ///
    graphregion(color(white)) ///
 title("Frequency of Price Change vs. Inflation Rate of Rice",size(*.8)) 
 graph export "priceinfoq_Shanghai_w_title.eps", replace 
*q stands for quantity of news, w stands for week of time unit

sort Week
twoway line PWRicePiA Week, ///
    fintensity(0) lcolor(midblue) lwidth(medthin) ///
	ytitle("") ///
	l2title("Inflation Rate (%)", size(large)) || ///
 line avgfre_change_rice_adj Week, cmissing(n) ///
	fintensity(0) lcolor(maroon) lwidth(medthin) yaxis(2) ///
	ytitle("Frequency of Price Change", size(large) axis(2) color(maroon)) ||,   ///
	xtitle("Week", size(large)) legend( label(1 " Weekly Inflation ") ///
	label (2 "Frequency of Price Change") cols(1) ring(0) pos(10) region(lwidth(none))  size(*.7))  ///
    graphregion(color(white)) ///
 title("Frequency of Price Change (year adjusted) vs. Inflation Rate of Rice",size(*.8)) 
 graph export "priceinfoq_Shanghai_w_title.eps", replace 
*q stands for quantity of news, w stands for week of time unit

