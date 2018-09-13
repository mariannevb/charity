* pricecoordination_data.do
* ==============================================================================
* This script file prepares dataset for future analyses.
* Specifically, the dataset shall contain three set of variables.
* (1) identification (ID): name, country, year, good and/or variety
* (2) group (GP): group index (grp), number of obs (num), index of obs (idx)
* (3) price-change (PC): price-change indicators (ind) and levels (lev)
* ==============================================================================
set more off
clear
cls

* ==============================================================================
* HEADER
* ==============================================================================

qui do "/Users/xu/Dropbox/XU/03 GD/20 BU/baxter/xu/charity/input/header.do"
local pathname = "./output/pricecoordination_data"

* ==============================================================================
* INITIALIZATION
* ==============================================================================
* use fill data
* there might be need to modify './data/ikea_select_2018.do'
* to incorporate 'median level' variety variable

use "./data/ikea_fill_2018.dta", replace
drop if flag > 0

* keep only relevant variables:
* (1) name group variables
* (2) price change indicators and levels

keep ///
	name ccode2 y i j ij ijc ///
	pcf pc_pennyf pchangef pchange_pennyf

* ==============================================================================
* 1 IDENTIFICATION VARIABLES
*
* the id variables are generally name, country, year, good and/or variety
* need to construct two additional variables first
* (1) an aggregated name level 'name2'
* (2) an aggregated variety level 'j2'
* 'j2' is a quasi-variety level that is more aggregated than variety 'j'
* want 'j2' to capture some degree of variety within a good 'i'
* such as color, material; but not too detailed: white, oak
* then report duplicates using id variables
* ==============================================================================

* Name Reconstruction: name2
* create duplicate of name (name2) 'aggregate' name group variable
* replace name2 with "group" name using "namegroup_construction.do"
* if this need to get done over with the stricter "name groups"
* simply use "name" instead of "name2", the aggregated level of name
gen name2=name
la var name2 "all instances of root name grouped together"
quietly do "./input/namegroup_construction.do"

* Variety Reconstruction: j2, j3
* create variety level that is between good 'i' and variety 'j'
gen j2=j
gen j3=j
la var j2 "aggregated variety j"
la var j3 "aggregated variety j"
quietly do "./input/varietygroup_construction.do"

tab j2
tab j3
replace j3 = 2 if j == 233
tab j2
tab j3

* ------------------------------------------------------------------------------
* Additional steps that formats id variables: name, country, year
* ------------------------------------------------------------------------------

* generate numerical index for name2
egen name3 = group(name2)
la var name3 "name2 recode: numerical index of name2 groups"
* generate numerical index for j2
* egen jj = group(j2)
* la var jj "j2 recode: numerical index of j2 groups"
* generate numerical index for j3
* egen jjj = group(j3)
* la var jjj "j3 recode: numerical index of j3 groups"

* changing format of year variable so it does not appear as "1-1-2016" in Excel
gen int year = y
la var year "year"
* use prime numbers to recode country code
*  1: us,  2: uk,  3: ca,  4: fr,  5: it,  6: de,  7: se
* 17: us, 19: uk, 23: ca, 29: fr, 31: it, 37: de, 41: se
recode ccode2 (1=17) (2=19) (3=23) (4=29) (5=31) (6=37) (7=41), gen(ccode3)
la var ccode3 "ccode2 recode: 17-us 19-uk 23-ca 29-fr 31-it 37-de 41-se"
la define ccode3_lbl 17 "US"
la define ccode3_lbl 19 "UK"      , add
la define ccode3_lbl 23 "Canada"  , add
la define ccode3_lbl 29 "France"  , add
la define ccode3_lbl 31 "Italy"   , add
la define ccode3_lbl 37 "Germany" , add
la define ccode3_lbl 41 "Sweden"  , add
la value ccode3 ccode3_lbl
* ------------------------------------------------------------------------------

* Summarize id variables
* specify id variables for obs: name, country, year, good and/or variety
sort year name3 ccode3 i j j2 j3 ij ijc
* check for duplicates: note 'i' and 'j' cannot uniquely identify
* even though: egen ij  = group(i j);  egen ijc = group(ij c)
duplicates report year name3 ij
duplicates report year ccode3 ij

duplicates report year name3 ccode3 i
duplicates report year name3 ccode3 i j2
duplicates report year name3 ccode3 i j3

keep ///
	year ccode3 name3 i j j2 j3 ij ijc ///
	pcf pc_pennyf pchangef pchange_pennyf
order ///
	year ccode3 name3 i j j2 j3 ij ijc ///
	pcf pc_pennyf pchangef pchange_pennyf

