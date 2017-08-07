function Load_sessionData(hObject, eventdata, handles)
% LOAD_SESSIONDATA: Load previously stored session and settings
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH
 
%Retrieve GUI handles
handles = gethand;

%Clear current session if any is open
uiwait(msgbox('This will clear your current session and load the one you select.'));

%Start timing
tic
 
%Get the sessionData mat-file from user
[matfile,path] = uigetfile('.mat','Select mat file of session data');

%If no file was specified return, else clear current global variables and
%GUI lists
if path == 0
    return;
else
    clearvars -global
    set(handles.list_samples,'String','');
    set(handles.list_channels,'String','');
end

%Retrieve global variables
global Fcs_Interest_all
global Sample_Set_arranged
global HashID
global Mask_all

%Read all the session information from mat-file
read_session = importdata(fullfile(path,matfile));
 
%Empty variables from previous session
put('sessionData', []);
put('sessiondata_index',[]);
put('gates', []);
put('allids',[]);
put('Tiff_name',[]);
put('Tiff_all',[]);
 
%Save the sessionData matrix, the gates and the rest of the necessary
%information to continue the session
put('sessionData', read_session.sessionData);
put('sessiondata_index',read_session.sessiondata_index);
put('gates', read_session.gates);
put('allids',read_session.allids);
put('Tiff_name',read_session.Tiff_name);
put('Tiff_all',read_session.Tiff_all);


%If a pixel expansion has been set in the GUI of the saved session, save it in
%variable
try
    expansionfeature=read_session.expansionfeature;
catch
    expansionfeature=[];
end
 
%Fill global variables with the corresponding data from the saved session
Fcs_Interest_all = read_session.Fcs_Interest_all;
Sample_Set_arranged = read_session.Sample_Set_arranged;
HashID = read_session.HashID;
Mask_all = read_session.Mask_all;
 
%If there are no samples in the saved session, return
gates = retr('gates');
if isempty(gates) == 1
    return;
end
 
%Store sample names
[names_add]=gates(:,1);
put('names_add',names_add);
 
%Update GUI handles
set(handles.list_samples,'String',names_add);
set(handles.list_samples,'Max',1000,'Min',1);
set(handles.list_channels,'Value',1);
set(handles.list_samples,'Value',1);
set(handles.list_channels,'Max',1000,'Min',2);
%Update pixelexpansion drop down only if value has been set in session to
%be loaded
if ~isempty(expansionfeature)
    set(handles.pixelexpansion_dropdown,'Value',str2double(expansionfeature)+1);
    if isnan(handles.pixelexpansion_dropdown.Value)
        set(handles.pixelexpansion_dropdown,'Value',1);
    end
    Pixelexpansion_callback;
end
 
%Enable the main buttons
set(handles.analyze_button,'Enable','on');
set(handles.visualize_button,'Enable','on');
set(handles.preparesample_button,'Enable','on');
set(handles.remove_options,'Enable','on');
 
loadflag = retr('loadflag');
 
%Create a custom folder to store all automatically generated files
if loadflag == 1
    pathname = uigetdir('Prompt','Where do you want to store the custom gates?');
    custom_gatesfolder = fullfile(pathname,'custom_gates_0');
    if ~exist(custom_gatesfolder)
        mkdir(custom_gatesfolder);
        disp(['All your custom gates will be saved in this folder ' custom_gatesfolder]);
    end
    loadflag = 0;
    put('loadflag',loadflag);
    put('custom_gatesfolder',custom_gatesfolder);
end
 
%Function call to update list boxes and store sample and channel data
list_samples_Callback;
 
end

