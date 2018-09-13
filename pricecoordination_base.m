%%  pricecoordination_base.m
%   This script is the part of the analysis providing baseline within/cross
%   country statistics
%
%%  Is Price Coordination Stronger Within & Across Countries?
%
%%  More Specifically
%
%   The price coordination is compared across group definitions
%   (year)                      | gpK = | 29
%
%   The price coordination is compared across price-change definitions
%   pcf        & pchangef       | pcK = | 1
%   pc_pennyf  & pchange_pennyf |       | 2
%   pc_unitf   & pchange_unitf  |       | 3
%
%   The price coordination is compared using countries that are
%   for each country (XX), define three comparison
%   (a) xx   - within country XX : XX = us/uk/ca/fr/it/de/se
%   (b) nxx  - within countries other than xx
%   (c) xxno - across XX and NXX countries : 1 from XX + 1 from NXX
%
%%  Code & Variable Structures
%
%%  Header
global con gpK pcK here
con     = 1;
here    = '../output/pricecoordination';

%%  Set Global Parameter Value
%   choose the group definition
%   select the price change calculation
tempgpKset = [29;];
temppcKset = [1;2;3;];

tempvarnames = { ...
    'OCC_D'  ; 'OCC_I'  ; 'OCC_N'  ; ...
    'OCC_DD' ; 'OCC_II' ; 'OCC_DN' ; 'OCC_IN' ; 'OCC_DI' ; 'OCC_NN' ; ...
    ...
    'FRQ_D'  ; 'FRQ_I'  ; 'FRQ_N'  ; ...
    'FRQ_DD' ; 'FRQ_II' ; 'FRQ_DN' ; 'FRQ_IN' ; 'FRQ_DI' ; 'FRQ_NN' ; ...
    ...
    'MAG_D'  ; 'MAG_I'  ; 'MAG_N'  ; ...
    'MAG_DD' ; 'MAG_II' ; 'MAG_DN' ; 'MAG_IN' ; 'MAG_DI' ; 'MAG_NN' ; ...
    };
temprownames = { ...
    'US'  ; ...
    'UK'  ; ...
    'CA'  ; ...
    'FR'  ; ...
    'IT'  ; ...
    'DE'  ; ...
    'SE'  ; ...
    'ALL' ; ...
    };

for iterpcK = 1:size(temppcKset,1)
    pcK = temppcKset(iterpcK,:);
    for itergpK = 1:size(tempgpKset,1)
        gpK = tempgpKset(itergpK,:);

        [ tempstatwithin,tempstatacross ] = ...
            pricecoordination_basestat( raw,gpK,pcK,con );

        temptblwithin = array2table( tempstatwithin, ...
            'VariableNames',tempvarnames,'RowNames', temprownames );
        temptblacross = array2table( tempstatacross, ...
            'VariableNames',tempvarnames,'RowNames', temprownames );

        temptexwithin = mat2tex( tempstatwithin,'%.3f','nomath' );
        temptexacross = mat2tex( tempstatacross,'%.3f','nomath' );

        base.pc(pcK).gp(gpK).statwithin = tempstatwithin;
        base.pc(pcK).gp(gpK).statacross = tempstatacross;

        base.pc(pcK).gp(gpK).tblwithin = temptblwithin;
        base.pc(pcK).gp(gpK).tblacross = temptblacross;

        base.pc(pcK).gp(gpK).texwithin = temptexwithin;
        base.pc(pcK).gp(gpK).texacross = temptexacross;

        disp(['pc=',num2str(pcK),'; gp=',num2str(gpK)]);
        disp(temptexwithin);
        disp(temptexacross);

    end
end
clearvars temp* iter*

%%