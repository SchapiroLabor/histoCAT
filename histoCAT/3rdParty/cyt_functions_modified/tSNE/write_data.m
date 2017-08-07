function write_data(X, theta, perplexity)
% WRITE_DATA Writes the datafile for the fast t-SNE implementation
%
% This function is modified from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

[n, d] = size(X);
h = fopen('data.dat', 'wb');
fwrite(h, n, 'integer*4');
fwrite(h, d, 'integer*4');
fwrite(h, theta, 'double');
fwrite(h, perplexity, 'double');
fwrite(h, X', 'double');
fclose(h);
end

