function [ STATWITHIN,STATACROSS ] = pricecoordination_basestat( DATARAW,GROUPK,PRICEK,CONDITIONAL )
%
%   pricecoordination_basestat
%   This is the function that calculate summary statistics of
%   occurrence, frequency, magnitude, and de-in-no weights
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
%
%   Example of within- & cross- country comovement.
%   Year is held fixed when calculating both of these.
%
%   For this measure of comovement, we use 'ij' as the measure of a 'good'
%   So the red and blue billy bookcases are considered different goods.
%
%           US  FR  SE
%   table   I   D   I
%   chair   I   I   I
%   lamp    I   I   D
%
%   Within US comovement
%   There are 3 pairs: table/chair,table/lamp,chair/lamp, they are all II.
%
%           DD  II  DI
%   Occ     0   3   0
%   Freq    0   1   0
%
%   Cross country comovement
%   Comparing good "m" in the US to all goods
%   that are NOT "m" in the other countries
%
%   For US-France, there are 6 pairs
%   US table/FR chair, US table/FR lamp, US chair/FR table,
%   US chair/FR lamp,  US lamp/FR table, US lamp/FR chair,
%   For US-France, the scores are
%   II, II, DI, II, DI, II
%
%   For US-Sweden there are also 6 pairs.
%   The US-Sweden scores are II, DI, II, DI, II, DI.
%
%   Overall statistics for cross-country comovement:
%           DD      II      DI
%   Occ     0       7       5
%   Freq    0.00    0.58    0.42

%%  Prepare

% prepare dataset to be analyzed
raw = DATARAW;
gpk = GROUPK;
pck = PRICEK;

DATA = pricecoordination_dataset( raw,gpk,pck );

%% input

GROUP      = unique(DATA.gp(:,1));
GROUPALL   = DATA.gp(:,1);
YEAR       = unique(DATA.id(:,2));
COUNTRY    = unique(DATA.id(:,3));
INDICATOR  = DATA.pc(:,1);
LEVEL      = DATA.pc(:,2);
COUNTRYALL = DATA.cc;

% pass to input
group      = GROUP;
groupall   = GROUPALL;
year       = YEAR;
country    = COUNTRY;
indicator  = INDICATOR;
level      = LEVEL;
countryall = COUNTRYALL  ;
con        = CONDITIONAL;

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
loc = NaN( size(year,1) * size(country,1) ,9);
occ = NaN( size(year,1) * size(country,1) ,9);
mag = NaN( size(year,1) * size(country,1) ,9);

for iteryear = 1:size(year,1)
    for itercountry = 1:size(country,1)

        % index
        yearcountryindex = (iteryear -1) * size(country,1) + itercountry;

        % look for (year & country)
        tempyear = year(iteryear,:);
        tempcountry = country(itercountry,:);

        % locate the (year & country) in dataset
        tempyearcountrylocate = and( ...
            DATA.id(:,2) == tempyear, DATA.id(:,3) == tempcountry );

        % get the price change indicators and levels
        tempyearcountryind = indicator( tempyearcountrylocate,: );
        tempyearcountrylev = level( tempyearcountrylocate,: );

        % calcaulte of each price change pattern: frequency and magnitude
        [ temploc,tempocc,tempmag ] = pricecoordination_pattern( ...
            tempyearcountryind,tempyearcountrylev,con );

        % output: year & country
        loc(yearcountryindex,:) = temploc;
        occ(yearcountryindex,:) = tempocc;
        mag(yearcountryindex,:) = tempmag;

    end
end

% within country statistics
occwithin = [ ...
    sum( occ( [1,  8, 15, 22, 36, 43, 50, 57, 64] ,:),1,'omitnan') ; ...
    sum( occ( [2,  9, 16, 23, 37, 44, 51, 58, 65] ,:),1,'omitnan') ; ...
    sum( occ( [3, 10, 17, 24, 38, 45, 52, 59, 66] ,:),1,'omitnan') ; ...
    sum( occ( [4, 11, 18, 25, 39, 46, 53, 60, 67] ,:),1,'omitnan') ; ...
    sum( occ( [5, 12, 19, 26, 40, 47, 54, 61, 68] ,:),1,'omitnan') ; ...
    sum( occ( [6, 13, 20, 27, 41, 48, 55, 62, 69] ,:),1,'omitnan') ; ...
    sum( occ( [7, 14, 21, 28, 42, 49, 56, 63, 70] ,:),1,'omitnan') ; ...
    sum( occ(                                   : ,:),1,'omitnan') ; ...
    ];
magwithin = [ ...
    sum( mag( [1,  8, 15, 22, 36, 43, 50, 57, 64] ,:),1,'omitnan') ; ...
    sum( mag( [2,  9, 16, 23, 37, 44, 51, 58, 65] ,:),1,'omitnan') ; ...
    sum( mag( [3, 10, 17, 24, 38, 45, 52, 59, 66] ,:),1,'omitnan') ; ...
    sum( mag( [4, 11, 18, 25, 39, 46, 53, 60, 67] ,:),1,'omitnan') ; ...
    sum( mag( [5, 12, 19, 26, 40, 47, 54, 61, 68] ,:),1,'omitnan') ; ...
    sum( mag( [6, 13, 20, 27, 41, 48, 55, 62, 69] ,:),1,'omitnan') ; ...
    sum( mag( [7, 14, 21, 28, 42, 49, 56, 63, 70] ,:),1,'omitnan') ; ...
    sum( mag(                                   : ,:),1,'omitnan') ; ...
    ];

