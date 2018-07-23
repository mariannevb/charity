* ikea_namegroup.do
* ------------------------------------------------------------------------------
* DESCRIPTION
* edited may 25 2018 to use filled data and with option? of larger namegroups
* study price changes within 'name group'
* idea is menu costs smaller within than across group
* ------------------------------------------------------------------------------
* INITIALIZATION
clear all
cd "/Users/xu/Dropbox/XU/03 GD/20 BU/baxter/baxter_ikea/ikea_namegroups"
* use  "./ikea_fill_2018.dta",replace
use  "./ikea_fill_alt_2018.dta",replace
drop if flag>0
la var ij "good i and variety j"

* ------------------------------------------------------------------------------
* NAME
* create duplicate of name
* replace name2 with 'group' name using namegroup_construction
* at some point a referee may insist that this get done over with the stricter "name groups"
* using "name" instead of "name2"
* but I deleted the block that kept the original name groups separate; easy to re-do later

gen name2=name
la var name2 "all instances of root name grouped together"
quietly do "./namegroup_construction.do"

* ------------------------------------------------------------------------------
* GROUP
* create groups that are defined by name, country, and/or year
sort name2 c y ij

* get obs # of & index in (name2) groups
bysort name2: gen N_name2 = _N
bysort name2: gen i_name2 = _n
la var N_name2 "# obs in (name2) groups"
la var i_name2 "index for good (ij,c,y) in (name2) groups"

* get obs # of & index in (name2,c) groups
bysort name2 c: gen N_nc = _N
bysort name2 c: gen i_nc = _n
la var N_nc "# obs in (name2,c) groups"
la var i_nc "index for good (ij,y) in (name2,c) groups"

* get obs # of & index in (name2,y) groups
bysort name2 y: gen N_ny = _N
bysort name2 y: gen i_ny = _n
la var N_ny "# obs in (name2,y) groups"
la var i_ny "index for good (ij,c) in (name2,y) groups"

* get obs # of & index in (name2,c,y) groups
bysort name2 c y: gen N_ncy = _N
bysort name2 c y: gen i_ncy = _n
la var N_ncy "# obs in (name2,c,y) groups"
la var i_ncy "index for good (ij) in (name2,c,y) groups"

* get numerical group indeces
egen nname = group(name2)
egen namec = group(name2 c)
egen namey = group(name2 y)
egen namecy = group(name2 c y)

la var nname "numerical index of (name2) groups"
la var namec "numerical index of (name2,c) groups"
la var namey "numerical index of (name2,y) groups"
la var namecy "numerical index of (name2,c,y) groups"

* ------------------------------------------------------------------------------
* PC
* recod price change indicators and levels
* for indicators: decrease=2, unchange=3, increase=5, missing=7
* for levels: missing=99

* cannot use 0 (zero) or -1
* use prime numbers to ensure unique: 2x2, 2x3, 2x5, 3x3, 3x5, 5x5
recode pcf (-1=2) (0=3) (1=5) (.=7), gen(pcf_99)
recode pc_pennyf (-1=2) (0=3) (1=5) (.=7), gen(pc_pennyf_99)
la var pcf_99 "pcf recode: (-1=2) (0=3) (1=5) (.=7)"
la var pc_pennyf_99 "pc_pennyf recode: (-1=2) (0=3) (1=5) (.=7)"

* recode pc level: use big numbers for easy if statement
recode pchangef (.=99), gen(pchangef_99)
recode pchange_pennyf (.=99), gen(pchange_pennyf_99)
la var pchangef_99 "pchangef recode: (.=99)"
la var pchange_pennyf_99 "pchange_pennyf recode: (.=99)"

* ------------------------------------------------------------------------------
* CLEAN

* changing format of year variable so it does not appear as "1-1-2016" in Excel
gen int year = y
la var year "year (int)"

* drop singleton observations here rather than dealing with it in Matlab program
drop if N_ncy == 1

*
* ------------------------------------------------------------------------------
* EXPORT

* all data
export excel ///
	name2 ccode2 year ij ///
	nname namec namey namecy ///
	N_name2 i_name2 N_nc i_nc N_ny i_ny N_ncy i_ncy ///
	pcf_99 pc_pennyf_99 pchangef_99 pchange_pennyf_99 ///
	using "./ikea_namegroup_stata.xlsx", firstrow(variables) nolabel replace

* I like to end programs with clear statements
* if any original variables have been dropped
* to prevent an accidental later save of the data set

* Variable Added:
/*******************************************************************************
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
year 					"year (str)"
*******************************************************************************/

clear
