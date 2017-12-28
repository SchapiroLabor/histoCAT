function save_sessiondata
%SAVE_SESSIONDATA function to save the session data (clicking on the save button)
%
% This function is modified from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

handles=gethand;
gates = retr('gates');
sessionData = retr('sessionData');
sessiondata_index = retr('sessiondata_index');
allids = retr('allids');
global Fcs_Interest_all
global Sample_Set_arranged
global HashID
global Mask_all
Tiff_name = retr('Tiff_name');
Tiff_all = retr('Tiff_all');
expansionfeature_value = handles.pixelexpansion_dropdown.Value;
expansionfeature_range = handles.pixelexpansion_dropdown.String;
notNan = retr('notNan');


if (isempty(sessionData)) 
    uiwait(msgbox('The session is empty.','Warning!','modal'));
    return;
end

[filename,pathname,~] = uiputfile('*.mat','Save Session');

if isequal(filename,0) || isequal(pathname,0)
    return;
end

save([pathname filename], 'sessionData','gates','sessiondata_index','allids','Fcs_Interest_all','Sample_Set_arranged','HashID','Mask_all','Tiff_name','Tiff_all','expansionfeature_value','expansionfeature_range','notNan','-v7.3'); 


end

