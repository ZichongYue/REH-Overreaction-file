Project Title: Overreaction in inflation expectations: Do behavioral attributes of individuals matter?
Authors: Takayuki Tsuruga (University of Osaka), Zichong Yue (University of Osaka)
1. Overview
This readme contains the STATA and Python code required to replicate the empirical results of the paper. The study investigates how behavioral individual attributes (BA) — such as present bias, planning ability, self-control, and risk aversion — interact with the overreaction to public signals in inflation expectations. 
2. Software Requirements
	STATA 19: 
	Required packages: xtreg, outreg2 (Install via ssc install outreg2). 
	Python 3.11: 
	Required libraries: pandas, numpy. 
3. Data Sources
	Micro Data (JHPS-CPS): The Japan Household Panel Survey on Consumer Preferences and Satisfaction (University of Osaka). It provides:
	π_(it+1)^e: One-year-ahead numerical inflation expectations. 
	z_it: Behavioral attributes (BA) and control variables (X_it). 
	Macro Data (Public Signals): 
	Actual Inflation (π_(t+1)): Core CPI, derived from the Statistics Bureau of Japan Consumer Price Index.
	Information Set (y_t): Since JHPS-CPS is conducted in January, we use preliminary CPI data from the preceding December to accurately reflect the information set available to respondents at that time. 
	Alternative Signals: Includes general CPI, fresh-food prices, consensus forecasts, month-on-month inflation, and experienced inflation for robustness.
4. Estimation Strategy
The core regression model is specified as follows: 
π_(t+1)-π_(it+1)^e=a_i+by_t+b_z^' z_it y_t+c^' X_it+v_(it+1)
Where:
	a_i: Individual fixed effects. 
	b: Reaction to the public signal. 
	b_z^': Reaction of behavioral attributes to the public signal.
5. Execution Guide
Step 1: Data Preparation
Run Constructing_panel.do to merge the JHPS-CPS microdata with Statistics Bureau of Japan macro-inflation data and generate the final panel dataset. 
Step 2: Main Analysis

Output	Script	Description
Table 1	Baseline.do	Estimates the baseline response to past inflation
Table 2	Baseline.CTRL.do	Estimates the model with control variables
Figure 1	figure1.do	Plots actual inflation vs. mean expectations (2004–2024)

Step 3: Robustness Analysis (Table 3) 
To replicate specific columns in Table 3, run the corresponding .do files:
	Col (2): NoHiInfdummy.do (Excludes structural break assumption). 
	Col (3): NonCore.do (Uses general CPI). 
	Col (4): Fresh.do (Uses fresh-food inflation). 
	Col (5): Concensus.do (Uses consensus forecasts as the signal). 
	Col (6): Fresh_CFE.do (Uses fresh-food inflation as public signal while keep using core CPI to construct forecast error).
	Col (7): MonM_CFE.do (Uses month-on-month inflation).
	Col (8): ExpInflation.do (Uses experienced inflation calculated via Python).
6. Python Scripts Detail
	Experiencedinflation.py: Processes CPI data from 1970–2024 to calculate respondent-specific "Experienced Inflation" based on age and calibrated decay weights (ρ=11.03).


