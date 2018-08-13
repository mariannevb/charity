function [ location,occurrence,magnitude ] = coordination_coo( indicator,level,country,conditional )

%	Price Coordination (coo)
%
%   FUNCTION:
%           Calculate occurence/magnitude across indicator-country.
%
%   INPUT:
%           indicator   -indicator of price-change
%           level       -level of the price-change
%           country     -country numerical code
%           conditional -calculate conditional/unconditional occurrence
%   OUTPUT:
%           location    -the location of non-missing pcp
%           occurrence  -the occurrence of non-missing pcp
%           magnitude   -the magnitude of non-missing pcp
%
%   EXAMPLE:
%           Define
%           a new country-price-change unique code, which is
%           the multiplication of country code and price-change code.
%
%           Suppose a group data
%           -----------------------------------------------------------------
%           | group | country | price-change indicator | price-change level |
%           -----------------------------------------------------------------
%           | 1     | CA ( 7) | Decrease (2)           | -0.80              |
%           | 1     | US (11) | Increase (3)           | +0.06              |
%           | 1     | SE (13) | Missing  (5)           | .                  |
%           -----------------------------------------------------------------
%
%           Then the new country-price-change unique code is
%           -----------------------------------------------------------------------------
%           | group | NEW code  | country | price-change indicator | price-change level |
%           -----------------------------------------------------------------------------
%           | 1     | CA-D (14) | CA ( 7) | Decrease (2)           | -0.80              |
%           | 1     | US-I (33) | US (11) | Increase (3)           | +0.06              |
%           | 1     | SE-M (65) | SE (13) | Missing  (5)           | .                  |
%           -----------------------------------------------------------------------------
%
%           Therefore can calculate, averaging across all observations in all groups
%           (1) the uni- & bi- pcp
%           (1) the uni- & bi- pcp within & across different countries & regions
%


%% INPUT
ind = indicator;
lev = level;
cou = country;
con = conditional;

%% Country-PriceChange Indicator
% define Code & Pair
[ code,pair ] = coordination_idp( [2;3;5;7;],[11;13;17;19;23;29;31;] );
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
valuesclass = pair';

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
location   = [ ~uniconlocate,~biconlocate ];
occurrence = [ uniocc,biocc ];
magnitude  = [ unimag,bimag ];

end