* ==============================================================================
* 2 GROUP VARIABLES
*
* define group: ten types
* ------------------------------------------------------
* | variables | year | name | country | good | variety |
* ------------------------------------------------------
* | group 1   | yes  | yes  |         |      |         |
* | group 2   | yes  |      |         | yes  |         |
* | group 3   | yes  |      |         | yes  | yes     |
* | group 4   | yes  | yes  |         | yes  |         |
* | group 5   | yes  | yes  |         | yes  | yes     |
* ------------------------------------------------------
* | group a   |      | yes  | yes     |      |         |
* | group b   |      | yes  |         | yes  |         |
* | group c   | yes  | yes  |         |      |         |
* | group d   | yes  | yes  | yes     |      |         |
* | group e   | yes  | yes  | yes     | yes  |         |
* ------------------------------------------------------
* the choices of group definitions are variant, but the goals here are
* (1) use 1,2,3, ... to study the coordination across countries/regions
* (1) use a,b,c, ... to study the coordination within name groups
* one thing to keep in mind is that, when analyzing coordination
* according to the definition of group, drop singleton obs
* therefore, cannot define a group using id vars that uniquely pins down obs
* i.e., use year, name, country, good and variety to define a group
*
* ==============================================================================

* ------------------------------------------------------------------------------
* Group Definition (1) - (5)
* ------------------------------------------------------------------------------

* Group Definition (1): (year,name)
egen                   grp_yn = group(year name3)
bysort year name3: gen num_yn = _N
bysort year name3: gen idx_yn = _n
la var grp_yn " numerical indexes for (year,name) groups    "
la var num_yn " number of obs within each (year,name) group "
la var idx_yn " index for obs within each (year,name) group "

* Group Definition (2): (year,good)
egen               grp_yi = group(year i)
bysort year i: gen num_yi = _N
bysort year i: gen idx_yi = _n
la var grp_yi " numerical indexes for (year,good) groups    "
la var num_yi " number of obs within each (year,good) group "
la var idx_yi " index for obs within each (year,good) group "

* Group Definition (3): (year,good-variety)
egen                grp_yij = group(year ij)
bysort year ij: gen num_yij = _N
bysort year ij: gen idx_yij = _n
la var grp_yij " numerical indexes for (year,good-variety) groups    "
la var num_yij " number of obs within each (year,good-variety) group "
la var idx_yij " index for obs within each (year,good-variety) group "

* Group Definition (4): (year,name,good)
egen                     grp_yni = group(year name3 i)
bysort year name3 i: gen num_yni = _N
bysort year name3 i: gen idx_yni = _n
la var grp_yni " numerical indexes for (year,name,good) groups    "
la var num_yni " number of obs within each (year,name,good) group "
la var idx_yni " index for obs within each (year,name,good) group "

* Group Definition (5): (year,name,good-variety)
egen                      grp_ynij = group(year name3 ij)
bysort year name3 ij: gen num_ynij = _N
bysort year name3 ij: gen idx_ynij = _n
la var grp_ynij " numerical indexes for (year,name,good-variety) groups    "
la var num_ynij " number of obs within each (year,name,good-variety) group "
la var idx_ynij " index for obs within each (year,name,good-variety) group "

* ------------------------------------------------------------------------------
* Group Definition (a) - (e)
* ------------------------------------------------------------------------------

* Group Definition (a): (name,country)
egen                     grp_nc = group(name3 ccode3)
bysort name3 ccode3: gen num_nc = _N
bysort name3 ccode3: gen idx_nc = _n
la var grp_nc " numerical indexes for (name,country) groups    "
la var num_nc " number of obs within each (name,country) group "
la var idx_nc " index for obs within each (name,country) group "

* Group Definition (b): (name,good)
egen                grp_ni = group(name3 i)
bysort name3 i: gen num_ni = _N
bysort name3 i: gen idx_ni = _n
la var grp_ni " numerical indexes for (name,good) groups    "
la var num_ni " number of obs within each (name,good) group "
la var idx_ni " index for obs within each (name,good) group "

* Group Definition (c): (name,year)
egen                   grp_ny = group(name3 year)
bysort name3 year: gen num_ny = _N
bysort name3 year: gen idx_ny = _n
la var grp_ny " numerical indexes for (name,year) groups    "
la var num_ny " number of obs within each (name,year) group "
la var idx_ny " index for obs within each (name,year) group "

* Group Definition (d): (name,country,year)
egen                          grp_ncy = group(name3 ccode3 year)
bysort name3 ccode3 year: gen num_ncy = _N
bysort name3 ccode3 year: gen idx_ncy = _n
la var grp_ncy " numerical indexes for (name,country,year) groups    "
la var num_ncy " number of obs within each (name,country,year) group "
la var idx_ncy " index for obs within each (name,country,year) group "

