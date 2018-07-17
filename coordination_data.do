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

* keep only relevant variables:
* (1) name group variables
* (2) price change indicators and levels
keep ///
	name y ij ccode2 ///
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

sort y ij name2 ccode2
duplicates report y ij name2 ccode2

* Group Definition (1): (year,good_variety) groups
bysort y ij: gen N_yij = _N
bysort y ij: gen i_yij = _n
egen yearij  = group(y ij)
la var N_yij  "total # of goods in each (year,good_variety) group"
la var i_yij  "index for good within each (year,good_variety) group"
la var yearij "numerical index of (year,good_variety) groups"

* Group Definition (2): (year,name) groups
bysort y name2: gen N_yn = _N
bysort y name2: gen i_yn = _n
egen yearn   = group(y name2)
la var N_yn  "total # of goods in each (year,name) group"
la var i_yn  "index for good within each (year,name) group"
la var yearn "numerical index of (year,country) groups"

* Group Definition (3): (year,good_variety,country) groups
bysort y ij name2: gen N_yijn = _N
bysort y ij name2: gen i_yijn = _n
egen yearijn = group(y ij name2)
la var N_yijn  "total # of goods in each (year,good_variety,name) group"
la var i_yijn  "index for good within each (year,good_variety,name) group"
la var yearijn "numerical index of (year,good_variety,name) groups"

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
replace pchange_unitf = .  if pchangef <= -1
replace pchange_unitf = .  if pchangef >=  1
la var pchange_unitf "price change magnitude for changes <=1 LCU"
* recode "pchange_allf" to "pchange_allf_99"
recode pchange_unitf (.=99), gen(pchange_unitf_99)
la var pchange_unitf_99 "pchange_unitf recode: (.=99)"

* ------------------------------------------------------------------------------
* COUNTRY
* recode country numerical index so country-pair are easier to calssify
*  1: us,  2: uk,  3: ca,  4: fr,  5: it,  6: de,  7: se
* 17: us, 19: uk, 23: ca, 29: fr, 31: it, 37: de, 41: se
* ------------------------------------------------------------------------------

* use Fibonacci numbers to ensure addition uniqueness
recode ccode2 (1=17) (2=19) (3=23) (4=29) (5=31) (6=37) (7=41), gen(ccode_99)
la var ccode_99 "ccode2 recode: 17-us 19-uk 23-ca 29-fr 31-it 37-de 41-se"
la define ccode_99_lbl 17 "US"
la define ccode_99_lbl 19 "UK"      , add
la define ccode_99_lbl 23 "Canada"  , add
la define ccode_99_lbl 29 "France"  , add
la define ccode_99_lbl 31 "Italy"   , add
la define ccode_99_lbl 37 "Germany" , add
la define ccode_99_lbl 41 "Sweden"  , add
la value ccode_99 ccode_99_lbl

* ------------------------------------------------------------------------------
* CLEAN
* ------------------------------------------------------------------------------

* changing format of year variable so it does not appear as "1-1-2016" in Excel
gen int year = y
la var year "year (int)"
* drop singleton observations at most disaggregate group definition
drop if N_yij == 1
* generate numerical index for name2
egen nname = group(name2)
la var nname "numerical index of (name2) groups"

keep ///
	nname year ij ccode2 ccode_99 ///
	yearij N_yij i_yij ///
	yearn N_yn i_yn ///
	yearijn N_yijn i_yijn ///
	pcf pchangef ///
	pc_pennyf pchange_pennyf ///
	pc_allf pchange_allf ///
	pc_unitf pchange_unitf ///
	pcf_99 pchangef_99 ///
	pc_pennyf_99 pchange_pennyf_99 ///
	pc_allf_99 pchange_allf_99 ///
	pc_unitf_99 pchange_unitf_99

order ///
	nname year ij ccode2 ccode_99 ///
	yearij N_yij i_yij ///
	yearn N_yn i_yn ///
	yearijn N_yijn i_yijn ///
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

yearij            " numerical index of (year,good_variety) groups             "
N_yij             " total # of goods in each (year,good_variety) group        "
i_yij             " index for good within each (year,good_variety) group      "
yearn             " numerical index of (year,country) groups                  "
N_yn              " total # of goods in each (year,name) group                "
i_yn              " index for good within each (year,name) group              "
yearijn           " numerical index of (year,good_variety,name) groups        "
N_yijn            " total # of goods in each (year,good_variety,name) group   "
i_yijn            " index for good within each (year,good_variety,name) group "

pcf               " pc indicator: decrease (-1) increase (1)                  "
pc_pennyf         " pc indicator: only outside-unit change                    "
pc_allf           " pc indicator: indicate within- & outside-unit change      "
pc_unitf          " pc indicator: only within-unit change                     "
pchangef          " price change magnitude (all LCU)                          "
pchange_pennyf    " price change magnitude (> 1 LCU)                          "
pchange_allf      " price change magnitude (= pchangef)                       "
pchange_unitf     " price change magnitude (<=1 LCU)                          "
pcf_99            " pcf recode: (-1=2) (0=3) (1=5) (.=7)                      "
pc_pennyf_99      " pc_pennyf recode: (-1=2) (0=3) (1=5) (.=7)                "
pc_allf_99        " pc_allf recode: (-2=2) (-1=3) (0=5) (1=7) (2=11) (.=13)   "
pc_unitf_99       " pc_unitf recode: (-1=2) (0=3) (1=5) (.=7)                 "
pchangef_99       " pchangef recode: (.=99)                                   "
pchange_pennyf_99 " pchange_pennyf recode: (.=99)                             "
pchange_allf_99   " pchange_allf recode: (.=99)                               "
pchange_unitf_99  " pchange_unitf recode: (.=99)                              "

ccode_99          " ccode2 recode: 17-us 19-uk 23-ca 29-fr 31-it 37-de 41-se  "
year              " year (int)                                                "
nname             " numerical index of (name2) groups                         "
name2             " all instances of root name grouped together               "

Output:

coordination_data.xlsx

*/
