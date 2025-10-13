%#function  Master_LoadSamples
%#function  Load_sessionData
%#function  Savetiff_fig
%#function  SavePlot
%#function  ExportCSV_singlecells
%#function  export_fcs
%#function  uisplitpane
%#function  visualize_button_Callback
%#function  list_channels_Callback
%#function  analyze_options_Callback
%#function  analyze_button_Callback
%#function  list_samples_Callback
%#function  preparesample_button_Callback
%#function  visualize_button_Callback
%#function  visualize_options_Callback
%#function  plot_mask_Callback
%#function  Pixelexpansion_callback
%#function  remove_options_Callback
%#function  regressionline_checkbox_callback
%#function  b2r_checkbox_callback
%#function  median_checkbox_callback
%#function  save_sessiondata

function varargout = histoCAT(varargin)
% HISTOCAT MATLAB code for histoCAT.fig
%      HISTOCAT, by itself, creates a new HISTOCAT or raises the existing
%      singleton*.
%
%      H = HISTOCAT returns the handle to a new HISTOCAT or the handle to
%      the existing singleton*.
%
%      HISTOCAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HISTOCAT.M with the given input arguments.
%
%      HISTOCAT('Property','Value',...) creates a new HISTOCAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before histoCAT_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to histoCAT_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help histoCAT

% Last Modified by GUIDE v2.5 28-Jul-2017 13:39:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @histoCAT_OpeningFcn, ...
    'gui_OutputFcn',  @histoCAT_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

end
% End initialization code - DO NOT EDIT


% --- Executes just before histoCAT is made visible.
function histoCAT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to histoCAT (see VARARGIN)

% add log file
% currentFolder = pwd;
% diary_file = fullfile(currentFolder, 'compiled_app_log.txt')
% diary(diary_file)

% Choose default command line output for histoCAT
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
setappdata(0,'histoCATgui',gcf);

%Switch off all the uicontrol not necessary before loading samples
set(handles.analyze_button,'Enable','off');
set(handles.visualize_button,'Enable','off');
set(handles.preparesample_button,'Enable','off');
set(handles.remove_options,'Enable','off');
set(handles.areaxy_onoff,'Visible','off');
set(handles.mask_onoff,'Visible','off');
set(handles.areaxy_onoff,'Callback',@areaxy_checkbox_Callback);

%%Clear all global variables
clearvars -global

loadflag = 1;
put('loadflag',loadflag);


set(handles.figure1, 'Name', ['histoCAT_',get_histoCAT_version,'  ',get_git_hash]);

% Update handles structure
guidata(hObject, handles);

end

% --- Outputs from this function are returned to the command line.
function varargout = histoCAT_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Check for newest histoCAT version number
% Choose default command line output for histoCAT
handles.output = hObject;

% TODO: IMPLEMENT NEW VERSION ALERT
% OLD VERSION ALERT EXISTED HERE, BUT DELETED DUE TO LAB CHANGE

end


function histoCAT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selecttool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%tool_background = axes('units','normalized', ...
%            'position',[0 0 1 1]);
%  bg_image=imread(fullfile('background_image\overlay_background_resized.jpg'));
%  bg_image_show = imagesc(linspace(0,5),linspace(0,5),bg_image);
%  %set(tool_background,'handlevisibility','off', ...
%  %        'visible','off');
%  set(bg_image_show,'AlphaData',.6);

end

