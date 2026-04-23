*
* Constructing the panel data
*
* written by Yue Zichong
* modified by Taka Tsuruga
* ******************************************************************************
clear 
set more off
matrix drop _all

*
* 1. reading the data
*

/* merge data */
use dta/2004, clear
foreach year in 2005 2006 2007 2008 2009 2010 2011 2012 2013 2016 2017 2018 2021 2022 2023 2024 {
    merge 1:1 panelid using dta/`year'
    drop _merge
}

/* rename the data */
/* Expectation of next year's inflation EI2004 = expected inflation of 2004 */
foreach year in 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2016 2017 2018 2021 2022 2023 2024 {
    rename Epi`year' EI`year'
}

keep panelid prefid IitY* EI* ig*

/* Merge gender */
merge 1:1 panelid using dta/Sex
drop _merge

/* Merge Age */
merge 1:1 panelid using dta/AgeY
drop _merge

/* Merge Education level */
merge 1:1 panelid using dta/edu
drop _merge

/* CPI inflation reported by Statistic Bereau (Year on year annual rate %)*/
gen CPI2007 = 0.7
gen CPI2008 = 0.4
gen CPI2009 = -1.7
gen CPI2010 = 0
gen CPI2011 = -0.2
gen CPI2012 = -0.1
gen CPI2013 = 1.6
gen CPI2014 = 2.4
gen CPI2015 = 0.2
gen CPI2016 = 0.3
gen CPI2017 = 1
gen CPI2018 = 0.3
gen CPI2019 = 0.8
gen CPI2020 = -1.2
gen CPI2021 = 0.8
gen CPI2022 = 4
gen CPI2023 = 2.6
gen CPI2024 = 3.6

/* Core CPI inflation reported by Statistic Bereau (Year on year annual rate %)*/
gen CCPI2003 = -0.3
gen CCPI2004 = -0.1
gen CCPI2005 = 0.1
gen CCPI2006 = 0.1
gen CCPI2007 = 0.8
gen CCPI2008 = 0.2
gen CCPI2009 = -1.3
gen CCPI2010 = -0.4
gen CCPI2011 = -0.1
gen CCPI2012 = -0.2
gen CCPI2013 = 1.2
gen CCPI2014 = 2.6
gen CCPI2015 = 0.1
gen CCPI2016 = -0.2
gen CCPI2017 = 0.9
gen CCPI2018 = 0.7
gen CCPI2019 = 0.7
gen CCPI2020 = -1
gen CCPI2021 = 0.5
gen CCPI2022 = 4
gen CCPI2023 = 2.3
gen CCPI2024 = 3

/* Core CPI inflation reported by Statistic Bereau (month on month annual rate %)*/
gen MCCPI2003 = 6.1
gen MCCPI2004 = 7.4
gen MCCPI2005 = 1.2
gen MCCPI2006 = -1.2
gen MCCPI2007 = 3.6
gen MCCPI2008 = -6
gen MCCPI2009 = -1.2
gen MCCPI2010 = 0
gen MCCPI2011 = 0
gen MCCPI2012 = -1.2
gen MCCPI2013 = -1.2
gen MCCPI2014 = -2.3
gen MCCPI2015 = -1.2
gen MCCPI2016 = 0
gen MCCPI2017 = 0
gen MCCPI2018 = -1.2
gen MCCPI2019 = 1.2
gen MCCPI2020 = 0
gen MCCPI2021 = 1.2
gen MCCPI2022 = 4.8
gen MCCPI2023 = 2.4
gen MCCPI2024 = 6

/* CPI inflation of fresh food reported by Statistic Bereau (Year on year annual rate %)*/
gen freshCPI2004 = 2.5
gen freshCPI2005 = -3.4
gen freshCPI2006 = 4.3
gen freshCPI2007 = 0.7
gen freshCPI2008 = -0.4
gen freshCPI2009 = -2.5
gen freshCPI2010 = 5.8
gen freshCPI2011 = -1
gen freshCPI2012 = 0.5
gen freshCPI2013 = -0.1
gen freshCPI2014 = 6.2
gen freshCPI2015 = 6.8
gen freshCPI2016 = 4.6
gen freshCPI2017 = -0.2
gen freshCPI2018 = 3.8
gen freshCPI2019 = -3.1
gen freshCPI2020 = 3.3
gen freshCPI2021 = -1.2
gen freshCPI2022 = 8.1
gen freshCPI2023 = 7.4
gen freshCPI2024 = 7

