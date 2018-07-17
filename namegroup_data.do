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

* keep only relevant variables:
* (1) name group variables
* (2) price change indicators and levels
keep ///
	name ccode2 y ij ///
	pcf pc_pennyf pchangef pchange_pennyf

* ------------------------------------------------------------------------------
* NAME DUPLICATE
* ------------------------------------------------------------------------------
* create duplicate of name
* replace name2 with "group" name using "namegroup_construction.do"
* if this need to get done over with the stricter "name groups"
* simply use "name" instead of "name2"
gen name2=name
la var name2 "all instances of root name grouped together"
quietly do "./input/namegroup_construction.do"

* ------------------------------------------------------------------------------
* GROUP
* create groups that are defined by name, country, and/or year
* ------------------------------------------------------------------------------
sort name2 ccode2 y ij
duplicates report name2 ccode2 y ij

* Group Definition (1): Name (name2)
bysort name2: gen N_name2 = _N
bysort name2: gen i_name2 = _n
egen nname = group(name2)
la var N_name2 "number-of-obs of good (ij,ccode2,y) in (name2) groups"
la var i_name2 "within-group-index for good (ij,ccode2,y) in (name2) groups"
la var nname "numerical index of (name2) groups"

* Group Definition (2): Name & Country (name2,ccode2)
bysort name2 ccode2: gen N_nc = _N
bysort name2 ccode2: gen i_nc = _n
egen namec = group(name2 ccode2)
la var N_nc "number-of-obs of good (ij,y) in (name2,ccode2) groups"
la var i_nc "within-group-index for good (ij,y) in (name2,ccode2) groups"
la var namec "numerical index of (name2,ccode2) groups"

* Group Definition (3): Name & Year (name2,y)
bysort name2 y: gen N_ny = _N
bysort name2 y: gen i_ny = _n
egen namey = group(name2 y)
la var N_ny "number-of-obs of good (ij,ccode2) in (name2,y) groups"
la var i_ny "within-group-index for good (ij,ccode2) in (name2,y) groups"
la var namey "numerical index of (name2,y) groups"

* Group Definition (4): Name & Country & Year (name2,ccode2,y) groups
bysort name2 ccode2 y: gen N_ncy = _N
bysort name2 ccode2 y: gen i_ncy = _n
egen namecy = group(name2 ccode2 y)
la var N_ncy "number-of-obs of good (ij,ccode2,y) in (name2,ccode2,y) groups"
la var i_ncy "within-group-index for good (ij) in (name2,ccode2,y) groups"
la var namecy "numerical index of (name2,ccode2,y) groups"

* ------------------------------------------------------------------------------
* PRICE CHANGE
* recode price change indicators and levels
*
* four types of price change indicators are constructed
* ______________________________________________________________________________
* price change | (-infty,-1) | [-1,0) | [0,0] | (0,1] | (1,+infty) | Missing
* pcf          | -1          | -1     | 0     | 1     | 1          | .
* pc_pennyf    | -1          | 0      | 0     | 0     | 1          | .
* pc_allf      | -2          | -1     | 0     | 1     | 2          | .
* pc_unitf     | .           | -1     | 0     | 1     | .          | .
* ______________________________________________________________________________
* the steps are to
* (1) recode price change indicators to prime numbers
* (2) recode price change levels
* ------------------------------------------------------------------------------

* (1) price change definition 1
* recode "pcf" to "pcf_99"
* for indicators: use prime numbers for uniqueness
la var pcf "pc indicator: decrease (-1) increase (1)"
recode pcf (-1=2) (0=3) (1=5) (.=7), gen(pcf_99)
la var pcf_99 "pcf recode: (-1=2) (0=3) (1=5) (.=7)"
la define pcf_99_lbl 2 "Decrease"
la define pcf_99_lbl 3 "No Change" , add
la define pcf_99_lbl 5 "Increase"  , add
la define pcf_99_lbl 7 "Missing"   , add
la value pcf_99 pcf_99_lbl
* recode "pchangef" to "pchangef_99"
* for levels: use big numbers for easy if statement
la var pchangef "price change magnitude (all LCU)"
recode pchangef (.=99), gen(pchangef_99)
la var pchangef_99 "pchangef recode: (.=99)"

