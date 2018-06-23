function [ obsrow,obsmat ] = namegroup_szs( percentile,sorting,dataset )

%	Patterns By Size Percentile (szs)
%
%   FUNCTION:
%           Calculate price change patterns
%           across size percentiles.
%
%   INPUT:
%           percentile  -vector, percentiles of interest
%           sorting     -integer, the sorting vatiable position in dataset
%           dataset     -matrix, the dataset, each row being a group
%   OUTPUT:
%           obsrow      -matrix, the observations at those percentiles
%           obsmat      -matrix, the observations between those percentiles
%
%   EXAMPLE:
%           Given the dataset
%           group   groupsize    variables (occu/freq/magn)
%           1       2            0.4
%           3       3            0.3
%           5       3            0.1
%           4       4            0.6
%           2       6            0.8
%
%           Suppose
%           (1) the percentiles of interest
%           [10,50,90]
%           (2) the sorting variable position
%           2
%
%           Then
%           (1) obsrow calculates the variables (occu/freq/magn)
%                      of observations AT the percentiles
%
%           percentile      groupsize       variables (occu/freq/magn)
%           10              2               0.4
%           50              3               0.1
%           90              6               0.8
%           (2) obsmat calculates the variables (occu/freq/magn)
%                      average of observations BETWEEN the percentiles
%
%           percentile      groupsize       variables (occu/freq/magn)
%           10              2               0.4
%           50              3 = (3+3)/2     0.2 = (0.3+0.1)/2
%           90              5 = (4+6)/2     0.7 = (0.6+0.8)/2
%

%% INPUT
per = percentile;
sgp = sorting;
data = dataset;

%% Get Index in Dataset of Each 1-Percentile

% the dataset has 19491 observations (groups)
% so roughly 195 observation within 1-percentile
numobs = size(data,1);
indexpercentile = [1:1:numobs;linspace(0,100,numobs)];

% the index location contains two columns
% indexlocation(90,:) = [   90th-percentile first observation index,
%                           90th-percentile last observation index]
indexlocation = zeros(100,2);

% for each percentile x, find location in the original dataset
% that has percentile >x-1 and <=x (linear interpolation)
for iterper = 1:100
    tempidx = indexpercentile(1, ...
        and(indexpercentile(2,:)<=iterper,indexpercentile(2,:)>iterper-1) ...
        );
    indexlocation(iterper,:) = [tempidx(:,1),tempidx(:,end),];
end

% Sort Dataset According To Sorting Column
sorted = sortrows(data,sgp);

%% Obtain Observations At/Between Those Percentiles

% Locate The Observation At Percentiles
perlocation = indexlocation(per,:);

% Preallocation
observationrow = NaN(size(perlocation,1),21);
observationmat = NaN(size(perlocation,1),21);

for iterlocation = 1:size(perlocation,1)
    % location indices of 'this' and 'last' percentiles
    tempthis = perlocation(iterlocation,:);
    if iterlocation == 1
        templast = [0,0];
    else
        templast = perlocation(iterlocation-1,:);
    end
    
    temprow = sorted(tempthis(:,1):tempthis(:,2),:);
    tempmat = sorted(templast(:,2)+1:tempthis(:,2),:);
    
    % calculate average average of those observations
    
    % keep information percentile, number of group,
    temprowper = per(iterlocation,:);
    tempmatper = per(iterlocation,:);
    temprownum = size(temprow,1);
    tempmatnum = size(tempmat,1);
    
    % keep  (group index/size) average
    temprowsize = mean( temprow(:,2),1 );
    tempmatsize = mean( tempmat(:,2),1 );
    
    % sum of variables (occu/freq/magn)
    temprowocc = sum( temprow(:,3:8), 1,'omitnan');
    tempmatocc = sum( tempmat(:,3:8), 1,'omitnan');
    temprowmag = mean( temprow(:,9:end), 1,'omitnan');
    tempmatmag = mean( tempmat(:,9:end), 1,'omitnan');
    
    temprowfreq = temprowocc ./ sum(temprowocc,2);
    tempmatfreq = tempmatocc ./ sum(tempmatocc,2);
    
    observationrow(iterlocation,:) = ...
        [temprowper,temprownum,temprowsize,temprowocc,temprowfreq,temprowmag];
    observationmat(iterlocation,:) = ...
        [tempmatper,tempmatnum,tempmatsize,tempmatocc,tempmatfreq,tempmatmag];
end

%% OUTPUT
obsrow = observationrow;
obsmat = observationmat;

end