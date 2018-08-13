function [ STATNUM,PERSTATROW,PERSTATMAT ] = pricecoordination_namestat( DATARAW, GROUPK, PRICEK,CONDITIONAL )
%
%   pricecoordination_namestat
%   This is the function that calculate summary statistics of
%   occurence, frequency, magnitude, and de-in-no weights
%   of each possible price change pattern across all groups
%   Suppose there are N groups. There are 9 price change patterns.
%   The first three are uni-variant, and the left six are bi-variant.
%
%   Input
%        DATARAW     - raw dataset
%        GROUPK      - group definition number
%        PIRCEK      - price change number
%        CONDITIONAL - use conditional calculation
%
%        DATASET     - main dataset
%
%        GROUP       - the index data of group definition
%        INDICATOR   - the price chagne indicator data
%        LEVEL       - the price change level data
%   Input
%        STAT        - the summary statistics of price change patterns

%%  Prepare
% prepare dataset to be analyzed
raw = DATARAW;
gpk = GROUPK;
pck = PRICEK;

DATA = pricecoordination_dataset( raw,gpk,pck );

% assign the correct column as input
GROUP     = DATA.gp(:,1);
INDICATOR = DATA.pc(:,1);
LEVEL     = DATA.pc(:,2);

%% input
group     = unique(GROUP);
groupall  = GROUP;
indicator = INDICATOR;
level     = LEVEL;
con       = CONDITIONAL;

%%  Calculate Each Group's Location, Occurrence, Magnitude

% D - decrease ; I - increase ; N - nochange ;
% store (LOC OCC MAG) in 9 columns as follows:
% 1st - 3rd columns : price change patterns      :  D,  I,  N
% 4th - 9th columns : price change pair patterns : DD, II, DN, IN, DI, NN
%
% LOC is indicator of existing patterns
% OCC is counted using conditional version
% MAG is stored as total value

% preallocation
loc = NaN(size(group,1),9);
occ = NaN(size(group,1),9);
mag = NaN(size(group,1),9);

for itergroup = 1:size(group,1)

    % locate the group in dataset
    tempgroup = group(itergroup,1);
    templocat = groupall == tempgroup;

    % get the price change indicators and levels of the group
    temppcind = indicator( templocat,: );
    temppclev = level( templocat,: );

    % calcaulte of each price change pattern: frequency and magnitude
    [ temploc,tempocc,tempmag ] = ...
        pricecoordination_pattern( temppcind,temppclev,con );

    % output
    loc(itergroup,:) = temploc;
    occ(itergroup,:) = tempocc;
    mag(itergroup,:) = tempmag;

end

%%  Calculate Average Group Occurrence, Frequency, Magnitude, De-In-No

% calculatte average DIN magnitude across all patterns
% D=decrease; I=increase; N=no-change
% see the function for more details
avgdin = pricecoordination_deinno( loc,occ,mag );

% calculate total occurrence across all patterns
% which is sum of occurrence of all groups
totocc = sum( occ, 1,'omitnan' );

% calculate average magnitude across all patterns
% which is sum of total magnitudes of all groups over the total occurrence
avgmag = sum( mag, 1,'omitnan' ) ./ totocc;

% calculate total frequency across all patterns
totfrq = [ ...
    totocc(:,1:3) ./ sum( totocc(:,1:3) ),...
    totocc(:,4:9) ./ sum( totocc(:,4:9) ),...
    ];

% Output all groups OCC and MAG across all patterns
stat = [ totocc;totfrq;avgmag;avgdin; ];

%%  Study Price Change Patterns Across Sizes of Groups

% locate where each group is first-appeared in original dataset
[~,grouplocate] = ismember(group,groupall,'rows');

% construct the dataset with three parts
% 1) the group variables: group index,size
% 2) the price change patterns (pcp) variables of groups: occ/mag
perdataset = [ DATA.gp(grouplocate,1:2),occ,mag ];

% specify the percentiles of interest
pervector = [50:10:90,90+(2:2:10)]';

% specify the sorting postion (always = 2: the # of observations);
persort = 2;

% call function to give at/between percentiles summary statistics
[ perstatrow,perstatmat ] = ...
    pricecoordination_sizeper( pervector,persort,perdataset );

%%
% output
STATNUM = stat;
PERSTATROW = perstatrow;
PERSTATMAT = perstatmat;

end
