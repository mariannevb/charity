function [ occurrence,magnitude ] = coordination_coo( indicator,level,country,conditional )

%	Price Coordination (coo)
%
%   FUNCTION:
%           Calculate occurence/magnitude across indicator-country.
%
%   INPUT:
%           indicator   -indicator of price change direction
%           level       -level of the price change
%           country     -country numerical code
%           conditional -calculate conditional/unconditional occurrence
%   OUTPUT:
%           occurrence  -the number of occurences
%           magnitude   -the magnitude
%
%   EXAMPLE:
%           Suppose a group data
%           group   country         indicator     level
%           1       CA              D             -0.80
%           1       US              I             +0.06
%           1       SE              Missing           .
%           Define a NEW ID by multiplication of (country, indicator)
%           group   ID               level
%           1       CA*D             -0.80
%           1       US*I             +0.06
%           1       SE*Missing           .
%           With NEW ID, the calculation is exactly as in pcp function
%
%           I define countries to be
%           11 = us, 13 = uk, 17 = ca, 19 = fr, 23 = it, 29 = de, 31 = se
%           and indicators to be
%           decrease = 2, unchange = 3, increase = 5, missing = 7
%           So, within any group the ID is unique.


%% INPUT
ind = indicator;
lev = level;
cou = country;
con = conditional;

%% Define Unique Country-Indicator ID
pairs = coordination_idp( [2;3;5;7;],[11;13;17;19;23;29;31;] );
indcou = ind .* cou;

%% Calculate Occurrence / Magnitude

% get the upper triangle matrix and vectorize
indmat = indcou * indcou';
indtri = triu(indmat,1);
indmat = indmat(:);
indtri = indtri(:);

% use uniqueness of indicator to get the index
index = indmat==indtri;

% calculate the magnitudes
levmat = abs(lev - lev');
levmat = levmat(:);

% all price change combos
combination = indmat(index);
levelchange = levmat(index);
valuesclass = pairs';

% adjust matrix size (compatibility with earlier version matlab)
combinationmat = repmat(combination,1,size(valuesclass,2));
levelchangemat = repmat(levelchange,1,size(valuesclass,2));
valuesclassmat = repmat(valuesclass,size(combination,1),1);

% calculate the number of occurrence and average change of level
match = combinationmat == valuesclassmat;
count = sum( match,1 );
change = sum( levelchangemat .* match,1 );

% count the occurence of each price change pattern
occ = count;
mag = change ./ count;

%% Conditional

if con == 1, occ(occ == 0) = NaN;  end;

%% OUTPUT
occurrence = occ;
magnitude  = mag;

end
