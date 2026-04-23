*
* Baseline_CTRL.do
*
* written by Yue Zichong
* modified by Taka Tsuruga
* ******************************************************************************
set logtype text /* set default file format for log*/
log using Baseline_CTRL2026_0325, replace

use dta/panel_data, clear
xtset panelid Year

gen ps = CCPI_lag /* ps: public signal */
gen Depvar = CFE /* Depvar: dependent variable */
/*
================================================================================
REGRESSION ANALYSIS 
================================================================================
*/

/* 
ssc install outreg2, replace
ssc install reghdfe, replace

ssc install ftools, replace
ssc install ivreg2, replace

*/ 

/*
--------------------------------------------------------------------------------
Forecast error of Core CPI inflation  
--------------------------------------------------------------------------------
*/
*
* Regression (1): No interaction term, No time dummy
*
reghdfe Depvar ps, absorb(panelid) vce(cluster panelid) 
outreg2 using Baseline_CTRL.xls, replace dec(3) ///
ctitle(CFE) keep (ps)

*
* Regression (2): No interaction term, Time dummy for constant
*
* Dummy for high inflation period
gen DHiI = 0 
replace DHiI = 1 if Year == 2022 | Year == 2023 | Year == 2024

* Dummy for 2022, 2023, 2024 alone
foreach year in 2022 2023 2024 {
    gen D`year' = (Year == `year')
}

reghdfe Depvar ps DHiI, absorb(panelid) vce(cluster panelid)
outreg2 using Baseline_CTRL.xls, append dec(3) ///
ctitle(CFE) keep (ps DHiI)

*
* Income, Age, Education as control variables
* 
* (1) income
gen logIC = log(IC)
quietly summarize logIC
gen logIC_z = (logIC - r(mean)) / r(sd)