/* generate inflation error of each year 
   For CPI inflation, data from 2007 */

foreach year in 2007 2008 2009 2010 2011 2012 2013 2016 2017 2018 2021 2022 2023 2024 {
    gen FE`year' = CPI`year' - EI`year'
	* CPI from 2007 to 2024
	* EI from 2004 to 2013, 2016-2018, 2021-2024 
}


/* generate inflation error of each year 
   For Core CPI data from 2004 */
foreach year in 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2016 2017 2018 2021 2022 2023 2024 {
    gen CFE`year' = CCPI`year' - EI`year'
	* CCPI from 2003 to 2024
	* EI from 2004 to 2013, 2016-2018, 2021-2024 
}


/* generate inflation error of each year 
   For Core CPI month on month data from 2004 */
foreach year in 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2016 2017 2018 2021 2022 2023 2024 {
    gen MCFE`year' = MCCPI`year' - EI`year'
	* CCPI m on m from 2003 to 2024
	* EI from 2004 to 2013, 2016-2018, 2021-2024 
}

/* generate inflation error of each year 
   For CPI inflation of fresh food, data from 2004 */

foreach year in 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2016 2017 2018 2021 2022 2023 2024 {
    gen FFE`year' = freshCPI`year' - EI`year'
	* CPIfresh from 2004 to 2024
	* EI from 2004 to 2013, 2016-2018, 2021-2024 
}
* Drop data
drop ig_ans*


/* present bias beta 
   beta = 0 => lambda = 1 (fully biased)
   beta = 1 => lambda = 0 (no present bias)
*/
merge 1:1 panelid using dta/beta
drop _merge

* Forward-looking factor
merge 1:1 panelid using dta/FL
drop _merge


* self-control factor
merge 1:1 panelid using dta/SC
drop _merge

merge 1:1 panelid using dta/NPR
drop _merge

* risk
merge 1:1 panelid using dta/risk
drop _merge

* Expected inflation
merge 1:1 panelid using dta/Experienced_Inflation
drop _merge

* Liquidity constraint
merge 1:1 panelid using dta/liquidity_constraint
drop _merge

*
* Panel structure 
*

keep panelid prefid FE* EI* CFE* MCFE* FFE* ///
			  CPI* CCPI* ig* MCCPI* freshCPI* ///
			  beta* beta_delta* price* riskaversion* ///
              FL* SC* NPR* ///
			  Sex* AgeY* IitY* EduY* ///
			  Experienced_inflation* liq*
		  
reshape long FE CFE EI MCFE FFE CPI CCPI ig MCCPI freshCPI beta beta_delta price riskaversion FL SC NPR Sex AgeY IitY EduY Experienced_inflation liq, i(panelid) j(Year)
			  
			  
xtset panelid Year

* Variable transformation: Public signal
gen CPI_lag = L.CPI
gen CCPI_lag = L.CCPI		  
gen ig_lag = L.ig
gen MCCPI_lag = L.MCCPI
gen freshCPI_lag = L.freshCPI

* Degree of present bias (lambda = 1 - beta)
/* You must exclude outliers from beta or lambda */ 
gen lambda = 1 - beta
* We do not drop the sample with lambda < 0
replace lambda = 0 if lambda < 0 & lambda != .


* If drop the sample with lambda < 0
*replace lambda = . if lambda < 0 & lambda != .



gen lambda_lag = L.lambda
drop beta beta_lag*
replace beta = 1 if beta > 1 & beta != .
*replace beta_delta = . if beta_delta > 1
replace beta_delta = 0 if beta_delta < 0
gen beta_delta_lag = L.beta_delta

/* You must exclude outliers from beta or lambda */ 
gen price_lag = L.price 
gen riskaversion_lag = L.riskaversion

replace FL = . if FL ==9
replace SC = . if SC ==9
drop FL_lag* SC_lag*

 * Income variable.