* Group Definition (d): (name,country,year,good)
egen                            grp_ncyi = group(name3 ccode3 year i)
bysort name3 ccode3 year i: gen num_ncyi = _N
bysort name3 ccode3 year i: gen idx_ncyi = _n
la var grp_ncyi " numerical indexes for (name,country,year,good) groups    "
la var num_ncyi " number of obs within each (name,country,year,good) group "
la var idx_ncyi " index for obs within each (name,country,year,good) group "

* ==============================================================================
* 3 PRICE-CHANGE VARIABLES
*
* construct price change indicators and levels: four types
* -----------------------------------------------------------------------
* | indicator | (-infty,-1) | [-1,0) | 0 | (0,1] | (1,+infty) | Missing |
* -----------------------------------------------------------------------
* | pcf       | -1          | -1     | 0 | 1     | 1          | .       |
* | pc_pennyf | -1          | 0      | 0 | 0     | 1          | .       |
* | pc_unitf  | .           | -1     | 0 | 1     | .          | .       |
* | pc_allf   | -2          | -1     | 0 | 1     | 2          | .       |
* -----------------------------------------------------------------------
* the steps are to
* (1) recode price change indicators to prime numbers
* (2) recode price change levels missing values to some large number
* the idea is to capture the different coordination pattern using
* the uniqueness of prime number multiplication
* for ind: (-1=2) (0=3) (1=5) (.=7) (-2=11) (2=13)
* for lev: (.=99)
* ==============================================================================

* price change definition (1): pcf
* recode "pcf" to "pcf_99"
* for indicators: use prime numbers for uniqueness
la var pcf "pc ind: decrease (-1) increase (1)"
recode pcf (-1=2) (0=3) (1=5) (.=7), gen(pcf_99)
la var pcf_99 "pcf recode: (-1=2) (0=3) (1=5) (.=7)"
la define pcf_99_lbl 2 " Decrease (>=< 1 LCU) "
la define pcf_99_lbl 3 " No Change (=0 LCU)   " , add
la define pcf_99_lbl 5 " Increase (>=< 1 LCU) " , add
la define pcf_99_lbl 7 " Missing              " , add
la value pcf_99 pcf_99_lbl
* recode "pchangef" to "pchangef_99"
* for levels: use big numbers for easy if statement
la var pchangef "pc level"
recode pchangef (.=99), gen(pchangef_99)
la var pchangef_99 "pchangef recode: (.=99)"

* price change definition (2): pc_pennyf
* recode "pc_pennyf" to "pc_pennyf_99"
* for indicators: use prime numbers for uniqueness
la var pc_pennyf "pc ind: only outside-unit change"
recode pc_pennyf (-1=2) (0=3) (1=5) (.=7), gen(pc_pennyf_99)
la var pc_pennyf_99 "pc_pennyf recode: (-1=2) (0=3) (1=5) (.=7)"
la define pc_pennyf_99_lbl 2 " Decrease (>1 LCU)   "
la define pc_pennyf_99_lbl 3 " No Change (<=1 LCU) " , add
la define pc_pennyf_99_lbl 5 " Increase (>1 LCU)   " , add
la define pc_pennyf_99_lbl 7 " Missing             " , add
la value pc_pennyf_99 pc_pennyf_99_lbl
* recode "pchange_pennyf" to "pchange_pennyf_99"
* for levels: use big numbers for easy if statement
la var pchange_pennyf "pc lev: (> 1 LCU)"
recode pchange_pennyf (.=99), gen(pchange_pennyf_99)
la var pchange_pennyf_99 "pchange_pennyf recode: (.=99)"

* price change definition (4): pc_allf
* generate "pc_allf": indicate both changes
* (D>-1)=-2; (D<=-1)=-1; (N)=0; (I<1)=1; (I>1)=2; (else)=.
gen pc_allf = pcf + pc_pennyf
la var pc_allf "pc ind: indicate within- & outside-unit change"
* recode "pc_allf" to "pc_allf_99": use prime numbers for uniqueness
recode pc_allf (-1=2) (0=3) (1=5) (.=7) (-2=11) (2=13), gen(pc_allf_99)
la var pc_allf_99 "pc_allf recode: (-1=2) (0=3) (1=5) (.=7) (-2=11) (2=13)"
la define pc_allf_99_lbl 11 "Decrease > 1 LCU"
la define pc_allf_99_lbl  2 "Decrease <=1 LCU" , add
la define pc_allf_99_lbl  3 "No Change"        , add
la define pc_allf_99_lbl  5 "Increase <=1 LCU" , add
la define pc_allf_99_lbl 13 "Increase > 1 LCU" , add
la define pc_allf_99_lbl  7 "Missing"          , add
la value pc_allf_99 pc_allf_99_lbl
* generate "pchange_allf": use price change
gen pchange_allf = pchangef
la var pchange_allf "pc lev: (= pchangef)"
* recode "pchange_allf" to "pchange_allf_99"
recode pchange_allf (.=99), gen(pchange_allf_99)
la var pchange_allf_99 "pchange_allf recode: (.=99)"

