function [ STAT ] = pricecoordination_region( REGION,OCCURRENCE,MAGNITUDE )
%
%	pricecoordination_region
%
%   FUNCTION:
%           Calculate occurrence/magnitude/frequency of region
%
%   INPUT:
%           REGION      - the region indicator of non-missing pcp
%           OCCURRENCE  - the total occurrence of non-missing pcp
%           MAGNITUDE   - the total magnitude of non-missing pcp
%   OUTPUT:
%           STAT        - the summary statistics of this region
%
%   EXAMPLE:
%
%

%% INPUT
region = REGION;
occ = OCCURRENCE;
mag = MAGNITUDE;

%% Total Occ and Mag

% calculate total occurrence across all patterns
% which is sum of occurrence of all groups
totocc = sum( occ, 1,'omitnan' );

% calculate average magnitude across all patterns
% which is sum of total magnitudes of all groups
totmag = sum( mag, 1,'omitnan' );

%% New Occ and Mag by Replacing

% the new version sets the price change patterns
% not in this region to NAN
totoccnew = NaN(size(totocc));
totoccnew(:,region) = totocc(:,region);

% the new version sets the price change patterns
% not in this region to NAN
totmagnew = NaN(size(totmag));
totmagnew(:,region) = totmag(:,region);

%% Separate Uni- & Bi- Patterns and Reshape

% -one & -two are uni- & bi- subsets
totoccone = totoccnew(:, 1:28 );
totocctwo = totoccnew(:,29:238);

% reshape by 7 and 21
totoccone = reshape(totoccone', 7, 4);
totocctwo = reshape(totocctwo',21,10);

% -one & -two are uni- & bi- subsets
totmagone = totmagnew(:, 1:28 );
totmagtwo = totmagnew(:,29:238);

% reshape by 7 and 21
totmagone = reshape(totmagone', 7, 4);
totmagtwo = reshape(totmagtwo',21,10);

%% Regional Statittics

% Total Occurrence
regiontotoccone = sum( totoccone, 1,'omitnan' );
regiontotocctwo = sum( totocctwo, 1,'omitnan' );

% only interest in the first 3 and first 6
regiontotocc = [ regiontotoccone(:,1:3),regiontotocctwo(:,1:6), ];

% Total Magnitude
regiontotmagone = sum( totmagone, 1,'omitnan' );
regiontotmagtwo = sum( totmagtwo, 1,'omitnan' );

% only interest in the first 3 and first 6
regiontotmag = [ regiontotmagone(:,1:3),regiontotmagtwo(:,1:6), ];

% Average Magnitude
regionavgmag = regiontotmag ./ regiontotocc;

% Total Magnitude
regiontotfrq = [ ...
    regiontotoccone(:,1:3) ./ sum( regiontotoccone(:,1:3) ),...
    regiontotocctwo(:,1:6) ./ sum( regiontotocctwo(:,1:6) ),...
    ];

% regional statistics
regionstat = [ regiontotocc,regiontotfrq,regionavgmag, ];

%% OUTPUT
STAT = regionstat;

end
