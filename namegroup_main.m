%% namegroup_main.m

% The script studies the price change patterns within a group.

clear
cd '/Users/xu/Dropbox/XU/03 GD/20 BU/baxter/charity/charity';

%%  Determine Global Parameters

% what groups
% (name):                       gpK =   1;
% (name,country):                       2;
% (name,year):                          3;
% (name,country,year):                  4;

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
gpK     = 4;
pcK     = 1;
head    = 1;
path    = '../output/namegroup';

%%  Import Data                                                       (raw)

tempdata = readtable('../output/namegroup_data.xlsx');

raw.var = tempdata.Properties.VariableNames';
raw.num = [tempdata.nname, table2array(tempdata(:,2:end))];

clearvars temp* iter*

%%  Identify The Group To Analyze                                    (data)

% determine which group want to use
% (name):               k = 1;  Columns [5, 9,10] in raw.num
% (name,country):           2;  Columns [6,11,12]
% (name,year):              3;  Columns [7,13,14]
% (name,country,year):      4;  Columns [8,15,16]
data.k = gpK;

% unique id of each observation
% [name, country, year, good(ij)]
data.id = raw.num(:,1:4);

% group id that determine the subset to analyze
% first col:    index of group;
% second col:   number of observations within group
% third col:    index of observation within group
data.gp = raw.num(:,[data.k+4,data.k*2+7,data.k*2+8]);

% price change variables
% [pcf, pc_pennyf, pchangef, pchange_pennyf]
% recoded to ..._99
data.pc = raw.num(:,end-3:end);

%%  Find Within Group Price Change Pattern                            (pcp)

% determine which set of price change (indicator-level) want to use
% pcf-pchangef:             k = 1;  Columns [1,3] in data.pc
% pc_pennyf-pchange_pennyf:     2;  Columns [2,4]
pcp.k = pcK;

% change this if
% 1) want to use other groups
% 2) want to use other price chagne measure
pcp.group       = unique(data.gp(:,1));
pcp.groupall    = data.gp(:,1);
pcp.pcindicator = data.pc(:,pcp.k);
pcp.pclevel     = data.pc(:,pcp.k+2);

% preallocation of occurrence, frequency, magnitude
% the columns are price change patterns: [DD UU II DU UI DI]
% where D: Decrease; U: Unchange; I: Increase
% occurerence has an extra column: MISSING price change variables
% frequency has an extra column: ratio of non-missing/missing occurrences
pcp.occ = NaN(size(pcp.group,1),6);
% pcp.frequency = NaN(size(pcp.group,1),6+1);
pcp.mag = NaN(size(pcp.group,1),6);

for itergroup = 1:size(pcp.group,1)

    % locate the group in dataset
    tempgroup = pcp.group(itergroup,1);
    templocat = pcp.groupall == tempgroup;

    % get the pc indicators and levels of the group
    temppcind = pcp.pcindicator( templocat,: );
    temppclev = pcp.pclevel( templocat,: );

    % calcaulte of each price change pattern: frequency and magnitude
    [ tempocc,tempmag ] = namegroup_pcp( temppcind,temppclev,0 );

    %
    pcp.occ(itergroup,:) = tempocc;
    pcp.mag(itergroup,:) = tempmag;

end
clearvars temp* iter*

% Output the Price Change Pattern Variables
pcp.head = head;
pcp.path = path;

pcp.tblocc = array2table([pcp.group,pcp.occ], ...
    'VariableNames',{'group';'DD';'UU';'II';'DU';'UI';'DI';});
% pcp.tblf = array2table([pcp.group,pcp.frequency], ...
%     'VariableNames',{'group';'DD';'UU';'II';'DU';'UI';'DI';'RATIO'});
pcp.tblmag = array2table([pcp.group,pcp.mag], ...
    'VariableNames',{'group';'DD';'UU';'II';'DU';'UI';'DI';});

writetable(pcp.tblocc,[pcp.path,'_pcp.xlsx' ], ...
    'WriteVariableNames',pcp.head,'Sheet', 'occu');
% writetable(pcp.tblf,[pcp.path,'_pcp.xlsx' ], ...
%     'WriteVariableNames',pcp.head,'Sheet', 'freq');
writetable(pcp.tblmag,[pcp.path,'_pcp.xlsx' ], ...
     'WriteVariableNames',pcp.head,'Sheet', 'magn');
