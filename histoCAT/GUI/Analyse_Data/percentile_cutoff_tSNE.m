function [vColor] = percentile_cutoff_tSNE(vColor,handles, percent )
% PERCENTILE_CUTOFF_TSNE: Function to cut off certain percentile of intensities for
% plotScatter_Channels color overlay. Sets intensities above the cut-off down to the
% value of the cut-off.
%
% Input: 
% vColor --> color intensities before cut-off
% handles --> structure with handles and user data (see GUIDATA)
% percent --> percentage to cut off set by slider (if slider is set to 1, the
% values above the 99th percentile will be set down to the value of the
% 99th percentile)
%
% Output: vColor --> color intensities after cut-off
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%If slider is at zero there is no cut-off
if percent == 0
    disp('no cut-off');
else
    
    %Get value of percentile corresponding to given cut-off
    percentile = prctile(vColor, 100-percent);
    
    %Find values above given percentile and set them down to value of
    %percentile
    for i=1:length(vColor)
        if vColor(i) > percentile
            vColor(i) = percentile;
        end
    end
end

end
