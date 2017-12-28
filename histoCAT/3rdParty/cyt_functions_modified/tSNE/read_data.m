function [X, landmarks, costs] = read_data
% READ_DATA Reads the result file from the fast t-SNE implementation
%
% This function is modified from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

h = fopen('result.dat','rb');
n = fread(h, 1, 'integer*4');
d = fread(h, 1, 'integer*4');
X = fread(h, n*d , 'double');
landmarks = fread(h, n, 'integer*4');
landmarks = landmarks + 1;
costs = fread(h, n, 'double');      % this vector contains only zeros
X = reshape(X, [d n])';
fclose(h);
end