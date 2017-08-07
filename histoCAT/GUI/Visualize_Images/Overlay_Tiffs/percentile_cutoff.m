function [valuevec] = percentile_cutoff(labelvec, valuevec, handles, percent )
% PERCENTILE_CUTOFF_TSNE: Function to cut off certain percentile of intensities for
% heatmap_images_overlay. Sets intensities above the cut-off down to the
% value of the cut-off.
%
% Input:
% labelvec --> vector of single-cell labels
% valuevec --> vector of intensity values corresponding to the single cells
% handles --> handle to GUI variables
% percent --> percentage to cut off set by slider (if slider is set to 1, the
% values above the 99th percentile will be set down to the value of the
% 99th percentile)
%
% Output:
% valuevec --> new vector of values with the values above the given
% percentile set down to the value of the percentile
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Sort the cell label vector and sort the value vector corresponding to the
%same order
[~, ord] = sort(labelvec);
valuevec = valuevec(ord);

%If the slider is set to zero, there will be no cut-off
if percent == 0
    disp('no cut-off');
    
%If the slider is set to anything but zero, cut the corresponding
%percentage off
else
    
    %Get value of percentile corresponding to given cut-off
    percentile = prctile(valuevec, 100-percent);
    
    %Find values above given percentile and set them down to value of
    %percentile
    for i=1:length(valuevec)
        if valuevec(i) > percentile
            valuevec(i) = percentile;
        end
    end
    
end

end
