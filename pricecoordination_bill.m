%%  pricecoordination_bill.m
%   This script is the part of the analysis trying to answer the third set
%   of questions.
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
%%  More Specifically
%
%   The price coordination is compared across group definitions
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
%   The price coordination is compared across price-change definitions
%
%   pcf        & pchangef       | pcK = | 1
%   pc_pennyf  & pchange_pennyf |       | 2
%   pc_unitf   & pchange_unitf  |       | 3
%
%%  Code & Variable Structures
%
%   In 'pricecoordination_bill', the analyses are conducted in two parts.
%
%       'bill.name' repeats the same analyses as 'pricecoordination_name'
%       'bill.euro' repeats the same analyses as 'pricecoordination_euro'
%
%   The idea is that, with the new variety variables, the price
%   coordination should be stronger in those two analyses, as suggested
%   by 'BILLY' case.
%
%%  Header
global con gpK pcK here
con     = 1;
here    = '../output/pricecoordination';

%%  NAME: 'bill.name' repeats the same analyses as 'pricecoordination_name'
%   choose the group definition
%   select the price change calculation
tempgpKset = [19;20;21;22;23;24;25;26;27;28;];
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

        bill.name.pc(pcK).gp(gpK).statall = tempstatall;
        bill.name.pc(pcK).gp(gpK).statrow = tempstatrow;
        bill.name.pc(pcK).gp(gpK).statmat = tempstatmat;

        bill.name.pc(pcK).gp(gpK).tblall = temptblall;
        bill.name.pc(pcK).gp(gpK).tblrow = temptblrow;
        bill.name.pc(pcK).gp(gpK).tblmat = temptblmat;

        bill.name.pc(pcK).gp(gpK).texall = temptexall;
        bill.name.pc(pcK).gp(gpK).texrow = temptexrow;
        bill.name.pc(pcK).gp(gpK).texmat = temptexmat;

        disp(['pc=',num2str(pcK),'; gp=',num2str(gpK)]);
        disp(temptexall);
        disp(temptexrow);
        disp(temptexmat);
    end
end
clearvars temp* iter*

%%  EURO: 'bill.euro' repeats the same analyses as 'pricecoordination_euro'
%   choose the group definition
%   select the price change calculation
tempgpKset = [12;13;14;16;17;18;];
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

        bill.euro.pc(pcK).gp(gpK).statall = tempstatall;
        bill.euro.pc(pcK).gp(gpK).tblall  = temptblall;
        bill.euro.pc(pcK).gp(gpK).texall  = temptexall;

        disp(['pc=',num2str(pcK),'; gp=',num2str(gpK)]);
        disp(temptexall);
    end
end
clearvars temp* iter*

%%