%
% Provide Some Statistics of the Price Change Pattern Variables
pcp.num = [ pcp.occ,pcp.mag];
pcp.statmean = reshape( (mean(pcp.num,1,'omitnan'))',[6,2])';
pcp.statstd = reshape( (std(pcp.num,1,'omitnan'))',[6,2])';
pcp.statobs = sum(~isnan(pcp.num(:,7:12)),1);

pcp.stat = [pcp.statmean;pcp.statstd;pcp.statobs];
pcp.stattbl = array2table( ...
    round(pcp.stat,3), ...
    'VariableNames',{'DD';'UU';'II';'DU';'UI';'DI';}, ...
    'RowNames',{ ...
    'MEAN Occurrence';'MEAN Magnitude'; ...
    'STD of Occurrence';'STD of Magnitude'; ...
    'Number of OBS'; ...
    });

disp('-------------------------------------------------------------------')
disp('[COL]     D: Decrease;        U: Unchange;        I: Increase      ')
disp('[ROW]     o: occurrence;                          m: magnitude     ')
disp(pcp.stattbl);
disp('-------------------------------------------------------------------')

% Latex Code
mat2tex( pcp.stat,'%.2f','nomath' )

%%  Construct New Dataset With occu/freq/magn                         (new)

new.newdata = pcp.num;
new.rawdata = raw.num;

% repeat each row (group) of the pcpdata x times,
% where x = number of observations within that group
% to get x, cannot just compress 'data.gp(:,2)'
% so
% 1) find first-apperience location of 'pcp.group' in 'pcp.groupall'
% 2) locate the x by this 'new.locate' in 'data.gp(:,2)'
[~,new.locate] = ismember(unique(data.gp(:,1)),data.gp(:,1),'rows');
new.repeart = data.gp(new.locate,2);
new.adddata = repelem(new.newdata,new.repeart,1);

new.rawname = raw.var;
new.addname = { ...
    'DD_o';'UU_o';'II_o';'DU_o';'UI_o';'DI_o'; ...
    'DD_m';'UU_m';'II_m';'DU_m';'UI_m';'DI_m'; ...
    };

% Output New Dataset
new.head = head;
new.path = path;

new.num = [new.rawdata,new.adddata];
new.tblnew = array2table(new.num, ...
    'VariableNames',[new.rawname;new.addname]);
new.tblold = array2table(new.rawdata, ...
    'VariableNames',new.rawname);

writetable(new.tblnew,[new.path,'_all.xlsx'], ...
    'WriteVariableNames',new.head,'Sheet', 'new');
writetable(new.tblold,[new.path,'_all.xlsx'], ...
    'WriteVariableNames',new.head,'Sheet', 'old');

%%  Study Price Change Patterns Across Sizes of Groups                (szs)

szs.head = head;
szs.path = path;

% locate where each group is first-appeared in original dataset
[~,szs.locate] = ismember(unique(data.gp(:,1)),data.gp(:,1),'rows');

% construct the dataset with three parts
% 1) the group variables: group index,size
% 2) the price change patterns (pcp) variables of groups: occ/mag
szs.rawdata = data.gp(szs.locate,1:2);
szs.newdata = pcp.num;
szs.dataset = [ szs.rawdata,szs.newdata ];

% specify the percentiles of interest
szs.percentile = [50:10:90,90+(2:2:10)]';

% specify the sorting postion (always = 2: the # of observations);
szs.sorting = 2;

% call function
[ szs.obsrow,szs.obsmat ] = ...
    namegroup_szs( szs.percentile,szs.sorting,szs.dataset );

% construct output tables
szs.tblr = array2table( szs.obsrow, ...
    'VariableNames',{
    'PERCENTILE';'GROUPOBS';'GROUPSIZE';
    'DD_o';'UU_o';'II_o';'DU_o';'UI_o';'DI_o'; ...
    'DD_f';'UU_f';'II_f';'DU_f';'UI_f';'DI_f'; ...
    'DD_m';'UU_m';'II_m';'DU_m';'UI_m';'DI_m'; ...
    });
szs.tblm = array2table( szs.obsmat, ...
    'VariableNames',{
    'PERCENTILE';'GROUPOBS';'GROUPSIZE';
    'DD_o';'UU_o';'II_o';'DU_o';'UI_o';'DI_o'; ...
    'DD_f';'UU_f';'II_f';'DU_f';'UI_f';'DI_f'; ...
    'DD_m';'UU_m';'II_m';'DU_m';'UI_m';'DI_m'; ...
    });

writetable(szs.tblr,[szs.path,'_szs.xlsx'], ...
    'WriteVariableNames',szs.head,'Sheet', 'row');
writetable(szs.tblm,[szs.path,'_szs.xlsx'], ...
    'WriteVariableNames',szs.head,'Sheet', 'mat');

% Latex Code
mat2tex( [ szs.obsrow;szs.obsmat ],'%.2f','nomath' );

%%  Save Dataset
save([path,'_data']);
