* coordination_data.do
set more off
clear
cls

* ------------------------------------------------------------------------------
* HEADER
* ------------------------------------------------------------------------------
qui do "/Users/xu/Dropbox/XU/03 GD/20 BU/baxter/xu/charity/input/header.do"
local pathname = "./output/coordination_data"


* ------------------------------------------------------------------------------
* INITIALIZATION
* ------------------------------------------------------------------------------
use "./data/ikea_fill_2018.dta", replace
drop if flag > 0

* create duplicate of name
* replace name2 with "group" name using "namegroup_construction"
* if this need to get done over with the stricter "name groups"
* simply use "name" instead of "name2"

gen name2=name
la var name2 "all instances of root name grouped together"
quietly do "./input/namegroup_construction.do"

* ------------------------------------------------------------------------------
* GROUP
* create groups that are defined by name, country, and/or year
* ------------------------------------------------------------------------------

sort y ij name2 ccode2

* Group Definition (1): (year,good_variety) groups
bysort y ij: gen N_yij = _N
bysort y ij: gen i_yij = _n
egen yearij  = group(y ij) 
la var N_yij "total # of goods in each (year,good_variety) group"
la var i_yij "index for good within each (year,good_variety) group"
la var yearij  "numerical index of (year,good_variety) groups"

* Group Definition (2): (year,name) groups
bysort y name2: gen N_yn = _N
bysort y name2: gen i_yn = _n
egen yearn   = group(y name2)
la var N_yn "total # of goods in each (year,name) group"
la var i_yn "index for good within each (year,name) group"
la var yearn   "numerical index of (year,country) groups"

* Group Definition (3): (year,good_variety,country) groups
bysort y ij name2: gen N_yijn = _N
bysort y ij name2: gen i_yijn = _n
egen yearijn = group(y ij name2)
la var N_yijn "total # of goods in each (year,good_variety,name) group"
la var i_yijn "index for good within each (year,good_variety,name) group"
la var yearijn "numerical index of (year,good_variety,name) groups"

* ------------------------------------------------------------------------------
* PRICE CHANGE
* recod price change indicators and levels
* ------------------------------------------------------------------------------

* recode "pcf" to "pcf_99"
* for indicators: decrease=2, unchange=3, increase=5, missing=7
recode pcf (-1=2) (0=3) (1=5) (.=7), gen(pcf_99)
la var pcf_99 "pcf recode: (-1=2) (0=3) (1=5) (.=7)"
la define pcf_99_lbl 2 "Decrease"
la define pcf_99_lbl 3 "No Change", add  
la define pcf_99_lbl 5 "Increase", add 
la define pcf_99_lbl 7 "Missing", add 
la value pcf_99 pcf_99_lbl

* recode "pchangef" to "pchangef_99"
* recode pc level: use big numbers for easy if statement
recode pchangef (.=99), gen(pchangef_99)
la var pchangef_99 "pchangef recode: (.=99)"

* ------------------------------------------------------------------------------
* COUNTRY
* recode country numerical index so country-pair are easier to calssify
*  1: us,  2: uk,  3: ca,  4: fr,  5: it,  6: de,  7: se
* 11: us, 13: uk, 17: ca, 19: fr, 23: it, 29: de, 31: se
* ------------------------------------------------------------------------------

* use Fibonacci numbers to ensure addition uniqueness
recode ccode2 (1=11) (2=13) (3=17) (4=19) (5=23) (6=29) (7=31), gen(ccode_99)
la var ccode_99 "ccode2 recode: 11-us 13-uk 17-ca 19-fr 23-it 29-de 31-se"
la define ccode_99_lbl 11 "US" 
la define ccode_99_lbl 13 "UK", add 
la define ccode_99_lbl 17 "Canada", add 
la define ccode_99_lbl 19 "France", add 
la define ccode_99_lbl 23 "Italy", add 
la define ccode_99_lbl 29 "Germany", add 
la define ccode_99_lbl 31 "Sweden", add
la value ccode_99 ccode_99_lbl

* ------------------------------------------------------------------------------
* CLEAN
* ------------------------------------------------------------------------------

* changing format of year variable so it does not appear as "1-1-2016" in Excel
gen int year = y
la var year "year (int)"
* drop singleton observations here rather than dealing with it in Matlab program
drop if N_yij == 1
* generate numerical index for name2
egen nname = group(name2)
la var nname "numerical index of (name2) groups"

* ------------------------------------------------------------------------------
* EXPORT
* ------------------------------------------------------------------------------

export excel ///
	year ij nname ccode2 ///
	yearij yearn yearijn ///
	N_yij i_yij N_yn i_yn N_yijn i_yijn ///
	pcf_99 pchangef_99 ccode_99 ///
	using "`pathname'.xlsx", firstrow(variables) nolabel replace

* ------------------------------------------------------------------------------
* SUMMARY
* ------------------------------------------------------------------------------

/*

New Variables:

N_yij 				"total # of goods in each (year,good_variety) group"
i_yij 				"index for good within each (year,good_variety) group"
N_yn 				"total # of goods in each (year,name) group"
i_yn 				"index for good within each (year,name) group"
N_yijn 				"total # of goods in each (year,good_variety,name) group"
i_yijn 				"index for good (ij) in (name2,c,y) groups"
yearij  			"numerical index of (year,good_variety) groups"
yearn   			"numerical index of (year,country) groups"
yearijn 			"numerical index of (year,good_variety,name) groups"
pcf_99 				"pcf recode: (-1=2) (0=3) (1=5) (.=7)"
pchangef_99 		"pchangef recode: (.=99)"
ccode_99 			"ccode2 recode: 11-us 13-uk 17-ca 19-fr 23-it 29-de 31-se"
year 				"year (int)"
nname 				"numerical index of (name2) groups"

Output:

coordination_data.xlsx

*/
