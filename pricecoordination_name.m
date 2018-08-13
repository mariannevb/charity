%%  pricecoordination_name.m
%   This script is the part of the analysis trying to answer the first set
%   of questions.
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
%%  More Specifically
%
%   In baseline analyses, 3 groups are explored
%   for price coordination.
%   (name,country)           |       | 6
%   (name,good)              |       | 7
%   (name,year)              |       | 8
%
%   In first extension, the group definitions are extended.
%   (name,year,country)      |       | 9
%   (name,year,country,good) |       | 10
%
%   In second extension, for each group definitions,
%   (name,country)           |       | 6
%   (name,good)              |       | 7
%   (name,year)              |       | 8
%   (name,year,country)      |       | 9
%   (name,year,country,good) |       | 10
%   study price coordination across the sizes of groups.
%
%%  Code & Variable Structures
%
%   In 'pricecoordination_name',
%
%   the 'pricecoordination_namestat' function gives the summary statistics
%   of price coordination, using all observations, using at-percentile
%   observations, and using between-percentile observations.
%
%   In this name group analysis, 'pricecoordination_name'
%   all output are stored in the variable 'name'.
%
%   The field name.pc(pcK).gp(gpK) means the analysis is conducted
%   using price change definition 'pcK' and group definition 'gpK'.
%
%   Of each anlysis, three statistics are output
%   (1) statall - the total occurrence of each price change pattern, the
%   total frequency of each price change pattern, and the average magnitude
%   of each price change pattern; the average absolute decrease magnitude
%   of each price change pattern, the average absolute increase magnitude
%   of each price change pattern and the average absolute no-change
%   magnitude of each price change pattern
%
%   (2) statrow - the same statistics at-percentile
%   (3) statmat - the same statistics between-percentile
%
%%  Header
cd '/Users/xu/Dropbox/XU/03 GD/20 BU/baxter/xu/charity/charity';
global con gpK pcK here
con     = 1;
here    = '../output/pricecoordination';

%%  Set Global Parameter Value
%   choose the group definition
%   select the price change calculation
tempgpKset = [6;7;8;9;10];
temppcKset = [1;2;3;];

tempvarnames = { ...
    'PERCENTILE';'NUMOBS';'SIZE'; ...
    ...
    'OCC_D';'OCC_I';'OCC_N'; ...
    'OCC_DD';'OCC_II';'OCC_DN';'OCC_IN';'OCC_DI';'OCC_NN'; ...
    ...
    'FREQ_D';'FREQ_I';'FREQ_N'; ...
    'FREQ_DD';'FREQ_II';'FREQ_DN';'FREQ_IN';'FREQ_DI';'FREQ_NN'; ...
    ...
    'MAG_D';'MAG_I';'MAG_N'; ...
    'MAG_DD';'MAG_II';'MAG_DN';'MAG_IN';'MAG_DI';'MAG_NN'; ...
    ...
    'AVGD_D';'AVGD_I';'AVGD_N'; ...
    'AVGD_DD';'AVGD_II';'AVGD_DN';'AVGD_IN';'AVGD_DI';'AVGD_NN'; ...
    ...
    'AVGI_D';'AVGI_I';'AVGI_N'; ...
    'AVGI_DD';'AVGI_II';'AVGI_DN';'AVGI_IN';'AVGI_DI';'AVGI_NN'; ...
    ...
    'AVGN_D';'AVGN_I';'AVGN_N'; ...
    'AVGN_DD';'AVGN_II';'AVGN_DN';'AVGN_IN';'AVGN_DI';'AVGN_NN'; ...
    };

for iterpcK = 1:size(temppcKset,1)
    pcK = temppcKset(iterpcK,:);
    for itergpK = 1:size(tempgpKset,1)
        gpK = tempgpKset(itergpK,:);

        [ tempstatall,tempstatrow,tempstatmat ] = ...
            pricecoordination_namestat( raw,gpK,pcK,con );

        temptblall = ...
            array2table( tempstatall, ...
            'VariableNames', ...
            {'D';'I';'N';'DD';'II';'DN';'IN';'DI';'NN';}, ...
            'RowNames', ...
            {'OCC';'FREQ';'MAG';'AVGD';'AVGI';'AVGN';  });
        temptblrow = ...
            array2table( tempstatrow, 'VariableNames',tempvarnames);
        temptblmat = ...
            array2table( tempstatmat, 'VariableNames',tempvarnames);

        temptexall = ...
            mat2tex( tempstatall ,'%.3f','nomath' );
        temptexrow = ...
            mat2tex( tempstatrow','%.3f','nomath' );
        temptexmat = ...
            mat2tex( tempstatmat','%.3f','nomath' );

        name.pc(pcK).gp(gpK).statall = tempstatall;
        name.pc(pcK).gp(gpK).statrow = tempstatrow;
        name.pc(pcK).gp(gpK).statmat = tempstatmat;

        name.pc(pcK).gp(gpK).tblall = temptblall;
        name.pc(pcK).gp(gpK).tblrow = temptblrow;
        name.pc(pcK).gp(gpK).tblmat = temptblmat;

        name.pc(pcK).gp(gpK).texall = temptexall;
        name.pc(pcK).gp(gpK).texrow = temptexrow;
        name.pc(pcK).gp(gpK).texmat = temptexmat;

        disp(['pc=',num2str(pcK),'; gp=',num2str(gpK)]);
        disp(temptexall);
        disp(temptexrow);
        disp(temptexmat);
    end
end
clearvars temp* iter*

%%