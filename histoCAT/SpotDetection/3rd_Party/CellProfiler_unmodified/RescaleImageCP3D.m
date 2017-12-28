function RescaledImage = RescaleImageCP3D(Image,limQuant,RescaleThr,numDownsampling)
% Support function for ObjByFilter. (See help there for more information).
% Put into separate function to have constincy among multiple module.
% Will generate RESCALEDIMAGE from IMAGE according to given constraints
% LIMQUANT and RESCALETHR. NUMDOWNSAMPLING is factor used for downsampling
% to increase speed. It does not affect RESCALEDIMAGE.
%
% Authors:
%   Nico Battich
%   Thomas Stoeger
%   Lucas Pelkmans
%
% Battich et al., 2013.
% Website: http://www.imls.uzh.ch/research/pelkmans.html
% *************************************************************************

% Obtain Minimal and maximal intensity of image;
[minRescInt maxRescInt] = getImageIntensityExtremaCP3D(Image,limQuant(1), limQuant(2), numDownsampling);
% Ensure that minimal and maximal intensity do not exceed input boundaries
% note that this will prevent that intensities of very dim imags are
% amplified so that false-positive objects are identified
minRescInt = max(minRescInt,RescaleThr(1));    % Minimum of lower boundary
minRescInt = min(minRescInt,RescaleThr(2));    % Maximum of lower boundary
maxRescInt = max(maxRescInt,RescaleThr(3));    % Minimum of higher boundary
maxRescInt = min(maxRescInt,RescaleThr(4));    % Maximum of higher boundary

% Rescale image
RescaledImage = -(Image-minRescInt)./(maxRescInt-minRescInt);  % note that here rescaling is not normalized to max of 100%=1 as in initial Identifyprimlog2


end