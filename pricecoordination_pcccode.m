function [ pcccode,pccpair ] = pricecoordination_pcccode( PRICECHANGE,COUNTRY,FULL )
%
%	Identification Pairs (idp)
%
%   FUNCTION:
%           Define Unique PCC (price-change-country) Codes & Code-Pairs.
%
%   INPUT:
%           pricechange -indicator codes of price-change
%           country     -indicator codes of country
%           full        -use all pricechange & country codes
%   OUTPUT:
%           code        -id for (country, price-change) codes
%           pair        -id for (country, price-change) code pairs
%
%   EXAMPLE:
%           Suppose
%           price-change codes : [Decrease,Increase] = [2,3]
%           country codes      : [US,UK,IT]          = [5,7,11]
%
%           Then
%           (country, price-change) codes are
%           -------------------------------
%           |    US   |    UK   |    IT   |
%           |     5   |     7   |    11   |
%           -------------------------------
%           |  D |  I |  D |  I |  D |  I |
%           |  2 |  3 |  2 |  3 |  2 |  3 |
%           -------------------------------
%           | 10 | 15 | 14 | 21 | 22 | 33 |
%           -------------------------------
%
%           Further
%           price-change pairs : [DD,DI,II]          = [4,6,9]
%           country pairs      : [US-UK,US-IT,UK-IT] = [35,55,77]
%
%           Note
%           price-change pairs can take two same codes, while
%           country pairs cannot.
%
%           Therefore
%           (country, price-change) code pairs are
%           -------------------------------------------------------
%           |      US-UK      |      US-IT      |      UK-IT      |
%           |         35      |         55      |         77      |
%           -------------------------------------------------------
%           |  DD |  DI |  II |  DD |  DI |  II |  DD |  DI |  II |
%           |   4 |   6 |   9 |   4 |   6 |   9 |   4 |   6 |   9 |
%           -------------------------------------------------------
%           | 140 | 210 | 315 | 220 | 330 | 495 | 308 | 462 | 693 |
%           -------------------------------------------------------
%

%%

p = PRICECHANGE;
c = COUNTRY;
f = FULL;

% unique price-change pair
% can include same indicators (diagonal)
pp = unique(triu(p*p',0));
pp = pp(2:end,:);

% unique country pair
% can NOT include same countries (diagonal)
cp = unique(triu(c*c',1));
cp = cp(2:end,:);

%%

% renew price-change "pair" for two reasons
% (1) take into account both uni- & bi- price-change patterns
% (2) rank these price-change patterns in the way of interest
% this need to be integrated in a better way, for now hardwire the codes

% | D | I | N | Missing | DD | II | DN | IN | DI | NN | Missing
% | 2 | 5 | 3 | 7       | 4  | 25 | 6  | 15 | 10 | 9  | 14,21,35,49
if f==1
    p  = [ 2; 5; 3; 7; ];
    pp = [ 4; 25; 6; 15; 10; 9; 14; 21; 35; 49; ];
end
%%

% unique (country, price-change) code
% element in the outer (Kronecker) product of
% country code and price-change code
pcccode = kron( p,c );
% the total elements = 4 * 7
% the first 7: p = 2
% the last  7: p = 7

%%
% unique (country, price-change) code pair
% element in the outer (Kronecker) product of
% (country,price-change) code and itself
pccpair = kron( pp,cp );
% the total elements = 10 * 21
% the first  21: pp = 4
% the last 4*21: pp = 14,21,35,49

end