%%  pricecoordination_euro.m
%   This script is the part of the analysis trying to answer the second set
%   of questions.
%
%%  Is Price Coordination Stronger Within Currency Union?
%
%   No. Even though intuitively the price coordination should be stronger,
%   the price coordination is about the same in (Euro) currency union and
%   in (North America) non-currency union; more interestingly, the price
%   coordination is about the same across (Euro) currency union and (North
%   America) non-currency union.
%
%%  More Specifically
%
%   The price coordination is compared across group definitions
%   (year,name)                 | gpK = | 1
%   (year,good)                 |       | 2
%   (year,good,variety)         |       | 3
%   (year,name,good)            |       | 4
%   (year,name,good,variety)    |       | 5
%
%   The price coordination is compared across price-change definitions
%   pcf        & pchangef       | pcK = | 1
%   pc_pennyf  & pchange_pennyf |       | 2
%   pc_unitf   & pchange_unitf  |       | 3
%
%   The price coordination is compared using countries that are
%   (1) eu   - within Euro Union region     : FR + IT + DE
%   (2) na   - within North America region  : CA + US
%   (3) no   - within Non-Euro Union region : CA + US + UK + SE
%   (4) euna - across EU and NA regions     : 1 from EU + 1 from NA
%   (5) euno - across EU and NO regions     : 1 from EU + 1 from NO
%
%%  Code & Variable Structures
%
%   In 'pricecoordination_euro',
%
%   the 'pricecoordination_eurostat' function gives the summary statistics
%   of price coordination, using countries that are from
%   EU, NA, NO, EUNA, EUNO
%
%   In this name group analysis, 'pricecoordination_name'
%   all output are stored in the variable 'euro'.
%
%   The field name.pc(pcK).gp(gpK) means the analysis is conducted
%   using price change definition 'pcK' and group definition 'gpK'.
%
%   Of each anlysis, three statistics are output
%   (1) statall - of each price pattern
%           the total occurrence
%           the total frequency
%           the average magnitude
%           the average absolute decrease magnitude
%           the average absolute increase magnitude
%           the average absolute no-change magnitude
%       - using countries that are from
%           eu
%           na
%           no
%           euna
%           euno
%
%%  Header
global con gpK pcK here
con     = 1;
here    = '../output/pricecoordination';

%%  Set Global Parameter Value
%   choose the group definition
%   select the price change calculation
tempgpKset = [1;2;3;4;5;];
temppcKset = [1;2;3;];

tempvarnames = { ...
    'OCC_D';'OCC_I';'OCC_N'; ...
    'OCC_DD';'OCC_II';'OCC_DN';'OCC_IN';'OCC_DI';'OCC_NN'; ...
    ...
    'FREQ_D';'FREQ_I';'FREQ_N'; ...
    'FREQ_DD';'FREQ_II';'FREQ_DN';'FREQ_IN';'FREQ_DI';'FREQ_NN'; ...
    ...
    'MAG_D';'MAG_I';'MAG_N'; ...
    'MAG_DD';'MAG_II';'MAG_DN';'MAG_IN';'MAG_DI';'MAG_NN'; ...
    };
temprownames = { ...
    'EU';'NA';'NO';'EUNA';'EUNO';'ALL'; ...
    };

for iterpcK = 1:size(temppcKset,1)
    pcK = temppcKset(iterpcK,:);
    for itergpK = 1:size(tempgpKset,1)
        gpK = tempgpKset(itergpK,:);

        [ tempstatall ] = ...
            pricecoordination_eurostat( raw,gpK,pcK,con );

        temptblall = ...
            array2table( tempstatall, ...
            'VariableNames', tempvarnames, ...
            'RowNames', temprownames );

        temptexall = ...
            mat2tex( tempstatall ,'%.3f','nomath' );

        euro.pc(pcK).gp(gpK).statall = tempstatall;
        euro.pc(pcK).gp(gpK).tblall  = temptblall;
        euro.pc(pcK).gp(gpK).texall  = temptexall;

        disp(['pc=',num2str(pcK),'; gp=',num2str(gpK)]);
        disp(temptexall);
    end
end
clearvars temp* iter*

%%