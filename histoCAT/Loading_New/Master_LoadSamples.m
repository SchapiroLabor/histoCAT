function Master_LoadSamples( hObject, eventdata, handles )
% MASTER_LOADSAMPLES: Main function for general loading. Calls all other
% necessary loading functions.
%
% hObject: handle to scatter_plot (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
%
% This function is connected to the GUI. For GUI independent loading see
% Commandline Loading.
% Output/Input variables (!!!GLOBAL!!!)
% HashID --> Unique folder IDs (!!!GLOBAL!!!)
% Sample_Set_arranged (--> samplefolders) --> paths to the selected sample folders (historical)(!!!GLOBAL!!!)
% Mask_all --> segmentation masks of all samples (!!!GLOBAL!!!)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Call global variables
global Sample_Set_arranged
global Mask_all
global Fcs_Interest_all
global HashID

%Function call to store the sample folder
[ samplefolders,fcsfiles_path,HashID ] = Load_SampleFolders(HashID);

%If no samples are found return
if isempty(samplefolders) == 1
    disp('No sample set selected');
    return;
end

%Retrieve the status of first time loading 0 or 1
loadflag = retr('loadflag');

%Start timing
tic

%Load all the db files
[Sample_Set_arranged,Mask_all,Tiff_all,...
    Tiff_name]= Load_MatrixDB(samplefolders,Sample_Set_arranged,Mask_all);

%If the spot detection plug-in folder exists, call spot detection
if exist('SpotDetection','dir')
    [Tiff_all,Tiff_name] = spot_detection_master(Tiff_name,Tiff_all);
end

%Function call to get the single cell info into matrix
[Fcs_Interest_all] = DataProcessing_Master(Mask_all,Tiff_all,Tiff_name,HashID,Fcs_Interest_all);


%Elapsed time
toc


%Function call to store the sample data
store_sessionData(samplefolders,fcsfiles_path,Sample_Set_arranged,Fcs_Interest_all,HashID,Mask_all, handles);

%Retrieve gates
gates = retr('gates');
if isempty(gates) == 1
    return;
end

%Store sample names for GUI
[names_add]=gates(:,1);
put('names_add',names_add);

%Update GUI handles.
set(handles.list_samples,'String',names_add);
set(handles.list_samples,'Max',1000,'Min',1);
set(handles.list_channels,'Value',1);
set(handles.list_samples,'Value',1);
set(handles.list_channels,'Max',1000,'Min',2);

%Enable the main buttons
set(handles.analyze_button,'Enable','on');
set(handles.visualize_button,'Enable','on');
set(handles.preparesample_button,'Enable','on');
set(handles.remove_options,'Enable','on');


%Create a custom folder to store all gated files
if loadflag == 1
    % in macos and linux, they may not see a title in dialog box, so tell the prompt beforehand
    store_gate_prompt = 'Where do you want to store the custom gates?';
    if ~ispc 
        uiwait(msgbox(store_gate_prompt, 'Info', 'modal'));
    end
    pathname = uigetdir(getLoadDirStartingPath,store_gate_prompt);
    custom_gatesfolder = fullfile(pathname,'custom_gates_0');
    
    % Check if folder includes spaces
    check_space_customfolder = any(isspace(custom_gatesfolder));
    % If so, please reselect
    while check_space_customfolder == 1
        waitfor(msgbox('Do not use SPACE in folder names! Please select a different custom gates folder location.'));
        pathname = uigetdir('Prompt','Where do you want to store the custom gates?');
        custom_gatesfolder = fullfile(pathname,'custom_gates_0');
        check_space_customfolder = any(isspace(custom_gatesfolder));
    end
    
    % Check if folder exist. If not, please create directory
    if ~exist(custom_gatesfolder)
        mkdir(custom_gatesfolder);
        disp(['All your custom gates will be saved in this folder ' custom_gatesfolder]);       
    end
    
    loadflag = 0;
    put('loadflag',loadflag);
    put('custom_gatesfolder',custom_gatesfolder);
end

%Call function to update list boxes and store sample and channels data.
list_samples_Callback;

%Get the GUI handles and set the pixelexpansion to the value the user
%previously defined
handles=gethand;
expansionfeature = retr('expansionfeature');
expansion_range = retr('expansion_range');
set(handles.pixelexpansion_dropdown,'String',expansion_range);
set(handles.pixelexpansion_dropdown,'Value',length(expansion_range));
Pixelexpansion_callback;

end

