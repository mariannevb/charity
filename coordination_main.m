%%  coordination.m

% This script studies the price coordinations across countries/regions.
% The program first defines a group, and then tabulates price coordination
% across countries within a group.

clear
cd '/Users/xu/Dropbox/XU/03 GD/20 BU/baxter/xu/charity/charity';

%%  Determine Global Parameters

% what groups
% (year,good-variety):          gpK =   1;
% (year,name):                          2;
% (year,good-variety,name):             3;

% which measure
% pcf        & pchangef:        pcK =   1;
% pc_pennyf  & pchange_pennyf:          2;
% pc_unitf   & pchange_unitf:           3;
% pc_allf    & pchange_allf:            4;

% pc indicator | (-inf,-1) | [-1,0) | [0,0] | (0,1] | (1,+inf) | Missing
% pcf          | -1        | -1     | 0     | 1     | 1        | .
% pc_pennyf    | -1        |  0     | 0     | 0     | 1        | .
% pc_unitf     | .         | -1     | 0     | 1     | .        | .
% pc_allf      | -2        | -1     | 0     | 1     | 2        | .

% conditional calculation
% treat impossible as missing:  con =   1;
% unconditional:                        0;

% want variable name
% variable name in first row:   head =  1;
% numerical values only:                0;

% here to save output
% specify string

global con gpK pcK head here
con     = 1;
gpK     = 1;
pcK     = 1;
head    = 1;
here    = '../output/coordination';

%%  Import Data                                                       (raw)

tempdata = readtable([here,'_data.xlsx']);

raw.var = tempdata.Properties.VariableNames';
raw.num = table2array(tempdata);
clearvars temp* iter*

% separate dataset into three types variables
% (1) id - identification variables: name, year, good-variety, country,
% (2) gp - group definition variables: group, size, index
% (3) pc - price change indicators and levels variables: 99 versions
raw.id = raw.num(:, 1: 4);
raw.gp = raw.num(:, 5:13);
raw.pc = raw.num(:,22:29);

% additional recode country code data
raw.cc = raw.num(:,end);

%%  Identify The Group To Analyze                                    (data)

% locate singleton-group observations based on choice of group definition
% delete those because no bi-price-change pattern within such groups
data.singleton = ( raw.gp( :,(gpK*3-2)+1 ) == 1 );

% unique id of each observation
% 1st column: name
% 2nd column: country
% 3rd column: year
% 4th column: good-variety
data.id = raw.id(~data.singleton,:);

% group definition that determines the subset to analyze
% 1st column: index of group
% 2nd column: number of observations within group
% 3rd column: index of observation within group
data.gp = raw.gp(~data.singleton,(gpK*3-2):(gpK*3));

% price change variables
% 1st column: price change indicators
% 2nd column: price change levels
data.pc = raw.pc(~data.singleton,(pcK*2-1):(pcK*2));

% country numerical code
%  1: us |  2: uk |  3: ca |  4: fr |  5: it |  6: de |  7: se
% 17: us | 19: uk | 23: ca | 29: fr | 31: it | 37: de | 41: se
data.cc = raw.cc(~data.singleton,:);

%%  Study Price Coordination                                          (coo)

% define key variables
coo.group       = unique(data.gp(:,1));

coo.groupall    = data.gp(:,1);
coo.groupnum    = data.gp(:,2);
coo.groupidx    = data.gp(:,3);

coo.pcindicator = data.pc(:,1);
coo.pclevel     = data.pc(:,2);

coo.country     = data.cc(:,1);

% preallocation of occurrence, magnitude
coo.occ = NaN(size(coo.group,1),210);
coo.mag = NaN(size(coo.group,1),210);

for itergroup = 1:size(coo.group,1)

    % locate the group in dataset
    tempgroup = coo.group(itergroup,1);
    templocat = (coo.groupall == tempgroup);

    % get the pc indicators and levels of the group
    temppcind = coo.pcindicator( templocat,: );
    temppclev = coo.pclevel( templocat,: );

    % get the country code of the group
    tempccode = coo.country( templocat,: );

    % calcaulte of each price change pattern across countries
    [ tempocc,tempmag ] = ...
        coordination_coo( temppcind,temppclev,tempccode,con );

    %
    coo.occ(itergroup,:) = tempocc;
    coo.mag(itergroup,:) = tempmag;

end
clearvars temp* iter*

%%  Compare Price Coordination                                        (cmp)

