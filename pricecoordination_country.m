function [ LOCATION,OCCURRENCE,MAGNITUDE ] = pricecoordination_country( INDICATOR,LEVEL,COUNTRY,CONDITIONAL )
%
%	pricecoordination_country
%
%   FUNCTION:
%           Calculate location/occurrence/magnitude
%
%   INPUT:
%           INDICATOR   -indicator of price-change
%           LEVEL       -level of the price-change
%           COUNTRY     -country numerical code
%           CONDITIONAL -calculate conditional/unconditional occurrence
%   OUTPUT:
%           LOCATION    -the location of non-missing pcp
%           OCCURRENCE  -the occurrence of non-missing pcp
%           MAGNITUDE   -the magnitude of non-missing pcp
%
%   EXAMPLE:
%
%   Define
%   a new country-price-change unique code, which is
%   the multiplication of country code and price-change code.
%
%   Suppose a group data
%   -----------------------------------------------------------------
%   | group | country | price-change indicator | price-change level |
%   -----------------------------------------------------------------
%   | 1     | CA ( 7) | Decrease (2)           | -0.80              |
%   | 1     | US (11) | Increase (3)           | +0.06              |
%   | 1     | SE (13) | Missing  (5)           | .                  |
%   -----------------------------------------------------------------
%
% Then the new country-price-change unique code is
%   -----------------------------------------------------------------------------
%   | group | NEW code  | country | price-change indicator | price-change level |
%   -----------------------------------------------------------------------------
%   | 1     | CA-D (14) | CA ( 7) | Decrease (2)           | -0.80              |
%   | 1     | US-I (33) | US (11) | Increase (3)           | +0.06              |
%   | 1     | SE-M (65) | SE (13) | Missing  (5)           | .                  |
%   -----------------------------------------------------------------------------
%
% Therefore can calculate, averaging across all observations in all groups
%   (1) the uni- & bi- pcp
%   (1) the uni- & bi- pcp within & across different countries & regions
%

%% INPUT
ind = INDICATOR;
lev = LEVEL;
cou = COUNTRY;
con = CONDITIONAL;

%% Price-Change-Country Code & Pairs
% define Code & Pair
[ pccode,pcpair ] = pricecoordination_pcccode( ...
	[2;5;3;7;],[17;19;23;29;31;37;41;],1);

univalueclass = pccode';
bivalueclass  = pcpair';
indcou = ind .* cou;

%% price change alone: uni-pc patterns

% vectorize original
indvec = indcou;
levvec = abs(lev);
valrow = univalueclass;

% match value of price change alone
indvecmat = repmat(indvec,1,size(valrow,2));
levvecmat = repmat(levvec,1,size(valrow,2));
valrowmat = repmat(valrow,size(indvec,1),1);

% match use uniqueness
unimatch = (indvecmat == valrowmat);
unicount = sum( unimatch,1 );
unichange = sum( levvecmat .* unimatch,1 );

% count the occurrence of each price change pattern
uniocc = unicount(:,1:28);
% total magnitudes of each price change pattern
unimag = unichange(:,1:28);

% correct for conditional calculation
uniconlocate = (uniocc == 0);
if con == 1
    uniocc(uniconlocate) = NaN;
    unimag(uniconlocate) = NaN;
end

%% price change pair: bi-pc patterns

% get the upper triangle matrix and vectorize
indmat = indcou * indcou';
indtri = triu(indmat,1);
indmat = indmat(:);
indtri = indtri(:);

% use uniqueness of indicator to get the index
index = (indmat==indtri);

% calculate the magnitudes
levmat = abs(lev - lev');
levmat = levmat(:);

% all price change pair combos
combination = indmat(index);
levelchange = levmat(index);
valuesclass = bivalueclass;

% adjust matrix size (compatibility with earlier version matlab)
%combinationmat = repmat(combination,1,size(valuesclass,2));
%levelchangemat = repmat(levelchange,1,size(valuesclass,2));
%valuesclassmat = repmat(valuesclass,size(combination,1),1);

% calculate the number of occurrence and average change of level
%match  = combinationmat == valuesclassmat;
%count  = sum( match,1 );
%change = sum( levelchangemat .* match,1 );

count  = NaN(size(valuesclass));
change = NaN(size(valuesclass));

for iterrow = 1:size(combination,1)

	combinationrow = combination(iterrow,:) .* ones(size(valuesclass));
	levelchangerow = levelchange(iterrow,:) .* ones(size(valuesclass));
	valuesclassrow = valuesclass;

	matchrow = combinationrow == valuesclassrow;
	levelrow = levelchangerow .* matchrow;

	count  = sum( [count ;matchrow;],1,'omitnan' );
	change = sum( [change;levelrow;],1,'omitnan' );

end

% count the occurrence of each price change pattern
biocc = count(:,1:210);
% total magnitudes of each price change pattern
bimag = change(:,1:210);

% correct for conditional calculation
biconlocate = (biocc == 0);
if con == 1
    biocc(biconlocate) = NaN;
    bimag(biconlocate) = NaN;
end

%% OUTPUT
LOCATION   = [ ~uniconlocate,~biconlocate ];
OCCURRENCE = [ uniocc,biocc ];
MAGNITUDE  = [ unimag,bimag ];

end
