function analyze_button_Callback(hObject, eventdata, handles)
% ANALYZE_BUTTON_CALLBACK: Gets called whenever analyze button is pressed
% and executes the chosen analyze option.
%
% hObject: handle to scatter_plot (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles and global variables
handles = gethand;
global Sample_Set_arranged;
global Fcs_Interest_all;
global HashID;

%Disable all other toolbar options before analyzing
zoom off;
pan off;
rotate3d off;
datacursormode off;

%If scatter plot option is selected
if strcmp(handles.analyze_options.String{handles.analyze_options.Value},'Scatter') == 1 & (get(handles.list_heatmap,'Value') == 1)
    
    %Calls regressionline box callback to see whether box is checked or not and
    %then calls the corresponding scatter plot function
    regressionline_checkbox_callback;
    
%If any heatmap channels are selected to overlay on the scatterplots
elseif strcmp(handles.analyze_options.String{handles.analyze_options.Value},'Scatter') == 1 & unique(get(handles.list_heatmap,'Value') > 1) == 1
    
    %Call scatter plot function with heatmap overlay
    plotScatter_Channels;
    
    %Call percentile cut-off slider function
    Heatmap_slider_tSNE;
    
%If histogram option is selected
elseif strcmp(handles.analyze_options.String{handles.analyze_options.Value},'Histogram') == 1
    
    %Call histogram function
    plot_histograms(1);
    
%If boxplot option is selected
elseif strcmp(handles.analyze_options.String{handles.analyze_options.Value},'Boxplot') == 1
    
    %Call boxplot function
    plot_boxplots_per_gate;
    
%If heatmap option is selected
elseif strcmp(handles.analyze_options.String{handles.analyze_options.Value},'Heatmap') == 1
    
    %Call heatmap function
    heatmap_of_selected;
    
%If run k-means option is selected
elseif strcmp(handles.analyze_options.String{handles.analyze_options.Value},'Run k-means') == 1
    
    %Call k-means function
    kmeans_callback;
    
%If run PCA option is selected
elseif strcmp(handles.analyze_options.String{handles.analyze_options.Value},'Run PCA') == 1
    
    %Call PCA function
    pca_callback;
    
%If run t-SNE option is selected
elseif strcmp(handles.analyze_options.String{handles.analyze_options.Value},'Run t-SNE') == 1
    
    %Call t-SNE function
    Run_tsne_Callback;
    
%If run Phenograph option is selected
elseif strcmp(handles.analyze_options.String{handles.analyze_options.Value},'Run Phenograph') == 1
    
    %Call run phenograph option
    Run_Phenograph_Callback;
    
%If gate on plot option is selected
elseif strcmp(handles.analyze_options.String{handles.analyze_options.Value},'Gate on plot') == 1
    
    %Retrieve plots
    hplots = retr('hplots');
    hplots_gates = retr('hplots_gates');
    
    %If there is exactly one plot, the user can gate on it
    if isempty(hplots) ~= 1
        if numel(hplots) == 1
            
            %Set current axes
            current_axes = hplots;
            
            %Function call to selection tool
            Area_selection_heatmap(current_axes);
            
            %Function call to ask user whether to save selection as new
            %gate
            Selection_save_questions( Sample_Set_arranged,Fcs_Interest_all,HashID );
            
        else
            msgbox('Gating allowed only on a single plot');
            return;
        end
        
    else 
        %Set current axes
        current_axes = hplots_gates;
        
        %Function call to selection tool
        Area_selection_plot( current_axes );
        
        %Function call to ask user whether to save selection as new
        %gate
        Selection_save_questions( Sample_Set_arranged,Fcs_Interest_all,HashID );
        
    end
    
    %If there is no plot return
    if isempty(current_axes) == 1
        return;
    end
    
%If highlight sample on plot option is selected
elseif strcmp(handles.analyze_options.String{handles.analyze_options.Value},'Highlight sample on Plot') == 1
    
    %Retrieve plots
    hplots = retr('hplots');
    hplots_gates = retr('hplots_gates');
    
    %If there is exactly one plot, samples can be highlightd
    if isempty(hplots) ~= 1
        if numel(hplots) == 1
            
            %Set current axes
            current_axes = hplots;
            
            %Function call to highlight selected samples on the current
            %plot
            highlight_selectedsample(current_axes);
            
        else
            msgbox('Cannot highlight on multiple heatmaps, select one of interest');
            return;
        end
        
    elseif isempty(hplots_gates) ~= 1
        
        %Set current axes
        current_axes = hplots_gates;
        
        %Function call to highlight selected samples on the current
        %plot
        highlight_selectedsample(current_axes);
    else
        msgbox('Cannot highlight samples');
        return;
    end

end

end