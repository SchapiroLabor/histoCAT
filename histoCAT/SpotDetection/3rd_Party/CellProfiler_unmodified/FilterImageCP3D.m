function FilteredImage = FilterImageCP3D(rImage,Filter)
% Support function for ObjByFilter. (See help there for more information).
%
% Pad image to reduce border artifact. Note that comment in original
% IdentifyPrimLoG2 says "to fix border artifact". However this is not fully
% true as TS/NB observed when looking at xy distribution of spot centroids.
% There still is a bias in spot detection against the pixels at the very
% border, potentially because 'replicate' pixels are not Gaussian. Raj et
% al. 2009 did not use padding. In most scenarios, cells directly at the 
% border (and thus the pixels next to the image border) are discarded
%
% Authors:
%   Nico Battich
%   Thomas Stoeger
%   Lucas Pelkmans
%
% Battich et al., 2013.
% Website: http://www.imls.uzh.ch/research/pelkmans.html
% *************************************************************************

padsize = ceil(max(size(Filter))./2);
FilteredImage = padarray(rImage,[padsize padsize],'replicate');

% Perform Filtering
FilteredImage = imfilter(FilteredImage,Filter,'replicate');
% Remove Border
FilteredImage = FilteredImage(padsize+1:end-padsize,padsize+1:end-padsize,:);


end