* price change definition (3): pc_unitf
* generate "pc_unitf": indicate only within-unit change
* (D<=-1)=-1; (N)=0; (I<1)=1; (else)=.
recode pc_allf (-2=.) (2=.), gen(pc_unitf)
la var pc_unitf "pc ind: only within-unit change"
* recode "pc_unitf" to "pc_unitf_99": use prime numbers for uniqueness
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
la var pchange_unitf "pc lev: for changes <=1 LCU"
* recode "pchange_allf" to "pchange_allf_99"
recode pchange_unitf (.=99), gen(pchange_unitf_99)
la var pchange_unitf_99 "pchange_unitf recode: (.=99)"

* ==============================================================================
* 4 NEW GROUP DEFINITIONS
*
* define group: new types
* ------------------------------------------------------------------
* | variables | year | name | country | good | variety2 | variety3 |
* ------------------------------------------------------------------
* | group 6   | yes  |      |         |      | yes      |          |
* | group 7   | yes  | yes  |         |      | yes      |          |
* | group 8   | yes  |      |         | yes  | yes      |          |
* | group 9   | yes  | yes  |         | yes  | yes      |          |
* ------------------------------------------------------------------
* | group 10  | yes  |      |         |      |          | yes      |
* | group 11  | yes  | yes  |         |      |          | yes      |
* | group 12  | yes  |      |         | yes  |          | yes      |
* | group 13  | yes  | yes  |         | yes  |          | yes      |
* ------------------------------------------------------------------
* the new group definition, using newly defined quasi-variety
* note that the group definition is up-to variety2 or variety3
* i.e., cannot define up-to j, otherwise all groups will be singletons
* compare price coordination within such groups to 1 - 5
*
* define group: new types
* ------------------------------------------------------------------
* | variables | year | name | country | good | variety2 | variety3 |
* ------------------------------------------------------------------
* | group f   |      | yes  |         |      | yes      |          |
* | group g   |      | yes  | yes     |      | yes      |          |
* | group h   |      | yes  |         | yes  | yes      |          |
* | group i   | yes  | yes  |         |      | yes      |          |
* | group j   | yes  | yes  | yes     | yes  | yes      |          |
* ------------------------------------------------------------------
* | group k   |      | yes  |         |      |          | yes      |
* | group l   |      | yes  | yes     |      |          | yes      |
* | group m   |      | yes  |         | yes  |          | yes      |
* | group n   | yes  | yes  |         |      |          | yes      |
* | group o   | yes  | yes  | yes     | yes  |          | yes      |
* ------------------------------------------------------------------
* the new group definition, using newly defined quasi-variety
* note that the group definition is up-to variety2 or variety3
* i.e., cannot define up-to j, otherwise all groups will be singletons
* compare price coordination within such groups to a - e
*
* ==============================================================================

* ------------------------------------------------------------------------------
* Group Definition (6) - (13)
* ------------------------------------------------------------------------------

* Group Definition (6): (year,variety2)
egen                grp_yj2 = group(year j2)
bysort year j2: gen num_yj2 = _N
bysort year j2: gen idx_yj2 = _n
la var grp_yj2 " numerical indexes for (year,variety2) groups    "
la var num_yj2 " number of obs within each (year,variety2) group "
la var idx_yj2 " index for obs within each (year,variety2) group "

* Group Definition (7): (year,name,variety2)
egen                grp_ynj2 = group(year name3 j2)
bysort year name3 j2: gen num_ynj2 = _N
bysort year name3 j2: gen idx_ynj2 = _n
la var grp_ynj2 " numerical indexes for (year,name,variety2) groups    "
la var num_ynj2 " number of obs within each (year,name,variety2) group "
la var idx_ynj2 " index for obs within each (year,name,variety2) group "

* Group Definition (8): (year,good,variety2)
egen                grp_yij2 = group(year i j2)
bysort year i j2: gen num_yij2 = _N
bysort year i j2: gen idx_yij2 = _n
la var grp_yij2 " numerical indexes for (year,good,variety2) groups    "
la var num_yij2 " number of obs within each (year,good,variety2) group "
la var idx_yij2 " index for obs within each (year,good,variety2) group "

* Group Definition (9): (year,name,good,variety2)
egen                grp_ynij2 = group(year name3 i j2)
bysort year name3 i j2: gen num_ynij2 = _N
bysort year name3 i j2: gen idx_ynij2 = _n
la var grp_ynij2 " numerical indexes for (year,name,good,variety2) groups    "
la var num_ynij2 " number of obs within each (year,name,good,variety2) group "
la var idx_ynij2 " index for obs within each (year,name,good,variety2) group "