gen IC = .
replace IC = 0 if IitY == 0
replace IC = 50 if IitY == 1
replace IC = 150 if IitY == 2
replace IC = 300 if IitY == 3
replace IC = 500 if IitY == 4
replace IC = 700 if IitY == 5
replace IC = 900 if IitY == 6
replace IC = 1100 if IitY == 7
replace IC = 1300 if IitY == 8
replace IC = 1500 if IitY == 9
drop IitY

* Experienced_inflation lag and liquidity_constraint lag
gen Experienced_inflation_lag = L.Experienced_inflation
gen liq_lag = L.liq

/* Construct consensus forecasts */
bysort Year: egen mean_EI = mean(EI)
bysort Year: egen sd_EI = sd(EI)
egen p2_EI = pctile(EI), by (Year) p(2.5)
egen p5_EI = pctile(EI), by (Year) p(5)
egen p95_EI = pctile(EI), by (Year) p(95)
egen p975_EI = pctile(EI), by (Year) p(97.5)

gen upper_EI = mean_EI + 1.96*sd_EI
gen lower_EI = mean_EI - 1.96*sd_EI

/* Age */
bys panelid: egen birth_fixed = max(AgeY)
/*
* Ordering
order panelid Year prefid /// 
      FE CFE CPI CCPI EI mean_EI sd_EI ///
	  CPI_lag CCPI_lag /// 
	  ig ig_lag IC ///
	  lambda lambda_lag beta_delta beta_delta_lag ///
	  price price_lag riskaversion riskaversion_lag ///
	  FL SC SCR///
	  Sex AgeY EduY ///
*/
	  
	  
*
* Notation check
*
label variable panelid "ID for individuals"
label variable Year "Time ID"
label variable prefid "Locations ID"		
label variable FE "CPI inflation forecast error"		
label variable CFE "Core CPI inflation forecast error"
label variable MCFE "Core CPI inflation forecast error month on month"
label variable CPI "CPI inflation"		
label variable CCPI "Core CPI inflation"
label variable MCCPI "Core CPI inflation month on month"
label variable freshCPI "CPI inflation of fresh food"		
label variable EI "Expected inflation"
label variable mean_EI "Cross-sectional mean of expected inflation"
label variable sd_EI "Cross-sectional standarad deviations of expected inflation"
label variable CPI_lag "CPI inflation in the previous year"		
label variable CCPI_lag "Core CPI inflation in the previous year"
label variable MCCPI_lag "Core CPI inflation month on month in the previous year"
label variable freshCPI_lag "CPI inflation of fresh food in the previous year"		
label variable ig "Income growth of individuals"		
label variable ig_lag "Income growth of individuals in the previous period"		
label variable IC "Income level (reported by respondents)"
label variable lambda "Degree of present bias"
label variable lambda_lag "Degree of present bias in the previous period"
label variable beta_delta "Time preferences"
label variable beta_delta_lag "Time preference in the previous period"
label variable price "Transformed price for risk aversion" 
label variable price_lag "Transformed price for risk aversion in the previous period"
label variable riskaversion "Degree of absolute risk aversion"
label variable riskaversion_lag "Degree of absolute risk aversion in the previous period"
label variable FL "Planning ability" 
label variable SC "Self-control ability"
label variable NPR "Self-control ability for robustness"
label variable Sex "Gender (1=Male, 2=Female)" 
label variable AgeY "Age"
label variable EduY "Education level"
label variable Experienced_inflation_lag "Experienced inflation in the previous year"
label variable liq_lag "Liquidity constraint in the previous year"
save dta/panel_data, replace

/*
*
* Graphs
*

sort panelid Year
list Year mean_EI sd_EI p2_EI p5_EI p95_EI p975_EI if panelid == 1 
twoway ///
    (line mean_EI Year, msymbol(square) msize(2.5) lpattern(solid) lcolor(blue) lwidth(medium) mlabel(mean_EI)) ///
	(line upper_EI Year, lpattern(dot) lcolor(black) lwidth(medium) mlabel(upper)) ///
    (line lower_EI Year, lpattern(dot) lcolor(black) lwidth(medium) mlabel(lower)), ///
	legend(off) ///	
    title("Expected inflation") ///
    xtitle("Year") ytitle("EI")

