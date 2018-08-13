%%  namegroup_main.m
%   The script studies the price change patterns within a group.

clear
cd '/Users/xu/Dropbox/XU/03 GD/20 BU/baxter/xu/charity/charity';

%%  Determine Global Parameters

% what groups
% (name):                       gpK =   1;
% (name,country):                       2;
% (name,year):                          3;
% (name,country,year):                  4;

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
gpK     = 4;
pcK     = 1;
head    = 1;
here    = '../output/namegroup';

%%  Import Data                                                       (raw)

tempdata = readtable([here,'_data.xlsx']);

raw.var = tempdata.Properties.VariableNames';
raw.num = [ tempdata.nname, table2array(tempdata(:,2:end)) ];
clearvars temp* iter*

% separate dataset into three types variables
% (1) id - identification variables: name, country, year, good-variety
% (2) gp - group definition variables: group, size, index
% (3) pc - price change indicators and levels variables: 99 versions
raw.id = raw.num(:, 1: 4);
raw.gp = raw.num(:, 5:16);
raw.pc = raw.num(:,25:32);

%%  Initialize Main Dataset                                          (data)

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

%%  Find Within Group Price Change Pattern                            (pcp)

% initialization of price change pattern analysis
pcp.group       = unique(data.gp(:,1));
pcp.groupall    = data.gp(:,1);
pcp.pcindicator = data.pc(:,1);
pcp.pclevel     = data.pc(:,2);

% preallocation of LOC (location) OCC (occurrence) MAG (magnitude)
% D - decrease ; I - increase ; N - nochange ;

% store (LOC OCC MAG) in 9 columns as follows:
% 1st - 3rd columns : price change patterns      :  D,  I,  N
% 4th - 9th columns : price change pair patterns : DD, II, DN, IN, DI, NN

% LOC is indicator of existing patterns
% OCC is counted using conditional version
% MAG is stored as total value
% see namegroup_pcp.m

pcp.loc = NaN(size(pcp.group,1),9);
pcp.occ = NaN(size(pcp.group,1),9);
pcp.mag = NaN(size(pcp.group,1),9);

for itergroup = 1:size(pcp.group,1)

    % locate the group in dataset
    tempgroup = pcp.group(itergroup,1);
    templocat = pcp.groupall == tempgroup;

    % get the pc indicators and levels of the group
    temppcind = pcp.pcindicator( templocat,: );
    temppclev = pcp.pclevel( templocat,: );

    % calcaulte of each price change pattern: frequency and magnitude
    [ temploc,tempocc,tempmag ] = namegroup_pcp( temppcind,temppclev,con );

    % output
    pcp.loc(itergroup,:) = temploc;
    pcp.occ(itergroup,:) = tempocc;
    pcp.mag(itergroup,:) = tempmag;

end
clearvars temp* iter*

% Output each group OCC and MAG across all patterns
pcp.tblocc = array2table([pcp.group,pcp.occ], ...
    'VariableNames',{'OCC';'D';'I';'N';'DD';'II';'DN';'IN';'DI';'NN';});
pcp.tblmag = array2table([pcp.group,pcp.mag], ...
    'VariableNames',{'MAG';'D';'I';'N';'DD';'II';'DN';'IN';'DI';'NN';});

% calculatte average DIN magnitude across all patterns
% D=decrease; I=increase; N=no-change
pcp.avgdin = namegroup_din( pcp.loc,pcp.occ,pcp.mag );

% calculate total occurrence and average magnitude across all patterns
pcp.totocc = sum( pcp.occ, 1,'omitnan' );
pcp.avgmag = sum( pcp.mag, 1,'omitnan' ) ./ pcp.totocc;

% calculate total frequency across all patterns
pcp.totfrq = [ ...
    pcp.totocc(:,1:3) ./ sum( pcp.totocc(:,1:3) ),...
    pcp.totocc(:,4:9) ./ sum( pcp.totocc(:,4:9) ),...
    ];

% Output all groups OCC and MAG across all patterns
pcp.stat = [ pcp.totocc;pcp.totfrq;pcp.avgmag;pcp.avgdin; ];
pcp.stattbl = array2table( pcp.stat, ...
    'VariableNames',{'D';'I';'N';'DD';'II';'DN';'IN';'DI';'NN';}, ...
    'RowNames',{'OCC';'FREQ';'MAG';'AVGD';'AVGI';'AVGN';});

% Delete old file and create new filename
% Write excel file
pcp.file = [ here,'_pcp.xlsx' ];
delete(pcp.file);
writetable(pcp.tblocc,pcp.file,'WriteVariableNames',head,'Sheet','occ');
writetable(pcp.tblmag,pcp.file,'WriteVariableNames',head,'Sheet','mag');
writetable(pcp.stattbl,pcp.file,'WriteVariableNames',head,'Sheet','stat');

% Latex Code
pcp.tex = mat2tex( pcp.stat,'%.3f','nomath' );
disp(pcp.tex);

%%  Study Price Change Patterns Across Sizes of Groups                (szs)

% locate where each group is first-appeared in original dataset
[~,szs.locate] = ismember(unique(data.gp(:,1)),data.gp(:,1),'rows');

% construct the dataset with three parts
% 1) the group variables: group index,size
% 2) the price change patterns (pcp) variables of groups: occ/mag
szs.rawdata = data.gp(szs.locate,1:2);
szs.newdata = [ pcp.occ,pcp.mag, ];
szs.dataset = [ szs.rawdata,szs.newdata ];

% specify the percentiles of interest
szs.percentile = [50:10:90,90+(2:2:10)]';

% specify the sorting postion (always = 2: the # of observations);
szs.sorting = 2;

% call function
[ szs.obsrow,szs.obsmat ] = ...
    namegroup_szs( szs.percentile,szs.sorting,szs.dataset );

% construct output tables
szs.varnames = {
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
szs.tblrow = array2table( szs.obsrow,'VariableNames',szs.varnames);
szs.tblmat = array2table( szs.obsmat,'VariableNames',szs.varnames);

% Delete old file and create new filename
% Write excel file
szs.file = [ here,'_szs.xlsx' ];
delete(szs.file);
writetable(szs.tblrow,szs.file,'WriteVariableNames',head,'Sheet','at');
writetable(szs.tblmat,szs.file,'WriteVariableNames',head,'Sheet','btw');

% Latex Code
szs.tex = mat2tex( [ szs.obsrow';szs.obsmat' ],'%.3f','nomath' );
disp(szs.tex);

%%  Save Dataset
save([here,'_data']);