* (2) price change definition 2
* recode "pc_pennyf" to "pc_pennyf_99"
* for indicators: use prime numbers for uniqueness
la var pc_pennyf "pc indicator: only outside-unit change"
recode pc_pennyf (-1=2) (0=3) (1=5) (.=7), gen(pc_pennyf_99)
la var pc_pennyf_99 "pc_pennyf recode: (-1=2) (0=3) (1=5) (.=7)"
la define pc_pennyf_99_lbl 2 "Decrease > 1 LCU"
la define pc_pennyf_99_lbl 3 "No Change"        , add
la define pc_pennyf_99_lbl 5 "Increase > 1 LCU" , add
la define pc_pennyf_99_lbl 7 "Missing"          , add
la value pc_pennyf_99 pc_pennyf_99_lbl
* recode "pchange_pennyf" to "pchange_pennyf_99"
* for levels: use big numbers for easy if statement
la var pchange_pennyf "price change magnitude (> 1 LCU)"
recode pchange_pennyf (.=99), gen(pchange_pennyf_99)
la var pchange_pennyf_99 "pchange_pennyf recode: (.=99)"

* (3) price change definition 3
* generate "pc_allf": indicate both changes
* decrease (>=1) = -2,
* decrease ( <1) = -1,
* nochange ( =0) =  0,
* increase ( <1) =  1,
* increase (>=1) =  2,
* missing        =  .,
gen pc_allf = pcf + pc_pennyf
la var pc_allf "pc indicator: indicate within- & outside-unit change"
* recode "pc_allf" to "pc_allf_99": use prime numbers for uniqueness
* decrease (>=1) =  2,
* decrease ( <1) =  3,
* nochange ( =0) =  5,
* increase ( <1) =  7,
* increase (>=1) = 11,
* missing        = 13,
recode pc_allf (-2=2) (-1=3) (0=5) (1=7) (2=11) (.=13), gen(pc_allf_99)
la var pc_allf_99 "pc_allf recode: (-2=2) (-1=3) (0=5) (1=7) (2=11) (.=13)"
la define pc_allf_99_lbl  2 "Decrease > 1 LCU"
la define pc_allf_99_lbl  3 "Decrease <=1 LCU" , add
la define pc_allf_99_lbl  5 "No Change"        , add
la define pc_allf_99_lbl  7 "Increase <=1 LCU" , add
la define pc_allf_99_lbl 11 "Increase > 1 LCU" , add
la define pc_allf_99_lbl 13 "Missing"          , add
la value pc_allf_99 pc_allf_99_lbl
* generate "pchange_allf": use price change
gen pchange_allf = pchangef
la var pchange_allf "price change magnitude (= pchangef)"
* recode "pchange_allf" to "pchange_allf_99"
recode pchange_allf (.=99), gen(pchange_allf_99)
la var pchange_allf_99 "pchange_allf recode: (.=99)"

* (4) price change definition 4
* generate "pc_unitf": indicate only within-unit change
* decrease (<1) = -1,
* nochange (=0) =  0,
* increase (<1) =  1,
* missing       =  .,
recode pc_allf (-2=.) (2=.), gen(pc_unitf)
la var pc_unitf "pc indicator: only within-unit change"
* recode "pc_unitf" to "pc_unitf_99": use prime numbers for uniqueness
* decrease (<1) = 2,
* nochange (=0) = 3,
* increase (<1) = 5,
* missing       = 7,
recode pc_unitf (-1=2) (0=3) (1=5) (.=7), gen(pc_unitf_99)
la var pc_unitf_99 "pc_unitf recode: (-1=2) (0=3) (1=5) (.=7)"
la define pc_unitf_99_lbl  2 "Decrease <=1 LCU"
la define pc_unitf_99_lbl  3 "No Change"        , add
la define pc_unitf_99_lbl  5 "Increase <=1 LCU" , add
la define pc_unitf_99_lbl  7 "Missing"          , add
la value pc_unitf_99 pc_unitf_99_lbl
* generate "pchange_allf": use price change
gen pchange_unitf = pchangef
replace pchange_unitf = .  if pc_allf < -1
replace pchange_unitf = .  if pc_allf >  1
la var pchange_unitf "price change magnitude for changes <=1 LCU"
* recode "pchange_allf" to "pchange_allf_99"
recode pchange_unitf (.=99), gen(pchange_unitf_99)
la var pchange_unitf_99 "pchange_unitf recode: (.=99)"

