function [ DEINNOSUMMARY ] = pricecoordination_deinno( LOCATION,OCCURRENCE,MAGNITUDE )

%   Average DIN (Decrease-Increase-Nochange) Across Patterns
%
%   FUNCTION:
%           Calculate average magnitudes of decrease and increase
%           across all 9 price change patterns
%
%   INPUT:
%           LOCATION    -the location of non-missing pcp
%           OCCURRENCE  -the occurrence of non-missing pcp
%           MAGNITUDE   -the magnitude of non-missing pcp
%
%   OUTPUT:
%           DEINNOSUMMARY  -the summary statistics of DIN
%
%   EXAMPLE:
%
%   Suppose location,occurrence,magnitude as follows (239:243,:)
%   ----------------------------------------------------------------------------
%   PCP = | D      | I      | N   | DD  | II     | DN  | IN     | DI     | NN  |
%   ----------------------------------------------------------------------------
%   LOC = | 1      | 1      | 0   | 0   | 0      | 0   | 0      | 1      | 0   |
%         | 0      | 0      | 1   | 0   | 0      | 0   | 0      | 0      | 1   |
%         | 0      | 0      | 0   | 0   | 0      | 0   | 0      | 0      | 0   |
%         | 0      | 1      | 0   | 0   | 1      | 0   | 0      | 0      | 0   |
%         | 0      | 1      | 1   | 0   | 1      | 0   | 1      | 0      | 1   |
%   ----------------------------------------------------------------------------
%   OCC = | 1      | 1      | NAN | NAN | NAN    | NAN | NAN    | 1      | NAN |
%         | NAN    | NAN    | 2   | NAN | NAN    | NAN | NAN    | NAN    | 1   |
%         | NAN    | NAN    | NAN | NAN | NAN    | NAN | NAN    | NAN    | NAN |
%         | NAN    | 3      | NAN | NAN | 3      | NAN | NAN    | NAN    | NAN |
%         | NAN    | 2      | 2   | NAN | 1      | NAN | 4      | NAN    | 1   |
%   ----------------------------------------------------------------------------
%   MAG = | 0.0872 | 0.0034 | NAN | NAN | NAN    | NAN | NAN    | 0.0905 | NAN |
%         | NAN    | NAN    | 0   | NAN | NAN    | NAN | NAN    | NAN    | 0   |
%         | NAN    | NAN    | NAN | NAN | NAN    | NAN | NAN    | NAN    | NAN |
%         | NAN    | 0.0128 | NAN | NAN | 0.0029 | NAN | NAN    | NAN    | NAN |
%         | NAN    | 0.0048 | 0   | NAN | 0      | NAN | 0.0096 | NAN    | 0   |
%   ----------------------------------------------------------------------------
%
%   Calculate average DIN (trickiness)
%   ----------------------------------------------------------------------------
%   PCP = | D      | I      | N   | DD  | II     | DN  | IN     | DI     | NN  |
%   ----------------------------------------------------------------------------
%   muD = | 0.0872 | NAN    | NAN | NAN | NAN    | NAN | NAN    | 0.0872 | NAN |
%   muI = | NAN    | 0.0035 | NAN | NAN | 0.0035 | NAN | 0.0024 | 0.0034 | NAN |
%   muN = | NAN    | NAN    | 0   | NAN | NAN    | NAN | 0      | NAN    | 0   |
%   ----------------------------------------------------------------------------
%
%   Suppose NANSUM is SUM that ignores NAN; following are "pseudo" codes.
%
%   To Be Finished

%%

loc = LOCATION;
occ = OCCURRENCE;
mag = MAGNITUDE;

%%

locNaN = NaN(size(loc,1),1);

locD = loc(:,1);
locI = loc(:,2);
locN = loc(:,3);

locDD = loc(:,4);
locII = loc(:,5);
locDN = loc(:,6);
locIN = loc(:,7);
locDI = loc(:,8);
locNN = loc(:,9);

locDinDD = locD .* locDD;
locDinDN = locD .* locDN;
locDinDI = locD .* locDI;

locIinII = locI .* locII;
locIinIN = locI .* locIN;
locIinDI = locI .* locDI;

locNinDN = locN .* locDN;
locNinIN = locN .* locIN;
locNinNN = locN .* locNN;

locDmat = [ locD,locNaN,locNaN, locDinDD,locNaN,locDinDN,locNaN,locDinDI,locNaN ];
locImat = [ locNaN,locI,locNaN, locNaN,locIinII,locNaN,locIinIN,locIinDI,locNaN ];
locNmat = [ locNaN,locNaN,locN, locNaN,locNaN,locNinDN,locNinIN,locNaN,locNinNN ];

locDmat(locDmat==0) = NaN;
locImat(locImat==0) = NaN;
locNmat(locNmat==0) = NaN;

magD = mag(:,1);
magI = mag(:,2);
magN = mag(:,3);

occD = occ(:,1);
occI = occ(:,2);
occN = occ(:,3);

magDmat = sum(magD .* locDmat, 1,'omitnan') ./ sum(occD .* locDmat, 1,'omitnan');
magImat = sum(magI .* locImat, 1,'omitnan') ./ sum(occI .* locImat, 1,'omitnan');
magNmat = sum(magN .* locNmat, 1,'omitnan') ./ sum(occN .* locNmat, 1,'omitnan');

magsummary = [ magDmat;magImat;magNmat; ];

%%

DEINNOSUMMARY = magsummary;

end
