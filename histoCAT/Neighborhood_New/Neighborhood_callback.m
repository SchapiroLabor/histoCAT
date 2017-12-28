function Neighborhood_callback(hObject, eventdata, handles)
% NEIGHBORHOOD_CALLBACK Callback for the neighorhood function from GUI
%
% Input:
% Global variables:
% Fcs_Interest_all --> all data in the fcs file structure
% Sample_Set_arranged --> samples arranged based on names (numbers)
% HashID --> individual HashID for each image
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

% Get handles
handles = gethand;
selectedall_gates = get(handles.list_samples,'Value');
global Fcs_Interest_all;
global Sample_Set_arranged;
global HashID;
gates = retr('gates');
sessionData = retr('sessionData');
custom_gatesfolder = retr('custom_gatesfolder');

gates_cut = gates(selectedall_gates,:);
select_gates_cut = 1:size(gates_cut,1);

% User input for neighborhood analysis
pixelexpansion_dropdown = retr('pixelexpansion');
answers = inputdlg({'Amount of permutations:','Significance cut-off: (min. 1/amount of permutations)','Special cluster (Individual Output)','Extra information (Legend for Individual Output)','Specify the amount of pixel expansion to look for cell neighbors:','Percentage cut-off for present interactions (0-1)','If you want to run patch detection: enter minimum amount of neighbors the patch has to include'},'Neighborhood Analysis',1,{'999','0.05','7','Grade1',pixelexpansion_dropdown,'0.1','\'});

% Extract user input
% Amount permutations
perm = answers(1);
perm = str2double(perm);
% Significants cut-off for pValue
alpha = answers(2);
alpha = str2double(alpha);
% Cluster number which should be highlighted and annotated
Special_clusters_name = answers(3);
Special_clusters_name = cell2mat(Special_clusters_name);
% Name/Annotation for the special/highlighted cluster
Extra_information = answers(4);
Extra_information = cell2mat(Extra_information);
% Pixel expansion - when is a cell a neighbor
Pixel_expansion = answers(5);
Pixel_expansion = str2double(Pixel_expansion);
% Cut off for how many images need to be included in a significant cluster
% (0-1) --> Example 0.1 --> 10% of all images include the cluster
cut_off_percent = answers(6);
cut_off_percent = str2double(cut_off_percent);
%Patch detection
patch_det = answers(7);
if strcmp(patch_det,'\')
    patch_det = 0;
else
    %Minus one because it is later used as the number the interactions have
    %to be higher than, so if user enters 1 -> it will be 0 and hence the
    %regular neighborhood analysis, if user enters 2 -> the interaction has
    %to be with more than 1 neighbor
    patch_det = str2double(patch_det)-1;
end


% If batch mode - each pixel expansion can be tested
if isnan(Pixel_expansion)
    
    for pixel = 1:6
        Neighborhood_Master(perm,pixel,alpha,gates_cut,select_gates_cut,...
            sessionData,custom_gatesfolder,Special_clusters_name,Extra_information,cut_off_percent,patch_det);
        disp('Done')
        disp(pixel)
    end
else
    Neighborhood_Master(perm,Pixel_expansion,alpha,gates_cut,select_gates_cut,...
        sessionData,custom_gatesfolder,Special_clusters_name,Extra_information,cut_off_percent,patch_det);
    disp('Done')
    disp(Pixel_expansion)
end

end