* ------------------------------------------------------------------------------
* CLEAN
* ------------------------------------------------------------------------------

* changing format of year variable so it does not appear as "1-1-2016" in Excel
gen int year = y
la var year "year (int)"
* drop singleton observations at most disaggregate group definition
drop if N_ncy == 1

keep ///
	name2 ccode2 year ij ///
	nname N_name2 i_name2 ///
	namec N_nc i_nc ///
	namey N_ny i_ny ///
	namecy N_ncy i_ncy ///
	pcf pchangef ///
	pc_pennyf pchange_pennyf ///
	pc_allf pchange_allf ///
	pc_unitf pchange_unitf ///
	pcf_99 pchangef_99 ///
	pc_pennyf_99 pchange_pennyf_99 ///
	pc_allf_99 pchange_allf_99 ///
	pc_unitf_99 pchange_unitf_99

order ///
	name2 ccode2 year ij ///
	nname N_name2 i_name2 ///
	namec N_nc i_nc ///
	namey N_ny i_ny ///
	namecy N_ncy i_ncy ///
	pcf pchangef ///
	pc_pennyf pchange_pennyf ///
	pc_allf pchange_allf ///
	pc_unitf pchange_unitf ///
	pcf_99 pchangef_99 ///
	pc_pennyf_99 pchange_pennyf_99 ///
	pc_allf_99 pchange_allf_99 ///
	pc_unitf_99 pchange_unitf_99

* ------------------------------------------------------------------------------
* EXPORT
* ------------------------------------------------------------------------------

sum
des
export ///
	excel using "`pathname'.xlsx", firstrow(variables) nolabel replace

* ------------------------------------------------------------------------------
* SUMMARY
* ------------------------------------------------------------------------------

/*

New Variables:

N_nc              " # obs in (name2,ccode2) groups                          "
i_nc              " index for good (ij,y) in (name2,ccode2) groups          "
N_ny              " # obs in (name2,y) groups                               "
i_ny              " index for good (ij,ccode2) in (name2,y) groups          "
N_ncy             " # obs in (name2,ccode2,y) groups                        "
i_ncy             " index for good (ij) in (name2,ccode2,y) groups          "
nname             " numerical index of (name2) groups                       "
namec             " numerical index of (name2,ccode2) groups                "
namey             " numerical index of (name2,y) groups                     "
namecy            " numerical index of (name2,ccode2,y) groups              "

pcf               " pc indicator: decrease (-1) increase (1)                "
pc_pennyf         " pc indicator: only outside-unit change                  "
pc_allf           " pc indicator: indicate within- & outside-unit change    "
pc_unitf          " pc indicator: only within-unit change                   "
pchangef          " price change magnitude (all LCU)                        "
pchange_pennyf    " price change magnitude (> 1 LCU)                        "
pchange_allf      " price change magnitude (= pchangef)                     "
pchange_unitf     " price change magnitude (<=1 LCU)                        "
pcf_99            " pcf recode: (-1=2) (0=3) (1=5) (.=7)                    "
pc_pennyf_99      " pc_pennyf recode: (-1=2) (0=3) (1=5) (.=7)              "
pc_allf_99        " pc_allf recode: (-2=2) (-1=3) (0=5) (1=7) (2=11) (.=13) "
pc_unitf_99       " pc_unitf recode: (-1=2) (0=3) (1=5) (.=7)               "
pchangef_99       " pchangef recode: (.=99)                                 "
pchange_pennyf_99 " pchange_pennyf recode: (.=99)                           "
pchange_allf_99   " pchange_allf recode: (.=99)                             "
pchange_unitf_99  " pchange_unitf recode: (.=99)                            "

year              " year (int)                                              "

Output:

namegroup_data.xlsx

*/
