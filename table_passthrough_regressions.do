* ------------------------------------------------------------------------------
* table_passthrough_regressions.do
* This file performs passthrough regressions and creates result tables.
* ------------------------------------------------------------------------------
set more off
clear
cls

* ------------------------------------------------------------------------------
* HEADER
* ------------------------------------------------------------------------------
qui do "/Users/xu/Dropbox/XU/03 GD/20 BU/baxter/xu/charity/input/header.do"

local pathname = "./output/table_passthrough_regressions"
ssc install outreg2

* ------------------------------------------------------------------------------
* INITIALIZATION
* ------------------------------------------------------------------------------
use "./data/ikea_fill_2018.dta", replace
drop if flag > 0

* keep only relevant variables
keep y ij ijtotal c ccode ijc age price_decile ///
	pchange pchangef pchangeb infl_lag depr_eu_lag
xtset

* ------------------------------------------------------------------------------
* VARIABLES
* ------------------------------------------------------------------------------

* re-code 'ijtotal' to 'ijtota3'
* group ijtotal 3,...,max to 3+
* recode only changed values
recode ijtotal (3/max = 3), gen(ijtotal3)
la var ijtotal3 "ijtotal recode: 3/max = 3"
la define ijtotal3_lbl 1 "1"
la define ijtotal3_lbl 2 "2", add
la define ijtotal3_lbl 3 "3+", add
la value ijtotal3 ijtotal3_lbl

* generate value-added tax (VAT) change variables
gen vatchange=0
replace vatchange=log(1.16)-log(1.13)  if c=="de" & y==2007
replace vatchange=log(1.21)-log(1.20)  if c=="it" & y==2012
replace vatchange=log(1.22)-log(1.21)  if c=="it" & y==2013
replace vatchange=log(1.20)-log(1.175) if c=="uk" & y==2012
la var vatchange "VAT change: All"

* generate individual value-added tax (VAT) change variables
gen vatchange_de=vatchange
gen vatchange_it=vatchange
gen vatchange_uk=vatchange
replace vatchange_de=0 if c~="de"
replace vatchange_it=0 if c~="it"
replace vatchange_uk=0 if c~="uk"
la var vatchange_de "VAT change: de"
la var vatchange_it "VAT change: it"
la var vatchange_uk "VAT change: uk"

* generate interaction variables
* (1) interaction of depr_eu_lag and depr_eu_lag
* (2) interaction of L(1) of depr_eu_lag and depr_eu_lag
* (3) interaction of L(2) of depr_eu_lag and depr_eu_lag
gen square = depr_eu_lag * depr_eu_lag
gen square_lag = L1.depr_eu_lag * L1.depr_eu_lag
gen square_lag_lag = L2.depr_eu_lag * L2.depr_eu_lag
la var square "depr_eu_lag * depr_eu_lag"
la var square_lag "L1.depr_eu_lag * L1.depr_eu_lag"
la var square_lag_lag "L2.depr_eu_lag * L2.depr_eu_lag"

* ------------------------------------------------------------------------------
* REGRESSION

* The goal is to see if price changes depend on different variables.

* Prepared 4 sets of comparison.
* (1) base:  lagged inflation, lagged depreciation;
* (2) fe:    country, age of good, decile of price, number of varieties;
* (3) vat:   value-added tax;
* (4) li:    lags and interactions of "base" variables

* ------------------------------------------------------------------------------

* (1) base: lagged inflation, lagged depreciation
quietly reg pchangef infl_lag depr_eu_lag
est store m1

* (2) fe: country, age of good, decile of price, number of varieties
quietly reg pchangef infl_lag depr_eu_lag ///
	i.ccode
est store m2
quietly reg pchangef infl_lag depr_eu_lag ///
	i.ccode i.age
est store m3
quietly reg pchangef infl_lag depr_eu_lag ///
	i.ccode i.age i.price_decile
est store m4
quietly reg pchangef infl_lag depr_eu_lag ///
	i.ccode i.age i.price_decile i.ijtotal3
est store m5

* (3) vat: value-added tax
quietly reg pchangef infl_lag depr_eu_lag ///
	vatchange