* Group Definition (10): (year,variety3)
egen                grp_yj3 = group(year j3)
bysort year j3: gen num_yj3 = _N
bysort year j3: gen idx_yj3 = _n
la var grp_yj3 " numerical indexes for (year,variety3) groups    "
la var num_yj3 " number of obs within each (year,variety3) group "
la var idx_yj3 " index for obs within each (year,variety3) group "

* Group Definition (11): (year,name,variety3)
egen                grp_ynj3 = group(year name3 j3)
bysort year name3 j3: gen num_ynj3 = _N
bysort year name3 j3: gen idx_ynj3 = _n
la var grp_ynj3 " numerical indexes for (year,name,variety3) groups    "
la var num_ynj3 " number of obs within each (year,name,variety3) group "
la var idx_ynj3 " index for obs within each (year,name,variety3) group "

* Group Definition (12): (year,good,variety3)
egen                grp_yij3 = group(year i j3)
bysort year i j3: gen num_yij3 = _N
bysort year i j3: gen idx_yij3 = _n
la var grp_yij3 " numerical indexes for (year,good,variety3) groups    "
la var num_yij3 " number of obs within each (year,good,variety3) group "
la var idx_yij3 " index for obs within each (year,good,variety3) group "

* Group Definition (13): (year,name,good,variety3)
egen                grp_ynij3 = group(year name3 i j3)
bysort year name3 i j3: gen num_ynij3 = _N
bysort year name3 i j3: gen idx_ynij3 = _n
la var grp_ynij3 " numerical indexes for (year,name,good,variety3) groups    "
la var num_ynij3 " number of obs within each (year,name,good,variety3) group "
la var idx_ynij3 " index for obs within each (year,name,good,variety3) group "

* ------------------------------------------------------------------------------
* Group Definition (f) - (o)
* ------------------------------------------------------------------------------

* Group Definition (f): (name,variety2)
egen                 grp_nj2 = group(name3 j2)
bysort name3 j2: gen num_nj2 = _N
bysort name3 j2: gen idx_nj2 = _n
la var grp_nj2 " numerical indexes for (name,variety2) groups    "
la var num_nj2 " number of obs within each (name,variety2) group "
la var idx_nj2 " index for obs within each (name,variety2) group "

* Group Definition (g): (name,country,variety2)
egen                        grp_ncj2 = group(name3 ccode3 j2)
bysort name3 ccode3 j2: gen num_ncj2 = _N
bysort name3 ccode3 j2: gen idx_ncj2 = _n
la var grp_ncj2 " numerical indexes for (name,country,variety2) groups    "
la var num_ncj2 " number of obs within each (name,country,variety2) group "
la var idx_ncj2 " index for obs within each (name,country,variety2) group "

* Group Definition (h): (name,good,variety2)
egen                        grp_nij2 = group(name3 i j2)
bysort name3 i j2: gen num_nij2 = _N
bysort name3 i j2: gen idx_nij2 = _n
la var grp_nij2 " numerical indexes for (name,good,variety2) groups    "
la var num_nij2 " number of obs within each (name,good,variety2) group "
la var idx_nij2 " index for obs within each (name,good,variety2) group "

* Group Definition (i): (name,year,variety2)
egen                      grp_nyj2 = group(name3 year j2)
bysort name3 year j2: gen num_nyj2 = _N
bysort name3 year j2: gen idx_nyj2 = _n
la var grp_nyj2 " numerical indexes for (name,year,variety2) groups    "
la var num_nyj2 " number of obs within each (name,year,variety2) group "
la var idx_nyj2 " index for obs within each (name,year,variety2) group "

* Group Definition (j): (name,country,year,good,variety2)
egen                               grp_ncyij2 = group(name3 ccode3 year i j2)
bysort name3 ccode3 year i j2: gen num_ncyij2 = _N
bysort name3 ccode3 year i j2: gen idx_ncyij2 = _n
la var grp_ncyij2 " numerical indexes for (name,country,year,good,variety2) groups    "
la var num_ncyij2 " number of obs within each (name,country,year,good,variety2) group "
la var idx_ncyij2 " index for obs within each (name,country,year,good,variety2) group "

* Group Definition (k): (name,variety3)
egen                 grp_nj3 = group(name3 j3)
bysort name3 j3: gen num_nj3 = _N
bysort name3 j3: gen idx_nj3 = _n
la var grp_nj3 " numerical indexes for (name,variety3) groups    "
la var num_nj3 " number of obs within each (name,variety3) group "
la var idx_nj3 " index for obs within each (name,variety3) group "

