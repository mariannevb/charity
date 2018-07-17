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

% the dataset has 19422 observations (groups)
% so roughly 194 observation within 1-percentile
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
observationrow = NaN(size(perlocation,1),57);
observationmat = NaN(size(perlocation,1),57);

for iterlocation = 1:size(perlocation,1)
    
    % location indices of 'this' and 'last' percentiles
    tempthis = perlocation(iterlocation,:);
    if iterlocation == 1
        templast = [0,0];
    else
        templast = perlocation(iterlocation-1,:);
    end
    
    % obtain group data
    temprow = sorted(tempthis(:,1):tempthis(:,2),:);
    tempmat = sorted(templast(:,2)+1:tempthis(:,2),:);
    
    % calculate group information
    
    % percentile, obs (number of group), size
    temprowper = per(iterlocation,:);
    tempmatper = per(iterlocation,:);
    temprowobs = size(temprow,1);
    tempmatobs = size(tempmat,1);
    temprowsize = mean( temprow(:,2),1 );
    tempmatsize = mean( tempmat(:,2),1 );
    
    % keep information
    temprowinfo = [ temprowper,temprowobs,temprowsize, ];
    tempmatinfo = [ tempmatper,tempmatobs,tempmatsize, ];
    
    % analog pcp analysis
    % OCC MAG - TOTOCC TOTFRQ ABGMAG ABGDIN
    
    % obtain OCC and MAG data
    temprowocc = temprow(:, 3:11);
    temprowmag = temprow(:,12:20);
    temprowloc = ~isnan(temprowocc);
    
    tempmatocc = tempmat(:, 3:11);
    tempmatmag = tempmat(:,12:20);
    tempmatloc = ~isnan(tempmatocc);
    
    % calculatte average DIN magnitude across all patterns
    temprowavgdin = namegroup_din( temprowloc,temprowocc,temprowmag );
    tempmatavgdin = namegroup_din( tempmatloc,tempmatocc,tempmatmag );
    
    % vectorize
    temprowavgdin = temprowavgdin';
    temprowavgdin = temprowavgdin(:)';
    tempmatavgdin = tempmatavgdin';
    tempmatavgdin = tempmatavgdin(:)';
    
    % calculate total occurrence and average magnitude across all patterns
    temprowtotocc = sum( temprowocc, 1,'omitnan' );
    temprowavgmag = sum( temprowmag, 1,'omitnan' ) ./ temprowtotocc;
    tempmattotocc = sum( tempmatocc, 1,'omitnan' );
    tempmatavgmag = sum( tempmatmag, 1,'omitnan' ) ./ tempmattotocc;
    
    % calculate total frequency across all patterns
    temprowtotfrq = [ ...
        temprowtotocc(:,1:3) ./ sum( temprowtotocc(:,1:3) ),...
        temprowtotocc(:,4:9) ./ sum( temprowtotocc(:,4:9) ),...
        ];
    tempmattotfrq = [ ...
        tempmattotocc(:,1:3) ./ sum( tempmattotocc(:,1:3) ),...
        tempmattotocc(:,4:9) ./ sum( tempmattotocc(:,4:9) ),...
        ];
    
    % keep statistics
    temprowstat = ...
        [ temprowtotocc,temprowtotfrq,temprowavgmag,temprowavgdin ];
    tempmatstat = ...
        [ tempmattotocc,tempmattotfrq,tempmatavgmag,tempmatavgdin ];
    
    % output information and statistics
    observationrow(iterlocation,:) = [ temprowinfo,temprowstat ];
    observationmat(iterlocation,:) = [ tempmatinfo,tempmatstat ];
end

%% OUTPUT
obsrow = observationrow;
obsmat = observationmat;

end