%%  Calculate Average Group Occurrence, Frequency, Magnitude, De-In-No

% calculate total occurrence across all patterns
% which is sum of occurrence of all groups
totocc = occwithin;

% calculate average magnitude across all patterns
% which is sum of total magnitudes of all groups over the total occurrence
avgmag = magwithin ./ totocc;

% calculate total frequency across all patterns
totfrq = [ ...
    totocc(:,1:3) ./ sum( totocc(:,1:3) ,2,'omitnan'),...
    totocc(:,4:9) ./ sum( totocc(:,4:9) ,2,'omitnan'),...
    ];

% statistics: occurrence, frequency, magnitude
statwithin = [ totocc,totfrq,avgmag, ];

% output
STATWITHIN = statwithin;

%%  Calculate Price Change Patterns

% preallocation of occurrence, magnitude
% different from previous patterns
% the new patterns incorporate the country code as a new dimension
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
    tempccode = countryall( templocat,: );

    % calculate of each price change pattern across countries
    [ temploc,tempocc,tempmag ] = ...
        pricecoordination_country( temppcind,temppclev,tempccode,con );

    % output
    loc(itergroup,:) = temploc;
    occ(itergroup,:) = tempocc;
    mag(itergroup,:) = tempmag;

end

%%  Compare Price Coordination Within/Across Seven Countries
%   for each country (XX), define three comparison
%   (a) xx   - within country XX : XX = us/uk/ca/fr/it/de/se
%   (b) nxx  - within countries other than xx
%   (c) xxno - across XX and NXX countries : 1 from XX + 1 from NXX

% country code
% 17: us | 19: uk | 23: ca | 29: fr | 31: it | 37: de | 41: se
% unique indicator codes for uni- & bi- price change patterns
% this is the benchmark, regions are defined as 'ismember' of these
[ pccode,pcpair ] = pricecoordination_pcccode( ...
	[2;5;3;7;],[17;19;23;29;31;37;41;],1);

% (0) within All (all) region
[ allone,alltwo ] = pricecoordination_pcccode( ...
	[2;5;3;],[17;19;23;29;31;37;41;],0);
% (1.c) across US and NUS (USNO)
usnoone = kron( [2;5;3;],                [17;   19;23;29;31;37;41;]     );
usnotwo = kron( [4;25;6;15;10;9;], kron( [17;],[19;23;29;31;37;41;] )   );
% (2.c) across UK and NUK (UKNO)
uknoone = kron( [2;5;3;],                [19;   17;23;29;31;37;41;]     );
uknotwo = kron( [4;25;6;15;10;9;], kron( [19;],[17;23;29;31;37;41;] )   );
% (3.c) across CA and NCA (CANO)
canoone = kron( [2;5;3;],                [23;   17;19;29;31;37;41;]     );
canotwo = kron( [4;25;6;15;10;9;], kron( [23;],[17;19;29;31;37;41;] )   );
% (4.c) across FR and NFR (FRNO)
frnoone = kron( [2;5;3;],                [29;   17;19;23;31;37;41;]     );
frnotwo = kron( [4;25;6;15;10;9;], kron( [29;],[17;19;23;31;37;41;] )   );
% (5.c) across IT and NIT (ITNO)
itnoone = kron( [2;5;3;],                [31;   17;19;23;29;37;41;]     );
itnotwo = kron( [4;25;6;15;10;9;], kron( [31;],[17;19;23;29;37;41;] )   );
% (6.c) across DE and NDE (DENO)
denoone = kron( [2;5;3;],                [37;   17;19;23;29;31;41;]     );
denotwo = kron( [4;25;6;15;10;9;], kron( [37;],[17;19;23;29;31;41;] )   );
% (7.c) across SE and NSE (SENO)
senoone = kron( [2;5;3;],                [41;   17;19;23;29;31;37;]     );
senotwo = kron( [4;25;6;15;10;9;], kron( [41;],[17;19;23;29;31;37;] )   );

% summary of locations across all six regions
% the region is defined by indicators of price change patterns
acrosslocate = [ ...
    ismember(pccode,usnoone)', ismember(pcpair,usnotwo)'; ...
    ismember(pccode,uknoone)', ismember(pcpair,uknotwo)'; ...
    ismember(pccode,canoone)', ismember(pcpair,canotwo)'; ...
    ismember(pccode,frnoone)', ismember(pcpair,frnotwo)'; ...
    ismember(pccode,itnoone)', ismember(pcpair,itnotwo)'; ...
    ismember(pccode,denoone)', ismember(pcpair,denotwo)'; ...
    ismember(pccode,senoone)', ismember(pcpair,senotwo)'; ...
    ismember(pccode,allone )', ismember(pcpair,alltwo )'; ...
    ];

% preallocation
statacross = NaN( size(acrosslocate,1),27 );

for iteracross = 1:size(acrosslocate,1)

    % the region is defined by indicators of price change patterns
    tempacross = acrosslocate(iteracross,:);

    % call function to give the regional statistics
    tempregionstat = pricecoordination_region( tempacross,occ,mag );

    % output
    statacross(iteracross,:) = tempregionstat;

end

%
STATACROSS = statacross;

end

