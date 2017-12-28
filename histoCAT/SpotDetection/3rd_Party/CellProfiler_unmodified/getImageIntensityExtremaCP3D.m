function [minIntensity, maxIntensity] = getImageIntensityExtremaCP3D(Image,minQuantile, maxQuantile, downsamplingFactor,varargin)
% getImageIntensityExtremaCP3D(Image,minQuantile, maxQuantile,
% downsamplingFactor,Illmean,IllStd)
%
% obtains minimum and maximum of an image. Note that minimum and maximum
% are given by the quantile, e.g. minQuantile of 0 is the real minimum of the
% image, wheareas 0.01 would discard the lowest 1%.
%
%
% IMAGE can either be a matrix with the 2D or 3D image or a path to a 2D
% image
%
% To speed up processing of large images (such as sCMOS 10megapixel iamges),
% DOWNSAMPLINGFACTOR of higher than 1 can downsample the image prior to quantile
%
% If the optional input arguments ILLMEAN and ILLSTD are provided at the
% end of the input, illumination correction will be performed with the MEAN
% and STD provided for illumination correction.
%
%
% Authors:
%   Nico Battich
%   Thomas Stoeger
%   Lucas Pelkmans
%
% Battich et al., 2013.
% Website: http://www.imls.uzh.ch/research/pelkmans.html

% Preprocess input

downsamplingFactor = ceil(downsamplingFactor); % make downsampling factor integer

if nargin== 6   % see if illumination correction should be performed.
    if ~any([isempty(varargin{1}),isempty(varargin{2})])
        bnDoIlluminationCorrection = true;
        IllMean = varargin{1};
        IllStd = varargin{2};
    else
        bnDoIlluminationCorrection = false;
    end
else
    bnDoIlluminationCorrection = false;
end

% Load Data
if isnumeric(Image)
    OrigImage = Image;
elseif ischar(Image);
    if any(fileattrib(Image))
        try
            OrigImage = imread(Image);
        catch notLoaded
            error(['Could not load Image with file path/name ' Image '.'])
        end
    else
        error(['Could not find file with file path/name ' Image '.'])
    end
else
    error('Could not identify format of input Image')
end

% Downsample by choosing discrete rows/columns. Note that this will prevent
% masking of small intensity peaks (such as RNA spots) below sampling
% scale (which might occur with classical image downsampling involving
% interpolation). Also use discrete steps of rows instead of randomly
% chosen subset of image for reproducibility (assumption that there
% is no repetitive pattern of the intensities)
rowIndices= 1:downsamplingFactor:size(OrigImage,1);
columnIndices =  1:downsamplingFactor:size(OrigImage,2);


ImagesDS = OrigImage(rowIndices,columnIndices,:);

if bnDoIlluminationCorrection == true  % if requested, do illumination correction
    % downsample template for illumantion correction
    IllMeanDS =  IllMean(rowIndices,columnIndices);
    IllStdDS =  IllStd(rowIndices,columnIndices);
    switch size(ImagesDS,3)
        case 1    % in case of 2D image use Nico's function for illum correction
            ImagesDS = IllumCorrect(ImagesDS,IllMeanDS,IllStdDS,1);
        otherwise % otherwise use implementation supporting 3D
            ImagesDS = applyNBBSIllumCorrCP3D(ImagesDS,IllMeanDS,IllStdDS);
    end
end

if ~isempty(minQuantile)
    minIntensity = quantile(ImagesDS(:),minQuantile);
else
    minIntensity = NaN;
end

if ~isempty(maxQuantile)
    maxIntensity = quantile(ImagesDS(:),maxQuantile);
else
    maxIntensity = NaN;
end

end