% unique indicator country identification (ID) pairs
cmp.idp = coordination_idp( [2;3;5;7;],[11;13;17;19;23;29;31;] );
cmp.pcp = [ 4, 9,25, 6,15,10,14,21,35,49]';

% Define cross-country types to compare

% within Euro Union (EU) region
cmp.type.eu = ismember(cmp.idp, ...
    coordination_idp( [2;3;5;7;],[19;23;29;] ));
% within North America (NA) region
cmp.type.na = ismember(cmp.idp, ...
    coordination_idp( [2;3;5;7;],[11;17;] ));
% within No Euro (NO) region (NA+UK+SWEDEN)
cmp.type.no = ismember(cmp.idp, ...
    coordination_idp( [2;3;5;7;],[11;17;13;31;] ));
% across EU and NA regions
cmp.type.euna = ismember(cmp.idp, ...
    kron(cmp.pcp, kron([19;23;29;],[11;17;]) ));
% across EU and NO regions
cmp.type.euno = ismember(cmp.idp, ...
    kron(cmp.pcp, kron([19;23;29;],[11;17;13;31;]) ));

% Define price-change patterns to sum
cmp.pattern = [ ...
    repmat( [1,0,0,0,0,0,0,0,0,0,]', [21,1]), ...
    repmat( [0,1,0,0,0,0,0,0,0,0,]', [21,1]), ...
    repmat( [0,0,1,0,0,0,0,0,0,0,]', [21,1]), ...
    repmat( [0,0,0,1,0,0,0,0,0,0,]', [21,1]), ...
    repmat( [0,0,0,0,1,0,0,0,0,0,]', [21,1]), ...
    repmat( [0,0,0,0,0,1,0,0,0,0,]', [21,1]), ...
    ];

% preallocation of occurrence, magnitude
cmp.occ = NaN(6,6);
cmp.mag = NaN(6,6);

for iterpcp = 1:6

    % Select pattern
    temppattern = logical(cmp.pattern(:,iterpcp));

    % Location of This Pattern and Difference Cross-Country Types
    tempeu = logical(cmp.type.eu .* temppattern);
    tempna = logical(cmp.type.na .* temppattern);
    tempno = logical(cmp.type.no .* temppattern);
    tempeuna = logical(cmp.type.euna .* temppattern);
    tempeuno = logical(cmp.type.euno .* temppattern);

    % calculate occurrence
    % for one cross-country type, the occurrence under this pc-pattern
    % is the sum of all occurrences
    tempocc = [ ...
        sum(sum(   coo.occ(:,tempeu)   ,1,'omitnan'),2,'omitnan'); ...
        sum(sum(   coo.occ(:,tempna)   ,1,'omitnan'),2,'omitnan'); ...
        sum(sum(   coo.occ(:,tempno)   ,1,'omitnan'),2,'omitnan'); ...
        sum(sum(   coo.occ(:,tempeuna) ,1,'omitnan'),2,'omitnan'); ...
        sum(sum(   coo.occ(:,tempeuno) ,1,'omitnan'),2,'omitnan'); ...
        sum(sum(   coo.occ(:,temppattern) ,1,'omitnan'),2,'omitnan'); ...
        ];

    % calculate magnitude
    % for one cross-country type, the magnitude under this pc-pattern
    % is the average of all magnitudes
    tempmag = [ ...
        mean(mean( coo.mag(:,tempeu)   ,1,'omitnan'),2,'omitnan'); ...
        mean(mean( coo.mag(:,tempna)   ,1,'omitnan'),2,'omitnan'); ...
        mean(mean( coo.mag(:,tempno)   ,1,'omitnan'),2,'omitnan'); ...
        mean(mean( coo.mag(:,tempeuna) ,1,'omitnan'),2,'omitnan'); ...
        mean(mean( coo.mag(:,tempeuno) ,1,'omitnan'),2,'omitnan'); ...
        mean(mean( coo.mag(:,temppattern) ,1,'omitnan'),2,'omitnan'); ...
        ];

    %
    cmp.occ(:,iterpcp) = tempocc;
    cmp.mag(:,iterpcp) = tempmag;
end

clearvars temp* iter*

cmp.freq = cmp.occ ./ repmat( sum(cmp.occ,2), [1,6] );

% Latex Code
mat2tex( [ cmp.occ,cmp.freq,cmp.mag ], ...
    '%i','%i','%i','%i','%i','%i','%.3f','nomath' );

%%  Save Dataset
save([here,'_data']);
