function [ObjCount SegmentationCC FiltImage] = ObjByFilter(Image,Filter,ObjThr,limQuant,RescaleThr,ObjIntensityThr,closeHoles,ObjSizeThr,DetectionBias)
%OBJBYFILTER Detects Objects within the n dimensional matrix IMAGE by applying
%   a n dimensional matrix FILTER and thresholding according to OBJTHR.
%   OBJBYFILTER outputs the number of objects and optionally a structure
%   SEGMENTATIONCC with the segmentation of individual objects.
%
%   OBJTHR can be either an individual number or a vector specifying
%   multiple thresholds, leading to multiple outputs. If only one OBJTHR
%   is specified, SEGMENTATIONCC corresponds to a Label-structure (see
%   bwconncomp), otherwise it will be an array thereof.
%
%   LIMQUANT is vector specifying lower and upper quantile of intensities
%   of IMAGE used for rescaling, if they are among allowed range (see
%   RESCALETHR below). Use [] to use standard values of LIMQUANT, which are
%   [0.01 0.99].
%
%   RESCALETHR is a vector restricting the rescaling of the image before
%   filtering. [MinimalIntensityOfLowerThreshold MaximalIntensityOfLowerThreshold
%   MinimalIntensityOfHigherThreshold MaximalIntensityOfHigherThreshold] If
%   RESCALETHR should not be set at all use empty input []. If individual
%   values should be ignored, set them to NaN, eg. [NaN 120 500 NaN]
%
%   OBJINTENSITYTHR is a number specifing the lowest intensity a
%   pixel/voxel is allowed to have in order to be detected as part of an
%   object (unless it is completely enclosed by another object and
%   CLOSEHOLES is enabled). OBJINTENSITYTHR is only applied after filtering
%   of the image in order to prevent introduction of short intensity
%   boundries, which would favour edge detection during object detection.
%
%   CLOSEHOLES closes holes within objects. Set to true or false.
%
%   OBJSIZETHR can either be a single number specifing the minimal amount
%   of pixels/voxels of an object or a vector of [MinimalSize MaximalSize].
%   OBJSIZETHR is applied after the CLOSEHOLES operation
%
%   DETECTIONBIAS is a matrix used for correcting the spot detection bias.
%   Note that input can be empty
%   ----------------------------------
%
% Authors:
%   Nico Battich
%   Thomas Stoeger
%   Lucas Pelkmans
%
% Battich et al., 2013.
% Website: http://www.imls.uzh.ch/research/pelkmans.html

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% INITIALIZE SETTINGS   %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Image = double(Image); % convert input to double, which will prevent rounding mistakes during rescaling.

numDownsampling=10;     % consider using this as an optional input or determining dynamically.
% Downsampling is important for calculating
% quantile of CV7k stacks, which can easiliy take
% minutes without downsampling

if nargout > 1      % Report segmentation, if requested; importantly, the code will finish if it does not have to update Segmentations.
    bnReportSegmentation = true;
else
    bnReportSegmentation = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  CHECK INPUT   %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Obtain number of Thrs to test
if isnumeric(ObjThr) && ~isempty(ObjThr) && (size(ObjThr,1) ==1 || size(ObjThr,2) ==1)
    numObjThr = length(ObjThr);
else
    error('ObjThr has to be either a single number or an array thereof.')
end

% Check, if Thrs for rescaling are set. If not set to + or - Infinity
% and therefor make them not restrictive
DefaultRescaleThr = [-Inf Inf -Inf  Inf];
if isempty(RescaleThr)
    RescaleThr = DefaultRescaleThr;
    %fprintf('RescaleThr not determined. Set to default (ignore).\n');
elseif size(RescaleThr,1) ~= 1 || size(RescaleThr,2) ~=4 || isnumeric(RescaleThr) == false
    error('RescaleThr must be a 1x4 matrix with minimal intensity of lower boundry, maximal intensity of lower boundry, minimal intensity of upper boundry, maximal intensity of upper boundry.');
else
    f = isnan(RescaleThr);
    if sum(f)>0
        RescaleThr(f) = DefaultRescaleThr(f);
        %fprintf('RescaleThr contains NaNs. Set these value(s) to default (ignore).\n')
    end
end

if RescaleThr(1)>RescaleThr(2)
    error('RescaleThr> min of lower threshold must not exceed max of lower threshold. ')
end

