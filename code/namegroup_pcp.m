function [ occurrence,magnitude ] = namegroup_pcp( indicator,level,conditional )

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
%           occurrence  -the number of occurent of different pcp
%           frequency   -the frequency of non-missing pcp
%           magnitude   -the magnitude of non-missing pcp
%
%   EXAMPLE:
%           Suppose a group data
%           group   good-variety    indicator   level
%           1       1               -1          -0.80
%           1       2               +1          +0.06
%           1       3               .           .
%           Then there are 3 bi-price-change combination
%                         [  4,  9, 25,  6, 15, 10, 14, 21, 35, 49];
%           count       = [  0,  0,  0,  0,  0,  1,  1,  0,  1,  0];
%                                                  ---------------
%           If unconditional,
%           occurrence  = [  0,  0,  0,  0,  0,  1,];
%           frequency   = [  0,  0,  0,  0,  0,  1,];
%           occurrence  = [nan,nan,nan,nan,nan,.86,];
%
%           If conditional,
%           occurrence  = [nan,nan,nan,nan,nan,  1,];
%           frequency   = [nan,nan,nan,nan,nan,  1,];
%           occurrence  = [nan,nan,nan,nan,nan,.86,];


%% INPUT
ind = indicator;
lev = level;
con = conditional;

%%

% get the upper triangle matrix and vectorize
indmat = ind * ind';
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
% (-1=2) (0=3) (1=5) (.=7)
valuesclass = [4,9,25,6,15, 10, 14,21,35,49];

% adjust matrix size (compatibility with earlier version matlab)
combinationmat = repmat(combination,1,size(valuesclass,2));
levelchangemat = repmat(levelchange,1,size(valuesclass,2));
valuesclassmat = repmat(valuesclass,size(combination,1),1);

% calculate the number of occurrence and average change of level
match = combinationmat == valuesclassmat;
count = sum( match,1 );
change = sum( levelchangemat .* match,1 );

% count the occurence of each price change pattern
occ = count(:,1:6);

% calculate average price change magnitudes
% if 0: average price change is zero
% if nan: no such price change pattern (divided by 0)
mag = change(:,1:6) ./ count(:,1:6);

%
% conditionone = sum(count(:,1:6),2) == 0;
% conditiontwo = sum(count(:,7:end),2) == 0;
%
% if and( conditionone,~conditiontwo )
%     freq = [ ...
%         0,0,0,0,0,0, ...
%         -99, ...
%         ];
% elseif and( ~conditionone,conditiontwo )
%     freq = [ ...
%         count(:,1:6) ./ sum(count(:,1:6),2), ...
%         99, ...
%         ];
% else
%     freq = [ ...
%         count(:,1:6) ./ sum(count(:,1:6),2), ...
%         sum(count(:,1:6),2) ./ sum(count(:,7:end),2), ...
%         ];
% end

%%

if con == 1
    occ(occ == 0) = NaN;
end

%% OUTPUT
occurrence = occ;
magnitude  = mag;

end