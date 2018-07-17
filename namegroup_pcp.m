function [ location,occurrence,magnitude ] = namegroup_pcp( indicator,level,conditional )

%	Price Change Pattern (pcp)
%
%   FUNCTION:
%           Calculate occurence, frequency, magnitude
%           of each possible price change pattern.
%
%   INPUT:
%           indicator   -indicator of price change direction
%           level       -level of the price change
%           conditional -calculate conditional/unconditional occurrence
%   OUTPUT:
%           location    -the location of non-missing pcp
%           occurrence  -the occurrence of non-missing pcp
%           magnitude   -the magnitude of non-missing pcp
%
%   EXAMPLE:
%			Definition of change: D=decrease; I=increase; N=no-change
%
%			Then there are 3 uni-pc patterns,
%           pcp | D  | I  | N  | Missing
%           ind | 2  | 5  | 3  | 7
%			and 6 bi-pc patterns
%           pcp | DD | II | DN | IN | DI | NN | Missing
%           ind | 4  | 25 | 6  | 15 | 10 | 9  | 14,21,35,49
%
%			That is, the price change patterns are
%           pcp | D  | I  | N  | DD | II | DN | IN | DI | NN | Missing
%           ind | 2  | 5  | 3  | 4  | 25 | 6  | 15 | 10 | 9  | 7,14,21,35,49
%
%           Suppose a group data
%           group | good-variety | change  | indicator(prime) | level
%           1     | 1            | I       | +1   (5)         | +0.80
%           1     | 2            | I       | +1   (5)         | +0.06
%           1     | 3            | Missing | .    (7)         | .
%           1     | 4            | N       | 0    (3)         | 0
%
%           Then if conditional,
%           pcp | D   | I    | N    | DD  | II   | DN  | IN   | DI  | NN  | Missing
%           ind | 2   | 5    | 3    | 4   | 25   | 6   | 15   | 10  | 9   | 7,14,21,35,49
%           loc | 0   | 1    | 1    | 0   | 1    | 0   | 1    | 0   | 0   | nan
%           occ | nan | 2    | 1    | nan | 1    | nan | 2    | nan | nan | 4
%           mag | nan | 0.86 | 0.00 | nan | 0.74 | nan | 0.86 | nan | nan | nan
%
%           and if unconditional,
%           pcp | D   | I    | N    | DD  | II   | DN  | IN   | DI  | NN  | Missing
%           ind | 2   | 5    | 3    | 4   | 25   | 6   | 15   | 10  | 9   | 7,14,21,35,49
%           loc | 0   | 1    | 1    | 0   | 1    | 0   | 1    | 0   | 0   | nan
%           occ | 0   | 2    | 1    | 0   | 1    | 0   | 2    | 0   | 0   | 4
%           mag | 0   | 0.86 | 0.00 | 0   | 0.74 | 0   | 0.86 | 0   | 0   | .

%% INPUT
ind = indicator;
lev = level;
con = conditional;

%% price change alone: uni-pc patterns

% vectorize original
indvec = ind;
levvec = abs(lev);
valrow = [2,5,3,7];

% match value of price change alone
indvecmat = repmat(indvec,1,size(valrow,2));
levvecmat = repmat(levvec,1,size(valrow,2));
valrowmat = repmat(valrow,size(indvec,1),1);

% match use uniqueness
unimatch = (indvecmat == valrowmat);
unicount = sum( unimatch,1 );
unichange = sum( levvecmat .* unimatch,1 );

% count the occurrence of each price change pattern
uniocc = unicount(:,1:3);
% total magnitudes of each price change pattern
unimag = unichange(:,1:3);

% correct for conditional calculation
uniconlocate = (uniocc == 0);
if con == 1
    uniocc(uniconlocate) = NaN;
    unimag(uniconlocate) = NaN;
end

%% price change pair: bi-pc patterns

% get the upper triangle matrix and vectorize
indmat = ind * ind';
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
% (-1=2) (0=3) (1=5) (.=7)
valuesclass = [4,25,6,15,10,9,14,21,35,49];

% adjust matrix size (compatibility with earlier version matlab)
combinationmat = repmat(combination,1,size(valuesclass,2));
levelchangemat = repmat(levelchange,1,size(valuesclass,2));
valuesclassmat = repmat(valuesclass,size(combination,1),1);

% calculate the number of occurrence and average change of level
match = combinationmat == valuesclassmat;
count = sum( match,1 );
change = sum( levelchangemat .* match,1 );

% count the occurrence of each price change pattern
biocc = count(:,1:6);
% total magnitudes of each price change pattern
bimag = change(:,1:6);

% correct for conditional calculation
biconlocate = (biocc == 0);
if con == 1
    biocc(biconlocate) = NaN;
    bimag(biconlocate) = NaN;
end

%% OUTPUT
location   = [ ~uniconlocate,~biconlocate ];
occurrence = [ uniocc,biocc ];
magnitude  = [ unimag,bimag ];

end