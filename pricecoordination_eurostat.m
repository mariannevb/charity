function [ STAT ] = pricecoordination_eurostat( DATARAW, GROUPK, PRICEK,CONDITIONAL )
%
%   pricecoordination_eurostat
%   This is the function that calculate summary statistics of
%   occurence, frequency, magnitude, and de-in-no weights
%   of each possible price change pattern across regions.
%   There are 9 price change patterns.
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
GROUP     = unique(DATA.gp(:,1));
GROUPALL  = DATA.gp(:,1);
INDICATOR = DATA.pc(:,1);
LEVEL     = DATA.pc(:,2);
COUNTRY   = DATA.cc;

%% input
group     = GROUP    ;
groupall  = GROUPALL ;
indicator = INDICATOR;
level     = LEVEL    ;
country   = COUNTRY  ;
con       = CONDITIONAL;

%%  Calculate Price Change Patterns

% preallocation of occurrence, magnitude
% different from previous patterns
% the new patterns incoporate the country code as a new dimension
% the 28 = 7*4 is the uni-variant country-price-change patterns
% that is, there are 7 countries and 3 price-change indicators
% the 210 = 21*10 is the bi-variant country-price-change patterns
% that is, there are 21 country pairs and 6 price-change indicator pairs
loc = NaN( size(group,1), 7*4+21*10);
occ = NaN( size(group,1), 7*4+21*10);
mag = NaN( size(group,1), 7*4+21*10);

for itergroup = 1:size(group,1)

    % locate the group in dataset
    tempgroup = group(itergroup,1);
    templocat = (groupall == tempgroup);

    % get the pc indicators and levels of the group
    temppcind = indicator( templocat,: );
    temppclev = level( templocat,: );

    % get the country code of the group
    tempccode = country( templocat,: );

    % calcaulte of each price change pattern across countries
    [ temploc,tempocc,tempmag ] = ...
        pricecoordination_country( temppcind,temppclev,tempccode,con );

    % output
    loc(itergroup,:) = temploc;
    occ(itergroup,:) = tempocc;
    mag(itergroup,:) = tempmag;

end

%%  Compare Price Coordination Across Six Regions
%   the six regions are as follows
%   (1) eu   - within Euro Union region     : FR + IT + DE
%   (2) na   - within North America region  : CA + US
%   (3) no   - within Non-Euro Union region : CA + US + UK + SE
%   (4) euna - across EU and NA regions     : 1 from EU + 1 from NA
%   (5) euno - across EU and NO regions     : 1 from EU + 1 from NO
%   (6) all  - any

% country code
% 17: us | 19: uk | 23: ca | 29: fr | 31: it | 37: de | 41: se
% unique indicator codes for uni- & bi- price change patterns
% this is the benchmark, regions are defined as 'ismember' of these
[ pccode,pcpair ] = pricecoordination_pcccode( ...
	[2;5;3;7;],[17;19;23;29;31;37;41;],1);

% (6) within All (all) region
[ allone,alltwo ] = pricecoordination_pcccode( ...
	[2;5;3;],[17;19;23;29;31;37;41;],0);

% (1) within Euro Union (EU) region
[ euone,eutwo ] = pricecoordination_pcccode( ...
	[2;5;3;],[29;31;37;],0);
% (2) within North America (NA) region
[ naone,natwo ] = pricecoordination_pcccode( ...
	[2;5;3;],[17;23;],0);
% (3) within Non Euro Union (NO) region
[ noone,notwo ] = pricecoordination_pcccode( ...
	[2;5;3;],[17;19;23;41;],0);

% (4) across EU and NA regions
eunaone = kron( [2;5;3;], [29;31;37;17;23;] );
eunatwo = kron( [4;25;6;15;10;9;], kron( [29;31;37;],[17;23;] ) );
% (5) across EU and NO regions
eunoone = kron( [2;5;3;], [29;31;37;17;19;23;41;] );
eunotwo = kron( [4;25;6;15;10;9;], kron( [29;31;37;],[17;19;23;41;] ) );

% summary of locations across all six regions
% the region is defined by indicators of price change patterns
regionlocate = [ ...
    ismember(pccode,euone)'  ,  ismember(pcpair,eutwo)'  ; ...
    ismember(pccode,naone)'  ,  ismember(pcpair,natwo)'  ; ...
    ismember(pccode,noone)'  ,  ismember(pcpair,notwo)'  ; ...
    ismember(pccode,eunaone)',  ismember(pcpair,eunatwo)'; ...
    ismember(pccode,eunoone)',  ismember(pcpair,eunotwo)'; ...
    ismember(pccode,allone)' ,  ismember(pcpair,alltwo)' ; ...
    ];

% preallocation
regionstat = NaN( size(regionlocate,1),27 );

for iterregion = 1:size(regionlocate,1)

    % the region is defined by indicators of price change patterns
    tempregion = regionlocate(iterregion,:);

    % call function to give the regional statistics
    tempregionstat = ...
        pricecoordination_region( tempregion,occ,mag );

    % output
    regionstat(iterregion,:) = tempregionstat;

end

%% output
STAT = regionstat;

end