* Group Definition (l): (name,country,variety3)
egen                        grp_ncj3 = group(name3 ccode3 j3)
bysort name3 ccode3 j3: gen num_ncj3 = _N
bysort name3 ccode3 j3: gen idx_ncj3 = _n
la var grp_ncj3 " numerical indexes for (name,country,variety3) groups    "
la var num_ncj3 " number of obs within each (name,country,variety3) group "
la var idx_ncj3 " index for obs within each (name,country,variety3) group "

* Group Definition (m): (name,good,variety3)
egen                        grp_nij3 = group(name3 i j3)
bysort name3 i j3: gen num_nij3 = _N
bysort name3 i j3: gen idx_nij3 = _n
la var grp_nij3 " numerical indexes for (name,good,variety3) groups    "
la var num_nij3 " number of obs within each (name,good,variety3) group "
la var idx_nij3 " index for obs within each (name,good,variety3) group "

* Group Definition (n): (name,year,variety3)
egen                      grp_nyj3 = group(name3 year j3)
bysort name3 year j3: gen num_nyj3 = _N
bysort name3 year j3: gen idx_nyj3 = _n
la var grp_nyj3 " numerical indexes for (name,year,variety3) groups    "
la var num_nyj3 " number of obs within each (name,year,variety3) group "
la var idx_nyj3 " index for obs within each (name,year,variety3) group "

* Group Definition (o): (name,country,year,good,variety3)
egen                               grp_ncyij3 = group(name3 ccode3 year i j3)
bysort name3 ccode3 year i j3: gen num_ncyij3 = _N
bysort name3 ccode3 year i j3: gen idx_ncyij3 = _n
la var grp_ncyij3 " numerical indexes for (name,country,year,good,variety3) groups    "
la var num_ncyij3 " number of obs within each (name,country,year,good,variety3) group "
la var idx_ncyij3 " index for obs within each (name,country,year,good,variety3) group "

* ==============================================================================
* 5 BASELINE GROUP DEFINITIONS
*
* define group: new types
* ----------------------------------------------------------------------------
* | variables | year | name | country | good | variety | variety2 | variety3 |
* ----------------------------------------------------------------------------
* | group 14  | yes  |      |         |      |         |          |          |
* ----------------------------------------------------------------------------
* the new group definition, using only year
* the baseline analyses then calculate statistics for
* (i) within country
* (ii) cross country
* note that, year-country-good-variety uniquely identifies each observation
* therefore, each year within/cross countries is comparing good-variety (ij)
*
* ==============================================================================

* ------------------------------------------------------------------------------
* Group Definition (14): (year)
egen             grp_y = group(year)
bysort year: gen num_y = _N
bysort year: gen idx_y = _n
la var grp_y " numerical indexes for (year) groups    "
la var num_y " number of obs within each (year) group "
la var idx_y " index for obs within each (year) group "

* ==============================================================================
* OUTPUT
* ==============================================================================

sort name3 year ccode3 i j j3 j2 ij ijc

keep name3 year ccode3 i j j2 j3 ij ijc ///
	 ///
	grp_yn     num_yn     idx_yn     ///
	grp_yi     num_yi     idx_yi     ///
	grp_yij    num_yij    idx_yij    ///
	grp_yni    num_yni    idx_yni    ///
	grp_ynij   num_ynij   idx_ynij   ///
	grp_nc     num_nc     idx_nc     ///
	grp_ni     num_ni     idx_ni     ///
	grp_ny     num_ny     idx_ny     ///
	grp_ncy    num_ncy    idx_ncy    ///
	grp_ncyi   num_ncyi   idx_ncyi   ///
	///
	grp_yj2    num_yj2    idx_yj2    ///
	grp_ynj2   num_ynj2   idx_ynj2   ///
	grp_yij2   num_yij2   idx_yij2   ///
	grp_ynij2  num_ynij2  idx_ynij2  ///
	grp_yj3    num_yj3    idx_yj3    ///
	grp_ynj3   num_ynj3   idx_ynj3   ///
	grp_yij3   num_yij3   idx_yij3   ///
	grp_ynij3  num_ynij3  idx_ynij3  ///
	grp_nj2    num_nj2    idx_nj2    ///
	grp_ncj2   num_ncj2   idx_ncj2   ///
	grp_nij2   num_nij2   idx_nij2   ///
	grp_nyj2   num_nyj2   idx_nyj2   ///
	grp_ncyij2 num_ncyij2 idx_ncyij2 ///
	grp_nj3    num_nj3    idx_nj3    ///
	grp_ncj3   num_ncj3   idx_ncj3   ///
	grp_nij3   num_nij3   idx_nij3   ///
	grp_nyj3   num_nyj3   idx_nyj3   ///
	grp_ncyij3 num_ncyij3 idx_ncyij3 ///
	///
	grp_y      num_y      idx_y      ///
	 ///
	pcf          pchangef          ///
	pc_pennyf    pchange_pennyf    ///
	pc_allf      pchange_allf      ///
	pc_unitf     pchange_unitf     ///
	 ///
	pcf_99       pchangef_99       ///
	pc_pennyf_99 pchange_pennyf_99 ///
	pc_unitf_99  pchange_unitf_99  ///
	pc_allf_99   pchange_allf_99

