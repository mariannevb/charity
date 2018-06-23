* namegroup_data.do
set more off
clear
cls

* ------------------------------------------------------------------------------
* HEADER
* ------------------------------------------------------------------------------
qui do "/Users/xu/Dropbox/XU/03 GD/20 BU/baxter/xu/charity/input/header.do"
local pathname = "./output/namegroup_data"

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

sort name2 c y ij

* Group Definition (1): Name (name2)
bysort name2: gen N_name2 = _N
bysort name2: gen i_name2 = _n
egen nname = group(name2)
la var N_name2 "number-of-obs of good (ij,c,y) in (name2) groups"
la var i_name2 "within-group-index for good (ij,c,y) in (name2) groups"
la var nname "numerical index of (name2) groups"

* Group Definition (2): Name & Country (name2,c)
bysort name2 c: gen N_nc = _N
bysort name2 c: gen i_nc = _n
egen namec = group(name2 c)
la var N_nc "number-of-obs of good (ij,y) in (name2,c) groups"
la var i_nc "within-group-index for good (ij,y) in (name2,c) groups"
la var namec "numerical index of (name2,c) groups"

* Group Definition (3): Name & Year (name2,y)
bysort name2 y: gen N_ny = _N
bysort name2 y: gen i_ny = _n
egen namey = group(name2 y)
la var N_ny "number-of-obs of good (ij,c) in (name2,y) groups"
la var i_ny "within-group-index for good (ij,c) in (name2,y) groups"
la var namey "numerical index of (name2,y) groups"

* Group Definition (4): Name & Country & Year (name2,c,y) groups
bysort name2 c y: gen N_ncy = _N
bysort name2 c y: gen i_ncy = _n
egen namecy = group(name2 c y)
la var N_ncy "number-of-obs of good (ij,c,y) in (name2,c,y) groups"
la var i_ncy "within-group-index for good (ij) in (name2,c,y) groups"
la var namecy "numerical index of (name2,c,y) groups"

* ------------------------------------------------------------------------------
* PRICE CHANGE
* recod price change indicators and levels
* ------------------------------------------------------------------------------

* recode "pcf" to "pcf_99"
* recode "pc_pennyf" to "pc_pennyf_99"
* for indicators: decrease=2, unchange=3, increase=5, missing=7
recode pcf (-1=2) (0=3) (1=5) (.=7), gen(pcf_99)
la var pcf_99 "pcf recode: (-1=2) (0=3) (1=5) (.=7)"
la define pcf_99_lbl 2 "Decrease"
la define pcf_99_lbl 3 "No Change", add  
la define pcf_99_lbl 5 "Increase", add 
la define pcf_99_lbl 7 "Missing", add 
la value pcf_99 pcf_99_lbl

recode pc_pennyf (-1=2) (0=3) (1=5) (.=7), gen(pc_pennyf_99)
la var pc_pennyf_99 "pc_pennyf recode: (-1=2) (0=3) (1=5) (.=7)"
la define pc_pennyf_99_lbl 2 "Decrease >=1 LCU"
la define pc_pennyf_99_lbl 3 "No Change", add  
la define pc_pennyf_99_lbl 5 "Increase >=1 LCU", add
la define pc_pennyf_99_lbl 7 "Missing", add
la value pc_pennyf_99 pc_pennyf_lbl_99

* recode "pchangef" to "pchangef_99"
* recode "pchange_pennyf" to "pchange_pennyf_99"
* recode pc level: use big numbers for easy if statement
recode pchangef (.=99), gen(pchangef_99)
la var pchangef_99 "pchangef recode: (.=99)"
recode pchange_pennyf (.=99), gen(pchange_pennyf_99)
la var pchange_pennyf_99 "pchange_pennyf recode: (.=99)"

* ------------------------------------------------------------------------------
* CLEAN
* ------------------------------------------------------------------------------

* changing format of year variable so it does not appear as "1-1-2016" in Excel
gen int year = y
la var year "year (int)"
* drop singleton observations here rather than dealing with it in Matlab program
drop if N_ncy == 1

* ------------------------------------------------------------------------------
* EXPORT
* ------------------------------------------------------------------------------

export excel ///
	name2 ccode2 year ij ///
	nname namec namey namecy ///
	N_name2 i_name2 N_nc i_nc N_ny i_ny N_ncy i_ncy ///
	pcf_99 pc_pennyf_99 pchangef_99 pchange_pennyf_99 ///
	using "`pathname'.xlsx", firstrow(variables) nolabel replace

* ------------------------------------------------------------------------------
* SUMMARY
* ------------------------------------------------------------------------------

/*

New Variables:

N_nc 					"# obs in (name2,c) groups"
i_nc 					"index for good (ij,y) in (name2,c) groups"
N_ny 					"# obs in (name2,y) groups"
i_ny 					"index for good (ij,c) in (name2,y) groups"
N_ncy 					"# obs in (name2,c,y) groups"
i_ncy 					"index for good (ij) in (name2,c,y) groups"
nname 					"numerical index of (name2) groups"
namec 					"numerical index of (name2,c) groups"
namey 					"numerical index of (name2,y) groups"
namecy 					"numerical index of (name2,c,y) groups"
pcf_99 					"pcf recode: (-1=2) (0=3) (1=5) (.=7)"
pc_pennyf_99 			"pc_pennyf recode: (-1=2) (0=3) (1=5) (.=7)"
pchangef_99 			"pchangef recode: (.=99)"
pchange_pennyf_99 		"pchange_pennyf recode: (.=99)"
year 					"year (int)"

Output:

namegroup_data.xlsx

*/
