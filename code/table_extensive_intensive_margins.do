* ------------------------------------------------------------------------------
* table_extensive_intensive_margins.do
* This file creates extensive and intensive margins of price changes
* ------------------------------------------------------------------------------
set more off
clear
cls

* ------------------------------------------------------------------------------
* HEADER
* ------------------------------------------------------------------------------
qui do "/Users/xu/Dropbox/XU/03 GD/20 BU/baxter/xu/charity/input/header.do"

local pathname = "./output/table_extensive_intensive_margins"
ssc install tabout

* ------------------------------------------------------------------------------
* INITIALIZATION
* ------------------------------------------------------------------------------
use "./data/ikea_fill_2018.dta", clear
drop if flag>0

* keep only relevant variables:
* (1) price change indicators and levels
* (2) sorting variables: year, country, age of good, decile of price
keep y ccode2 age price_decile ijtotal pcf pc_pennyf pchangef pchange_pennyf

* ------------------------------------------------------------------------------
* VARIABLES
* ------------------------------------------------------------------------------

* deal with price change variables first

* re-label "pcf"
la var pcf "price change indicator for fill-forward data"
la define pcf_lbl -1 "Decrease"
la define pcf_lbl  0 "No Change", add  
la define pcf_lbl  1 "Increase", add 
la value pcf pcf_lbl

* re-label "pc_pennyf"
* penny version of pcf
* difference from pcf: 0 if price change < 1 LCU
la var pc_pennyf "penny version of pcf: 0 = Changes <1 LCU"
la define pc_pennyf_lbl -1 "Decrease >=1 LCU"
la define pc_pennyf_lbl  0 "No Change", add  
la define pc_pennyf_lbl  1 "Increase >=1 LCU", add
la value pc_pennyf pc_pennyf_lbl

* generate "pc_allf"
* combine penny and non-penny price changes into one variable
* use -2,-1,0,1,2 to indicate
gen pc_allf = pcf + pc_pennyf
la var pc_allf "combine pcf and pc_pennyf"
la define pc_allf_lbl -2 "Decrease >=1 LCU"
la define pc_allf_lbl -1 "Decrease <1 LCU", add  
la define pc_allf_lbl  0 "No Change", add  
la define pc_allf_lbl  1 "Increase < LCU", add  
la define pc_allf_lbl  2 "Increase >=1 LCU", add 
la value pc_allf pc_allf_lbl

* deal with sorting variables second

* re-label 'ccode2'
la define ccode2_lbl 1 "US" 
la define ccode2_lbl 2 "UK", add 
la define ccode2_lbl 3 "Canada", add 
la define ccode2_lbl 4 "France", add 
la define ccode2_lbl 5 "Italy", add 
la define ccode2_lbl 6 "Germany", add 
la define ccode2_lbl 7 "Sweden", add
la value ccode2 ccode2_lbl

* re-code 'age' to 'age7'
* group age 7,...,max to 7+
* recode only changed values
recode age (7/max = 7), gen(age7)
la var age7 "age recode: 7/max = 7"
la define age7_lbl 1 "1"
la define age7_lbl 2 "2", add  
la define age7_lbl 3 "3", add  
la define age7_lbl 4 "4", add  
la define age7_lbl 5 "5", add  
la define age7_lbl 6 "6", add  
la define age7_lbl 7 "7+", add
la value age7 age7_lbl

* re-code 'ijtotal' to 'ijtota3'
* group ijtotal 3,...,max to 3+
* recode only changed values
recode ijtotal (3/max = 3), gen(ijtotal3)
la var ijtotal3 "ijtotal recode: 3/max = 3"
la define ijtotal3_lbl 1 "1"
la define ijtotal3_lbl 2 "2", add  
la define ijtotal3_lbl 3 "3+", add  
la value ijtotal3 ijtotal3_lbl

* generate 'pchangef100'
* use percentages in intensive margins
gen pchangef100 = 100 * pchangef
la var pchangef100 "pchangef in percentages"

* ------------------------------------------------------------------------------
* TABLES
* ------------------------------------------------------------------------------

* extensive margins table
tabout ///
	y ccode2 age7 price_decile ijtotal3 /// row variables
	pc_allf using "`pathname'_ext.xls" , replace ///
	style(tab) cells(row) format(2) layout(cb) ptotal(single) ///
	h1("Extensive Margins: Price Changes By Directions (%)")

* intensive margins table
* (1) all non-zero and total
* (2) only  <1 LCU total
* (2) only >=1 LCU total
tabout ///
	y ccode2 age7 price_decile ijtotal3 /// row variables
	pc_allf if (abs(pc_allf) >= 1) using "`pathname'_int.xls" , replace ///
	sum cells(mean pchangef100) ///
	style(tab) format(2) layout(cb) ptotal(single) ///
	h1("Intensive Margins: Magnitudes of Price Changes By Directions (%)")
tabout ///
	y ccode2 age7 price_decile ijtotal3 /// row variables
	pcf if (abs(pcf) >= 1) using "`pathname'_int.xls" , append ///
	sum cells(mean pchangef100) ///
	style(tab) format(2) layout(cb) ptotal(single) ///
	h1("Intensive Margins: Magnitudes of Price Changes By Directions (%)")

* ------------------------------------------------------------------------------
* LATEX
* ------------------------------------------------------------------------------

tabout ///
	y ccode2 age7 price_decile ijtotal3 /// row variables
	pc_allf using "`pathname'_ext.tex" , replace ///
	style(tex) cells(row) format(2) layout(cb) ptotal(single) ///
	h1("Extensive Margins: Price Changes By Directions (%)")
tabout ///
	y ccode2 age7 price_decile ijtotal3 /// row variables
	pc_allf if (abs(pc_allf) >= 1) using "`pathname'_int.tex" , replace ///
	sum cells(mean pchangef100) ///
	style(tex) format(2) layout(cb) ptotal(single) ///
	h1("Intensive Margins: Magnitudes of Price Changes By Directions (%)")
tabout ///
	y ccode2 age7 price_decile ijtotal3 /// row variables
	pcf if (abs(pcf) >= 1) using "`pathname'_int.tex" , append ///
	sum cells(mean pchangef100) ///
	style(tex) format(2) layout(cb) ptotal(single) ///
	h1("Intensive Margins: Magnitudes of Price Changes By Directions (%)")
	
* ------------------------------------------------------------------------------
* SUMMARY
* ------------------------------------------------------------------------------

/*

New Variables:

pc_allf		"combine pcf and pc_pennyf"
age7		"age recode: 7/max = 7"
ijtotal3 	"ijtotal recode: 3/max = 3"
pchangef100 "pchangef in percentages"

Output:

"table_extensive_intensive_margins_int.xls"
"table_extensive_intensive_margins_ext.xls"
"table_extensive_intensive_margins_int.tex"
"table_extensive_intensive_margins_ext.tex"

*/