order name3 year ccode3 i j j2 j3 ij ijc ///
	 ///
	grp_yn     num_yn     idx_yn     ///
	grp_yi     num_yi     idx_yi     ///
	grp_yij    num_yij    idx_yij    ///
	grp_yni    num_yni    idx_yni    ///
	grp_ynij   num_ynij   idx_ynij   ///
	grp_nc     num_nc     idx_nc     ///
	grp_ni     num_ni     idx_ni     ///
	grp_ny     num_ny     idx_ny     ///
	grp_ncy    num_ncy    idx_ncy    ///
	grp_ncyi   num_ncyi   idx_ncyi   ///
	///
	grp_yj2    num_yj2    idx_yj2    ///
	grp_ynj2   num_ynj2   idx_ynj2   ///
	grp_yij2   num_yij2   idx_yij2   ///
	grp_ynij2  num_ynij2  idx_ynij2  ///
	grp_yj3    num_yj3    idx_yj3    ///
	grp_ynj3   num_ynj3   idx_ynj3   ///
	grp_yij3   num_yij3   idx_yij3   ///
	grp_ynij3  num_ynij3  idx_ynij3  ///
	grp_nj2    num_nj2    idx_nj2    ///
	grp_ncj2   num_ncj2   idx_ncj2   ///
	grp_nij2   num_nij2   idx_nij2   ///
	grp_nyj2   num_nyj2   idx_nyj2   ///
	grp_ncyij2 num_ncyij2 idx_ncyij2 ///
	grp_nj3    num_nj3    idx_nj3    ///
	grp_ncj3   num_ncj3   idx_ncj3   ///
	grp_nij3   num_nij3   idx_nij3   ///
	grp_nyj3   num_nyj3   idx_nyj3   ///
	grp_ncyij3 num_ncyij3 idx_ncyij3 ///
	///
	grp_y      num_y      idx_y      ///
	 ///
	pcf          pchangef          ///
	pc_pennyf    pchange_pennyf    ///
	pc_allf      pchange_allf      ///
	pc_unitf     pchange_unitf     ///
	 ///
	pcf_99       pchangef_99       ///
	pc_pennyf_99 pchange_pennyf_99 ///
	pc_unitf_99  pchange_unitf_99  ///
	pc_allf_99   pchange_allf_99

export excel using "`pathname'.xlsx", firstrow(variables) nolabel replace
save "`pathname'.dta", replace

* ------------------------------------------------------------------------------
* FOOTER
* ------------------------------------------------------------------------------

