%%  pricecoordination_main.m
%   This the main script file that implements study of price coordinations.
%   The study contains the following parts, illustrated by questions below.
%
%%  Is Price Coordination Stronger Among Products That Share A Common Name?
%
%   No. Even though intuitively the price coordination should be stronger,
%   it is quite weak. Therefore, two additional steps are taken to explore.
%
%   (a) Further disaggregate the group definitions, for example, using
%   name, country and year. Then, that is, would price coordination be
%   stronger among products that not only share a common name, and also
%   are sold at the same year in the same country? Therefore, the idea
%   behind the first step is see, whether changing the definition of the
%   (name) group towards some more disaggregated levels, will the price
%   coordination start to reveal?
%
%   (b) Analyze the price coordination across the size of the group, where
%   the size is number of observations within a group. The intuition is
%   that, if the (name) group is big, it might be more costly to adjust
%   price together (i.e., price coordination), due to larger menu cost.
%   Therefore, in the second step, prices moving to the same direction
%   might be more frequent, or equivalently, prices moving to the opposite
%   directions might be less frequent, in larger-size groups.
%
%%  Is Price Coordination Stronger Within Currency Union?
%
%   No. Even though intuitively the price coordination should be stronger,
%   the price coordination is about the same in (Euro) currency union and
%   in (North America) non-currency union; more interestingly, the price
%   coordination is about the same across (Euro) currency union and (North
%   America) non-currency union.
%
%%  Where Is Price Coordination?
%
%   The literature studies the price coordination due to menu cost; the
%   above two questions and analyses show this menu cost is not the root
%   driver, provided menu cost shall be covariant with (name) group and
%   currency union.
%
%   Then where is the price coordination; more specifically, across
%   different definitions of group, indicated by different disaggregated
%   level, which definition, or equivalently level of disaggregation,
%   produces the strongest price coordination?
%
%   To start, implement the BILLY case study. It seems like, the price
%   coordination is shown at some quasi variety level, which is a slightly
%   more aggregated level than the variety level.
%
%%  Structure of Scripts
%
%   pricecoordination_main
%       pricecoordination_name : question 1
%       pricecoordination_euro : question 2
%       pricecoordination_bill : question 3
%
%   pricecoordination_namestat : main function in pricecoordination_name
%       pricecoordination_dataset : prepare dataset
%       pricecoordination_pattern : study price change patterns
%       pricecoordination_deinno  : study decrease-increase-nochange
%       pricecoordination_sizeper : study across size percentiles
%
%   pricecoordination_eurostat : main function in pricecoordination_euro
%       pricecoordination_dataset : prepare dataset
%       pricecoordination_country : study price change patterns
%       pricecoordination_region  : study regional statistics
%       pricecoordination_pcccode : generate price-change-country codes
%
%%  Header
clear
cd '/Users/xu/Dropbox/XU/03 GD/20 BU/baxter/xu/charity/charity';

