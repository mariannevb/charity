function [ pairs ] = coordination_idp( indicator,country )

%	Identification Pairs (idp)
%
%   FUNCTION:
%           Define Unique Indicator Country Identification (ID) Pairs
%
%   INPUT:
%           indicator   -indicator of price change direction
%           country     -code for country
%   OUTPUT:
%           pairs       -the unique indicator country pairs
%
%   EXAMPLE:
%           Suppose 
%           the price indicators: [Decrease,Increase] = [2,3]
%           the country code: [US,UK,IT] = [5,7,11]
%           Then
%           the unique indicator pairs are [DD,DI,II] = [4,6,9]
%           the unique country pairs are [US-UK,US-IT,UK-IT] = [35,55,77]
%           (note: cannot have two identical countries in a country pair)
%           Therefore
%           the unique identification pairs are
%           [      US-UK,      US-IT,      UK-IT,]
%           [-----------,-----------,-----------,]
%           [ DD, DI, II, DD, DI, II, DD, DI, II,]
%           [---,---,---,---,---,---,---,---,---,]
%           [140,210,315,220,330,495,308,462,693,]
%

% unique indicator pair
% total of 10=(4+1)*4/2; a pair can include same indicators (diagonal)

%indicatorpair = unique(triu(indicator*indicator',0));
%indicatorpair = indicatorpair(2:end,:);

indicatorpair = [ 4, 9,25, 6,15,10,14,21,35,49]';

% unique country pair
% total of 21=(6+1)*6/2; a pair can NOT include same countries (diagonal)
countrypair = unique(triu(country*country',1));
countrypair = countrypair(2:end,:);

% unique pair
% total of 210=10*21; a pair is a element in the outer (Kronecker) product
pairs = kron(countrypair,indicatorpair);

end