function Selection_save_questions( Sample_Set_arranged,Fcs_Interest_all,HashID )
% SELECTION_SAVE_QUESTIONS: Question will be asked to the user whether to
% save gated area and import data as new gate. If saved, the fcs of the
% gate will automatically get imported to the UI listbox.
%
% Input:
% Sample_Set_arrange --> file paths to all samples in session
% Fcs_Interest_all --> singe-cell data in fcs format for each image in session
% HashID --> hashes of all image names, as they appear in the first column
% of the sessionData (ImageID), corresponding to the loading order of the images
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH
  
%Get GUI handles
handles = gethand;

%Retrieve variables
gates  = retr('gates');
selected_gates = get(handles.list_samples,'Value');
end_max = max(cellfun(@length,gates([selected_gates],3)));
allids = retr('allids');
gatedontiff = retr('gatedontiff');
vxyid = retr('vxyid');

%Function call to get the index of the selected gates in Sample set order.
[  ~, ~, ~,sample_orderIDX ] = getimageids_of_selectedgates(Sample_Set_arranged,HashID,selected_gates, allids);

if isempty(vxyid) ~= 1
    sample_orderIDX = sample_orderIDX(vxyid);
end

%Find the maximum amount of channels of the selected samples
fcs = cellfun(@(x) size(x,2),Fcs_Interest_all([sample_orderIDX],1),'UniformOutput',false);
idx_fcs = find(~cellfun('isempty',fcs));
end_of_newfcs = max([fcs{idx_fcs}]);

if end_max > end_of_newfcs && gatedontiff == 0
    end_fcs = end_max;
else
    %Question to user whether to save the gated cells
    quest_custchannel = questdlg('Do you want to save the gate?',...
                        'Save Gate',...
                        'Yes','No','Cancel','Cancel');
    if strcmp(quest_custchannel,'Yes') == 1
         end_fcs = end_max;
    else
        return;
    end
end

%Store size of current session
put('end_fcs',end_fcs);

%If user selected to import gated cells
if isempty(end_fcs) ~= 1
    
    %Retrieve the folder to store the custom gates in
    pathgate =  retr('custom_gatesfolder');
    %Ask user to give the new gate a name
    namefcs = inputdlg('Give a name for the gate');
    %Add fcs ending to name of new gate
    filegate = strcat(char(namefcs{:}),'.fcs');
    
    %If the user gave a valid name (no empty string)
    if strcmp(filegate,'.fcs') ~= 1
        
        %Write out fcs file of new gate to custom gates folder
        [filename_gatedarea] = writefcs_gate(filegate,pathgate);
        
        %If a file has been written out to an fcs-file
        if isempty(filename_gatedarea) ~= 1
            %Import it as new gate
            import_gatedarea(filename_gatedarea);
        else
            return;
        end
    else
        return;
    end  
end    

end

