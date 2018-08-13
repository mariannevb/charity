function [ DATASET ] = pricecoordination_dataset( DATARAW, GROUPK, PRICEK )
%
%   pricecoordination_dataset
%   This the function that pins down the dataset to be studied.
%
%   Input
%        DATARAW - raw dataset
%        GROUPK  - group definition number
%        PIRCEK  - price change number
%   Input
%        DATASET - main dataset
%

%%
% input
raw = DATARAW;
gpk = GROUPK;
pck = PRICEK;
%%
% deal with singleton groups based on the definition of group
% locate singleton-group observations by checking if size == 1
% delete them because no bi-price-change pattern within such groups
data.singleton = ( raw.gp( :,(gpk*3-2)+1 ) == 1 );
%%
% unique id of each observation
% 1st column: name
% 2nd column: year
% 3rd column: country
% 4th column: good
% 5th column: variety
% the problem with columns 1-5 is that, they cannot uniquely id each obs
% therefore, include additional two columns, egen from group in stata
% 6th column: good-variety
% 7th column: good-variety-country
data.id = raw.id(~data.singleton,:);
%%
% group definition that determines the subset to analyze
% 1st column: index of group
% 2nd column: number of observations within group
% 3rd column: index of observation within group
data.gp = raw.gp(~data.singleton,(gpk*3-2):(gpk*3));
%%
% modified price change variables with prime numbers and 99 versions
% 1st column: price change indicators
% 2nd column: price change levels
data.pc = raw.pc(~data.singleton,(pck*2-1):(pck*2));
%%
% country numerical code
%  1: us |  2: uk |  3: ca |  4: fr |  5: it |  6: de |  7: se
% 17: us | 19: uk | 23: ca | 29: fr | 31: it | 37: de | 41: se
data.cc = raw.id(~data.singleton,3);
%%
% output
DATASET = data;

end