est store m6
quietly reg pchangef infl_lag depr_eu_lag ///
	vatchange L1.vatchange
est store m7
quietly reg pchangef infl_lag depr_eu_lag ///
	vatchange L1.vatchange L2.vatchange
est store m8
quietly reg pchangef infl_lag depr_eu_lag ///
	vatchange_de vatchange_it vatchange_uk
est store m9
quietly reg pchangef infl_lag depr_eu_lag ///
	vatchange_de vatchange_it vatchange_uk ///
	L1.vatchange_de L1.vatchange_it L1.vatchange_uk
est store m10
quietly reg pchangef infl_lag depr_eu_lag ///
	vatchange_de vatchange_it vatchange_uk ///
	L1.vatchange_de L1.vatchange_it L1.vatchange_uk ///
	L2.vatchange_de L2.vatchange_it L2.vatchange_uk
est store m11

* (4) li: lags and interactions of "base" variables
quietly reg pchangef infl_lag depr_eu_lag ///
	square
est store m12
quietly reg pchangef infl_lag depr_eu_lag ///
	square L1.infl_lag L1.depr_eu_lag square_lag
est store m13
quietly reg pchangef infl_lag depr_eu_lag ///
	square L1.infl_lag L1.depr_eu_lag square_lag ///
	L2.infl_lag L2.depr_eu_lag square_lag_lag
est store m14

* ------------------------------------------------------------------------------
* TABLES
* ------------------------------------------------------------------------------

* (1) adding (2) fe: country, age of good, decile of price, number of varieties
outreg2 [m1 m2 m3 m4 m5] ///
	using "`pathname'_fe.xls", replace tex ///
	stats(coef se tstat) paren(se) bracket(tstat) adjr2 /// statistics
	bdec(3) sdec(2) tdec(2) rdec(3) ///
	drop(pchangef) nonotes addnote( ///
	Note: Standard errors in parentheses and t-Statistics in brackets, ///
	Note: *** p<0.01; ** p<0.05; * p<0.1)

* (1) adding (3) vat: value-added tax
outreg2 [m1 m6 m7 m8 m9 m10 m11] ///
	using "`pathname'_vat.xls", replace tex ///
	stats(coef se tstat) paren(se) bracket(tstat) adjr2 /// statistics
	bdec(3) sdec(2) tdec(2) rdec(3) ///
	drop(pchangef) nonotes addnote( ///
	Note: Standard errors in parentheses and t-Statistics in brackets, ///
	Note: *** p<0.01; ** p<0.05; * p<0.1)

* (1) adding (4) li: lags and interactions of "base" variables
outreg2 [m1 m12 m13 m14] ///
	using "`pathname'_li.xls", replace tex ///
	stats(coef se tstat) paren(se) bracket(tstat) adjr2 /// statistics
	bdec(3) sdec(2) tdec(2) rdec(3) ///
	drop(pchangef) nonotes addnote( ///
	Note: Standard errors in parentheses and t-Statistics in brackets, ///
	Note: *** p<0.01; ** p<0.05; * p<0.1)

* ------------------------------------------------------------------------------
* LATEX
* ------------------------------------------------------------------------------

* the "tex" option

* ------------------------------------------------------------------------------
* SUMMARY
* ------------------------------------------------------------------------------

/*

New Variables:

ijtotal3 		"ijtotal recode: 3/max = 3"
vatchange 		"VAT change: All"
vatchange_de 	"VAT change: de"
vatchange_it 	"VAT change: it"
vatchange_uk 	"VAT change: uk"
square 			"depr_eu_lag * depr_eu_lag"
square_lag 		"L1.depr_eu_lag * L1.depr_eu_lag"
square_lag_lag 	"L2.depr_eu_lag * L2.depr_eu_lag"

Output:

table_passthrough_regressions_fe.tex
table_passthrough_regressions_fe.txt
table_passthrough_regressions_fe.xls
table_passthrough_regressions_li.tex
table_passthrough_regressions_li.txt
table_passthrough_regressions_li.xls
table_passthrough_regressions_vat.tex
table_passthrough_regressions_vat.txt
table_passthrough_regressions_vat.xls

*/
