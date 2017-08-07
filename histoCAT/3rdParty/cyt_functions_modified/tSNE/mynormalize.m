function data = mynormalize(data, percentile)
% MYNORMALIZE Normalize data according to a specified percentile
%
% This function is modified from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Input:
% data --> data to be normalized
% percentile --> percentile selected for normalization 
%
% Output: data --> normalized data
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

fprintf('Normalizing according to the %gth percentile...', percentile);
data = data-repmat(prctile(data, 100-percentile, 1), size(data,1),1);
data = data./repmat(prctile((data), percentile, 1),size(data,1),1);

data(data > 1) = 1;
data(data < 0) = 0;
data(isinf(data)) = 0;
end