%%  Determine Global Parameters
%   This section gives the option to change some global parameters; more
%   importantly, the global parameters can be modified to produce
%   comparable results.
%
%%  Which Group Definition
%
%   (year,name)              | gpK = | 1
%   (year,good)              |       | 2
%   (year,good,variety)      |       | 3
%   (year,name,good)         |       | 4
%   (year,name,good,variety) |       | 5
%   (name,country)           |       | 6
%   (name,good)              |       | 7
%   (name,year)              |       | 8
%   (name,year,country)      |       | 9
%   (name,year,country,good) |       | 10
%
%   ------------------------------------------------------
%   | variables | year | name | country | good | variety |
%   ------------------------------------------------------
%   | group 1   | yes  | yes  |         |      |         |
%   | group 2   | yes  |      |         | yes  |         |
%   | group 3   | yes  |      |         | yes  | yes     |
%   | group 4   | yes  | yes  |         | yes  |         |
%   | group 5   | yes  | yes  |         | yes  | yes     |
%   ------------------------------------------------------
%   | group a   |      | yes  | yes     |      |         |
%   | group b   |      | yes  |         | yes  |         |
%   | group c   | yes  | yes  |         |      |         |
%   | group d   | yes  | yes  | yes     |      |         |
%   | group e   | yes  | yes  | yes     | yes  |         |
%   ------------------------------------------------------
%
%   (year,variety2)                   | gpK = | 11
%   (year,name,variety2)              |       | 12
%   (year,good,variety2)              |       | 13
%   (year,name,good,variety2)         |       | 14
%   (year,variety3)                   | gpK = | 15
%   (year,name,variety3)              |       | 16
%   (year,good,variety3)              |       | 17
%   (year,name,good,variety3)         |       | 18
%   (name,variety2)                   | gpK = | 19
%   (name,country,variety2)           |       | 20
%   (name,good,variety2)              |       | 21
%   (name,year,variety2)              |       | 22
%   (name,country,year,good,variety2) |       | 23
%   (name,variety3)                   | gpK = | 24
%   (name,country,variety3)           |       | 25
%   (name,good,variety3)              |       | 26
%   (name,year,variety3)              |       | 27
%   (name,country,year,good,variety3) |       | 28
%
%   ------------------------------------------------------------------
%   | variables | year | name | country | good | variety2 | variety3 |
%   ------------------------------------------------------------------
%   | group 6   | yes  |      |         |      | yes      |          |
%   | group 7   | yes  | yes  |         |      | yes      |          |
%   | group 8   | yes  |      |         | yes  | yes      |          |
%   | group 9   | yes  | yes  |         | yes  | yes      |          |
%   ------------------------------------------------------------------
%   | group 10  | yes  |      |         |      |          | yes      |
%   | group 11  | yes  | yes  |         |      |          | yes      |
%   | group 12  | yes  |      |         | yes  |          | yes      |
%   | group 13  | yes  | yes  |         | yes  |          | yes      |
%   ------------------------------------------------------------------
%   | group f   |      | yes  |         |      | yes      |          |
%   | group g   |      | yes  | yes     |      | yes      |          |
%   | group h   |      | yes  |         | yes  | yes      |          |
%   | group i   | yes  | yes  |         |      | yes      |          |
%   | group j   | yes  | yes  | yes     | yes  | yes      |          |
%   ------------------------------------------------------------------
%   | group k   |      | yes  |         |      |          | yes      |
%   | group l   |      | yes  | yes     |      |          | yes      |
%   | group m   |      | yes  |         | yes  |          | yes      |
%   | group n   | yes  | yes  |         |      |          | yes      |
%   | group o   | yes  | yes  | yes     | yes  |          | yes      |
%   ------------------------------------------------------------------
%
%%  Which Price Change Measure
%
%   pcf        & pchangef       | pcK = | 1
%   pc_pennyf  & pchange_pennyf |       | 2
%   pc_unitf   & pchange_unitf  |       | 3
%   pc_allf    & pchange_allf   |       | 4
%
%   -------------------------------------------------------------------
%   | indicator | (-inf,-1) | [-1,0) | 0 | (0,1] | (1,+inf) | Missing |
%   -------------------------------------------------------------------
%   | pcf       | -1        | -1     | 0 | 1     | 1        | .       |
%   | pc_pennyf | -1        | 0      | 0 | 0     | 1        | .       |
%   | pc_unitf  | .         | -1     | 0 | 1     | .        | .       |
%   | pc_allf   | -2        | -1     | 0 | 1     | 2        | .       |
%   -------------------------------------------------------------------
%
%%  Whether Use Conditional Calculation
%
%   treat impossible as missing | con = | 1
%   treat impossible as zero    |       | 0
%
%%  Whether Use Variable Name in Output
%
%   variable name in first row | head = | 1
%   numerical values only      |        | 0
%
%%  Where To Save
%   specify string | here = |

global con gpK pcK head here
con     = 1;
gpK     = 1;
pcK     = 1;
head    = 1;
here    = '../output/pricecoordination';

%%  Import Data                                                       (raw)

tempdata = readtable([here,'_data.xlsx']);

% seprate the string variables names and variable numerical data
% the variables are arranged in the following order
% (1) identification variables
% (2) group definition variables
% (3) original price change variables
% (4) modified price change variables with prime numbers and 99
raw.var = tempdata.Properties.VariableNames';
raw.num = table2array(tempdata);
clearvars temp* iter*

% separate dataset into three subset
% (1) id - identification variables: year,name,country,good,variety
% (2) gp - group definition variables: group, size, index
% (3) pc - price change variables: indicators and levels '99' versions
raw.id = raw.num(:, 1: 7);
raw.gp = raw.num(:,10:end-16);
raw.pc = raw.num(:,end-7:end-0);

%%  Question-1                                                       (name)
pricecoordination_name;
%%  Question-2                                                       (euro)
pricecoordination_euro;
%%  Question-3                                                       (bill)
pricecoordination_bill;

%%  Export Dataset
save([here,'_data.mat']);