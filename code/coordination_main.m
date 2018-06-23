%%  coordination.m

% This script studies the price coordinations across countries/regions.
% The program first defines a group, and then tabulates price coordination
% across countries within a group.

clear
cd '/Users/xu/Dropbox/XU/03 GD/20 BU/baxter/charity/code';

%%  Determine Global Parameters

% what groups
% (year,good-variety):          gpK =   1;
% (year,name):                          2;
% (year,good-variety,name):             3;

% which measure
% pcf&pchangef:                 pcK =   1;
% pc_pennyf&pchange_pennyf:             2;
% pcb&pchangeb:                         3;
% pc_pennyb&pchange_pennyb:             4;
% pcraw&pchangeraw:                     5;
% pc_pennyraw&pchange_pennyraw:         6;

% want variable name
% variable name in first row:   head =  1;
% numerical values only:                0;

% path to save output
% specify string

global gpK pcK head path
gpK     = 1;
pcK     = 1;
head    = 1;
path    = '../output/coordination';

%%  Import Data                                                       (raw)

tempdata = readtable('../output/coordination_data.xlsx');

raw.var = tempdata.Properties.VariableNames';
raw.num = table2array(tempdata);

clearvars temp* iter*

%%  Identify The Group To Analyze                                    (data)

% determine which group want to use
data.k = gpK;

% unique id of each observation
% [year, good_variety, name, country]
data.id = raw.num(:,1:4);

% group id that determine the subset to analyze
% [group index, number-of-obs within group, index-of-obs within group]
data.gp = raw.num(:,[data.k+4,data.k+7,data.k+8]);

% price change variables
% [price change indicator, price change level]
data.pc = raw.num(:,end-2:end-1);

% country numerical code
% [country numerical (Fibonacci) code]
data.cc = raw.num(:,end);

%%  Study Price Coordination                                          (coo)

% determine which group want to use
coo.k = pcK;

% define key variables
coo.group       = unique(data.gp(:,1));
coo.groupall    = data.gp(:,1);
coo.groupnum    = data.gp(:,2);
coo.groupidx    = data.gp(:,3);
coo.pcindicator = data.pc(:,coo.k);
coo.pclevel     = data.pc(:,coo.k+1);
coo.country     = data.cc;

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
        coordination_coo( temppcind,temppclev,tempccode,0 );
    
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
save([path,'_data']);