* (2) AGE  
generate Age = Year - AgeY
replace Age = . if Age > 100
/* Age Dummy 1. AA Age Absolute. Age < 40: young; 40 - 60: middle; > 60: old */
forvalues i = 1/3{ 
generate AA`i' = 0
}
replace AA1 = 1 if Age > 0 & Age < 40
replace AA2 = 1 if Age > = 40 & Age < 60
replace AA3 = 1 if Age > 60 & Age < = 100

gen young = AA1
gen middle = AA2

* (3) Education
* eduhigh = High education level, edulow = Low education level
gen eduhigh = 0
gen edulow = 0
replace eduhigh = . if EduY == .
replace eduhigh = 1 if EduY == 7 | EduY == 8 | EduY == 9 | EduY == 10 | EduY == 11 
replace edulow = . if EduY == .
replace edulow = 1 if EduY == 1 | EduY == 2 | EduY == 3 | EduY == 4 | EduY == 5 | EduY == 6 


*
* Regression (3): Interaction term, Time dummy for constant
*
* (3)-1: Does dynamic consistency matter for reaction? 

* Dummy for dynamic consistencey
* zDC = 1 if there is a dynamically consistent (no present bias) 
* zDC = 0 if there is present bias (lambda > 0)
gen zDC = 0
replace zDC = . if missing(lambda)
replace zDC = 1 if lambda == 0
* Lagged zDC
gen zDC_lag = L.zDC 
reghdfe Depvar c.ps##i.zDC_lag ///
c.logIC_z 1.young 1.middle DHiI ///
liq_lag, ///
absorb(panelid) vce(cluster panelid)
outreg2 using Baseline_CTRL.xls, append dec(3) ///
ctitle(CFE) keep (ps DHiI 1.zDC_lag c.ps#1.zDC_lag)
lincom _b[ps] + _b[1.zDC_lag#c.ps]

* (3)-2-a: Does planning ability matter for reaction? 
gen FLgroup1 = 0
gen FLgroup2 = 0
gen FLgroup3 = 0

replace FLgroup1 = . if FL ==.
replace FLgroup1 = 1 if FL == 1 | FL == 2 /* Forward-looking */
replace FLgroup3 = . if FL ==.
replace FLgroup3 = 1 if FL == 3 
replace FLgroup2 = . if FL ==.
replace FLgroup2 = 1 if FL == 4 | FL == 5 /* Myopic */ 
* Lagged variable 
gen FLgroup1_lag = L.FLgroup1
reghdfe Depvar c.ps##i.FLgroup1_lag ///
c.logIC_z 1.young 1.middle DHiI ///
liq_lag, ///
absorb(panelid) vce(cluster panelid)
outreg2 using Baseline_CTRL.xls, append dec(3) ///
ctitle(CFE) keep (ps DHiI 1.FLgroup1_lag c.ps#1.FLgroup1_lag)
lincom _b[ps] + _b[1.FLgroup1_lag#c.ps]

* (3)-3-a: Does self control ability matter for reaction? 
* SCgroup1 = rational
gen SCgroup1 = 0
gen SCgroup2 = 0
gen SCgroup3 = 0
replace SCgroup1 = . if SC == .
replace SCgroup1 = 1 if SC == 4 | SC == 5 /* Self controlled */ 
replace SCgroup2 = . if SC == .
replace SCgroup2 = 1 if SC == 1 | SC == 2 /* Indulgent */
replace SCgroup3 = . if SC == .
replace SCgroup3 = 1 if SC == 3 
* Lagged variable 
gen SCgroup1_lag = L.SCgroup1
reghdfe Depvar c.ps##i.SCgroup1_lag ///
c.logIC_z 1.young 1.middle DHiI ///
liq_lag, ///
absorb(panelid) vce(cluster panelid)
outreg2 using Baseline_CTRL.xls, append dec(3) ///
ctitle(CFE) keep (ps DHiI 1.SCgroup1_lag c.ps#1.SCgroup1_lag)
lincom _b[ps] + _b[1.SCgroup1_lag#c.ps]

* (3)-4-a: Does risk attitude (risk aversion) matter for reaction? 
* Here we take standardization for transformed price
quietly summarize price
gen price_z = (price - r(mean)) / r(sd)
gen price_z_lag = L.price_z

* Transformed price for risk aversion (Lagged) 
reghdfe Depvar c.ps##c.price_z_lag ///
c.logIC_z 1.young 1.middle DHiI ///
liq_lag, ///
absorb(panelid) vce(cluster panelid)
outreg2 using Baseline_CTRL.xls, append dec(3) ///
ctitle(CFE) keep (ps DHiI price_z_lag c.ps#c.price_z_lag)
lincom _b[ps] + 2*_b[c.price_z_lag#c.ps] /* Note here we assume that individual become more risk-averse by 2sd */


* (3)-1, 2, 3, 4, 5, 6: Do present bias, planning ability, risk attitude (risk aversion) self-control experienced inflation matter for reaction? 

reghdfe Depvar c.ps##i.zDC_lag ///
         i.FLgroup1_lag c.ps#i.FLgroup1_lag ///
		 i.SCgroup1_lag c.ps#i.SCgroup1_lag ///
		 price_z_lag c.ps#c.price_z_lag ///
		 c.logIC_z 1.young 1.middle DHiI ///
		 liq_lag, ///
		 absorb(panelid) vce(cluster panelid)
outreg2 using Baseline_CTRL.xls, append dec(3) ///
ctitle(CFE) keep (ps DHiI 1.zDC_lag c.ps#1.zDC_lag ///
                    1.FLgroup1_lag c.ps#1.FLgroup1_lag ///
					1.SCgroup1_lag c.ps#1.SCgroup1_lag ///
					price_z_lag c.ps#c.price_z_lag)

lincom _b[ps] + _b[1.zDC_lag#c.ps] + _b[1.FLgroup1_lag#c.ps] + _b[1.SCgroup1_lag#c.ps] 
lincom _b[ps] + _b[1.zDC_lag#c.ps] + _b[1.FLgroup1_lag#c.ps] + _b[1.SCgroup1_lag#c.ps] ///
                    + 2*_b[c.price_z_lag#c.ps] /// Conservative estimates
					
					
erase Baseline_CTRL.txt

log close
exit
