function result = remove_repeating_strings(strings)
% REMOVE_REPEATING_STRINGS
%
% This function is from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH
    if isempty(strings)
        return;
    end
    
    if numel(strings) == 1
        result = strings;
        return;
    end
    
    str = strings{1};
    for i=1:numel(str)
        TF = strncmpi(str(1:i),strings,i);
        if ~isempty(find(TF==0))
            break;
        end
    end
    
   
        result = strings;
    
end