if RescaleThr(3)>RescaleThr(4)
    error('RescaleThr> min of higher threshold must not exceed max of higher threshold. ')
end

% Check, if limes for rescaling are set. If not set to 0.01 and 0.99
% and therefor make them not restrictive

DefaultlimQuant = [0.01 0.99];
if isempty(limQuant)
    limQuant = DefaultlimQuant;
    %fprintf('limQuant not determined. Set to default 0.01 and 0.99 .\n');
elseif size(limQuant,1) ~= 1 || size(limQuant,2) ~=2 || isnumeric(limQuant) == false
    error('limQuant must be a 1x2 matrix with lower quantile and upper quantile of image, which will be handles as its minimal and maximal intensity.');
else
    f = isnan(limQuant);
    if sum(f)>0
        limQuant(f) = DefaultlimQuant(f);
        %fprintf('limQuant contains NaNs. Set these value(s) to default.\n')
    end
end

if limQuant(1)>limQuant(2)
    error('limQuant> lower quantile must not exceed higher quantile. ')
end


% Check if Minimal object intensity, which is required to be part of an
% object has been set.

if isnumeric(ObjIntensityThr) && ~isempty(ObjIntensityThr)
    ObjIntensityThr = double(ObjIntensityThr);
else
    ObjIntensityThr = -Inf;
    %fprintf('numMinIntensityForObj has not been set. Set to default (ignore)')
end

% if there is an input for the allowed Object size, apply this as a filter
% during object segmentation.
if isnumeric(ObjSizeThr) && ~isempty(ObjSizeThr)
    bnMinObjSize = true;
    if length(ObjSizeThr)>1;    % if input is not a single number, use the second one as an upper boundry
        bnMaxObjSize = true;
    end
else
    bnMinObjSize = false;
end


if nargout == 3
    bnFiltImage = true;
else
    bnFiltImage = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  RESCALE INPUT IMAGE %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rImage = RescaleImageCP3D(Image,limQuant,RescaleThr,numDownsampling); % note that here rescaling is not normalized to max of 100%=1 as in initial Identifyprimlog2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  FILTER IMAGE  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Perform filtering to enhance (spotlike) objects
rImage = FilterImageCP3D(rImage,Filter);

if bnFiltImage == true % if requested, return filtered image
    FiltImage = rImage;
end

% Fix detection bias
if ~isempty(DetectionBias)
rImage = rImage./DetectionBias;
end


%Set Values of too dim pixels to a value where it they do not get
%identified as spots
fImageBright = Image > ObjIntensityThr;
j = min(ObjThr)-1;      % set too dim pixels to a value below the lowest selected threshold. Note that replacing j by NaNs would slow down the code by approx x3.
rImage(~fImageBright) =  j;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  SEGMENTATION  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ObjCount=nan(1,numObjThr);
SegmentationCC{numObjThr}=[];

for n=1:numObjThr
    % Pixels/Voxels above Threshold
    bw=rImage>ObjThr(n);
    
    if closeHoles == true
        % Close holes if requested
        bw=imfill(bw,'holes');
    end
    
    % Create Segmentation
    vislabel = bwconncomp(bw);    % Use bwconncomp instead of bwlabel(n) to save memory. Note that this is not compatible with ancient matlab versions
    
    if vislabel.NumObjects >= 1  % check if at least one object;
        
        % Discard Objects outside of range
        if bnMinObjSize == true
            visprops = regionprops(vislabel,'Area');    % note that area property will yield volume in 3D;
            vispropsArea = arrayfun(@(x) x.Area, visprops);
            f = vispropsArea < ObjSizeThr(1); % Objects below minimal size
            
            if bnMaxObjSize == true % note that Maximal object size requires setting a minimal object size
                f = f | (vispropsArea > ObjSizeThr(2));
            end
            
            % update Segmentation
            vislabel.NumObjects=vislabel.NumObjects-sum(f);
            if bnReportSegmentation == true;    % prevent excess calculation / rearrangement if not required
                vislabel.PixelIdxList(f)=[];
            end
        end
    end
    
    % report results of object count / segmentation
    ObjCount(1,n) = vislabel.NumObjects;
    
    if bnReportSegmentation == true
        if numObjThr == 1    % if only one threshold is specified, directly return segmentation
            SegmentationCC = vislabel;
        else
            SegmentationCC{n}=vislabel;
        end
    end
    
end


end