/*

New Variables:

year             y recode: integer format of year
name3            name2 recode: numerical index of name2 groups
ccode3           ccode2 recode: 17-us 19-uk 23-ca 29-fr 31-it 37-de 41-se
j2               aggregated variety j
j3               aggregated variety j

grp_yn           numerical indexes for (year,name) groups
num_yn           number of obs within each (year,name) group
idx_yn           index for obs within each (year,name) group
grp_yi           numerical indexes for (year,good) groups
num_yi           number of obs within each (year,good) group
idx_yi           index for obs within each (year,good) group
grp_yij          numerical indexes for (year,good-variety) groups
num_yij          number of obs within each (year,good-variety) group
idx_yij          index for obs within each (year,good-variety) group
grp_yni          numerical indexes for (year,name,good) groups
num_yni          number of obs within each (year,name,good) group
idx_yni          index for obs within each (year,name,good) group
grp_ynij         numerical indexes for (year,name,good-variety) groups
num_ynij         number of obs within each (year,name,good-variety) group
idx_ynij         index for obs within each (year,name,good-variety) group
grp_nc           numerical indexes for (name,country) groups
num_nc           number of obs within each (name,country) group
idx_nc           index for obs within each (name,country) group
grp_ni           numerical indexes for (name,good) groups
num_ni           number of obs within each (name,good) group
idx_ni           index for obs within each (name,good) group
grp_ny           numerical indexes for (name,year) groups
num_ny           number of obs within each (name,year) group
idx_ny           index for obs within each (name,year) group
grp_ncy          numerical indexes for (name,country,year) groups
num_ncy          number of obs within each (name,country,year) group
idx_ncy          index for obs within each (name,country,year) group
grp_ncyi         numerical indexes for (name,country,year,good) groups
num_ncyi         number of obs within each (name,country,year,good) group
idx_ncyi         index for obs within each (name,country,year,good) group

grp_yj2          numerical indexes for (year,variety2) groups
num_yj2          number of obs within each (year,variety2) group
idx_yj2          index for obs within each (year,variety2) group
grp_ynj2         numerical indexes for (year,name,variety2) groups
num_ynj2         number of obs within each (year,name,variety2) group
idx_ynj2         index for obs within each (year,name,variety2) group
grp_yij2         numerical indexes for (year,good,variety2) groups
num_yij2         number of obs within each (year,good,variety2) group
idx_yij2         index for obs within each (year,good,variety2) group
grp_ynij2        numerical indexes for (year,name,good,variety2) groups
num_ynij2        number of obs within each (year,name,good,variety2) group
idx_ynij2        index for obs within each (year,name,good,variety2) group
grp_yj3          numerical indexes for (year,variety3) groups
num_yj3          number of obs within each (year,variety3) group
idx_yj3          index for obs within each (year,variety3) group
grp_ynj3         numerical indexes for (year,name,variety3) groups
num_ynj3         number of obs within each (year,name,variety3) group
idx_ynj3         index for obs within each (year,name,variety3) group
grp_yij3         numerical indexes for (year,good,variety3) groups
num_yij3         number of obs within each (year,good,variety3) group
idx_yij3         index for obs within each (year,good,variety3) group
grp_ynij3        numerical indexes for (year,name,good,variety3) groups
num_ynij3        number of obs within each (year,name,good,variety3) group
idx_ynij3        index for obs within each (year,name,good,variety3) group
grp_nj2          numerical indexes for (name,variety2) groups
num_nj2          number of obs within each (name,variety2) group
idx_nj2          index for obs within each (name,variety2) group
grp_ncj2         numerical indexes for (name,country,variety2) groups
num_ncj2         number of obs within each (name,country,variety2) group
idx_ncj2         index for obs within each (name,country,variety2) group
grp_nij2         numerical indexes for (name,good,variety2) groups
num_nij2         number of obs within each (name,good,variety2) group
idx_nij2         index for obs within each (name,good,variety2) group
grp_nyj2         numerical indexes for (name,year,variety2) groups
num_nyj2         number of obs within each (name,year,variety2) group
idx_nyj2         index for obs within each (name,year,variety2) group
grp_ncyij2       numerical indexes for (name,country,year,good,variety2) groups
num_ncyij2       number of obs within each (name,country,year,good,variety2) group
idx_ncyij2       index for obs within each (name,country,year,good,variety2) group
grp_nj3          numerical indexes for (name,variety3) groups
num_nj3          number of obs within each (name,variety3) group
idx_nj3          index for obs within each (name,variety3) group
grp_ncj3         numerical indexes for (name,country,variety3) groups
num_ncj3         number of obs within each (name,country,variety3) group
idx_ncj3         index for obs within each (name,country,variety3) group
grp_nij3         numerical indexes for (name,good,variety3) groups
num_nij3         number of obs within each (name,good,variety3) group
idx_nij3         index for obs within each (name,good,variety3) group
grp_nyj3         numerical indexes for (name,year,variety3) groups
num_nyj3         number of obs within each (name,year,variety3) group
idx_nyj3         index for obs within each (name,year,variety3) group
grp_ncyij3       numerical indexes for (name,country,year,good,variety3) groups
num_ncyij3       number of obs within each (name,country,year,good,variety3) group
idx_ncyij3       index for obs within each (name,country,year,good,variety3) group

grp_y            numerical indexes for (year) groups
num_y            number of obs within each (year) group
idx_y            index for obs within each (year) group

pc_allf          pc ind: indicate within- & outside-unit change
pchange_allf     pc lev: (= pchangef)
pc_unitf         pc ind: only within-unit change
pchange_unitf    pc lev: for changes <=1 LCU

pcf_99           pcf recode: (-1=2) (0=3) (1=5) (.=7)
pchangef_99      pchangef recode: (.=99)
pc_pennyf_99     pc_pennyf recode: (-1=2) (0=3) (1=5) (.=7)
pchange_penn~99  pchange_pennyf recode: (.=99)
pc_unitf_99      pc_unitf recode: (-1=2) (0=3) (1=5) (.=7)
pchange_unit~99  pchange_unitf recode: (.=99)
pc_allf_99       pc_allf recode: (-1=2) (0=3) (1=5) (.=7) (-2=11) (2=13)
pchange_allf_99  pchange_allf recode: (.=99)

Output:

./output/pricecoordination_data.xlsx
./output/pricecoordination_data.dta
*/
