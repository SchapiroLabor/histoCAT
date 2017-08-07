function overlay_maskandchannels( Mask_all,Fcs_Interest_all,imageids,gate_names,SGsof_imageids_open,sample_orderIDX )
% OVERLAY_MASKANDCHANNELS: This is the main function for all visualization
% in histoCAT. Once the user clicks 'Visualize', the indices of the
% currently selected gates and channels are retrieved. Depending on the
% selected Visualize option, this function will call the necessary functions
% to execute them and set up the tabs to display the different selected
% gates.
%
% Input:
% Mask_all --> segmentation masks of all samples (matrices)
% Fcs_Interest_all --> all individual images as tables with their single-cell information in fcs
% format
% imageids --> image hash IDs of the selected samples
% gate_names --> gate names of the selected samples
% SGsof_imageids_open  --> indices of the selected gates in the samples listbox
% sample_orderIDX --> the indices of the selected gates in the whole SampleSet (This index corresponds to the order in which all singlecell info,
% masks and tiffs are stored.)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%Initialize loading bar
overlayingWaitbar = waitbar(0,'Preparing Images,Please wait...');
   
%Retrieve variables
gates = retr('gates');
sessionData  = retr('sessionData');

%Find the indices (in sessionData) of the channels that have corresponding tiff-images (i.e.
%the first two columns do not have tiffs because they represent the
%imageID and cellIDs)
idx_tiffntempty = find(~cellfun('isempty',regexp(unique([gates{:,3}],'stable'),'Cell_')));
if isempty(idx_tiffntempty) == 1
    idx_tiffntempty = find(~cellfun('isempty',regexp(unique([gates{:,3}],'stable'),'.tif*')));
end

%Number all channels (also the ones inbetween without tiffs)
nums = 1:idx_tiffntempty(end);

%If at least one sample is selected from the list_visual listbox (except for 
%the first option which is 'None'), use this sample for further visualization, 
%else work with the selected sample(s) from the samples listbox
if unique(get(handles.list_visual,'Value') > 1) == 1
    selectedsample_tiff = get(handles.list_visual,'Value') - 1;
    gate_names = gate_names(selectedsample_tiff);
    imageids   = imageids(selectedsample_tiff);
    sample_orderIDX = sample_orderIDX(selectedsample_tiff);
    vis_samples = 1;
else
    vis_samples = 0;
end

%Clear variables
put('rgb_images',[]);
put('tiff_matrix',[]);
tiff_matrix = {};

%Update loading bar
waitbar(0.5, overlayingWaitbar);

%Set the focus on the tiff images panel of the GUI (left side)
handles.panel_tiff_images;

%Delete older tab groups if there are any
delete(handles.panel_tiff_images.Children.findobj('type','uitabgroup'));
put('maskoutline',{});

%Close loading bar
close(overlayingWaitbar);

%Create a new tab group
tabmaster_histonetiff = uitabgroup('Parent',handles.panel_tiff_images,'SelectionChangedFcn',@tabchange);
tiffntfound = 0;

%Loop through the selected gates
for imh = 1:length(gate_names)   
    
    %Current gate name
    currgate_name = gate_names{imh};
    
    %Add a tab for each gate
    tabchild=uitab(tabmaster_histonetiff,'Title',currgate_name);
    
    %Function call to plot areashape X and Y for the image
    plotAreaXY(tabchild,imh,imageids,sample_orderIDX);
    
    %If 'Heatmap channel on selected samples', 'Highlight sample on Tiff images' or
    %'Highlight area excluding selected sample' are sekected from the View Options
    %drop down menu and the segmentation mask for the current image is not empty
    if ((strcmp(handles.visualize_options.String{handles.visualize_options.Value},'Heatmap channel on selected samples') == 1) || ...
            (strcmp(handles.visualize_options.String{handles.visualize_options.Value},'Highlight sample on Tiff images') == 1) || ...
            (strcmp(handles.visualize_options.String{handles.visualize_options.Value},'Highlight excluding selected sample') == 1)) && ...
            (~isempty(Mask_all(1,sample_orderIDX(imh)).Image) && numel(get(handles.list_channels,'Value')) == 1)
        
        %Get the channel numbers corresponding to RGBCMY
        valchannel = retr('valchannel');
        if isempty(valchannel) == 1
            sel_channels = get(handles.list_channels,'Value');
        else
            sel_channels = valchannel;
        end
        
        %If samples from list_visual box were selected, work with these,
        %else use the samples from the samples listbox
        if vis_samples == 1
            
            %Get the single-cell data of the current gate
            cur_img = double(table2dataset(Fcs_Interest_all{sample_orderIDX(imh),1}));
            
            %Get the channel names from the channels listbox
            list_nam = get(handles.list_channels,'String');

            %Get the index of the currently selected channel for the
            %current gate
            idx_chan = find(~cellfun('isempty',regexpi(Fcs_Interest_all{sample_orderIDX(imh),1}.Properties.VariableNames,list_nam{sel_channels})));
            
            %Get the column from sessionData that contains the values of
            %the selected channel and the rows that correspond to the
            %current gate
            singlecell_dat = cur_img(:,idx_chan);
            
            %Get the cellIDS corresponding to each row
            singlecell_label = cur_img(:, 2);
        else
            %Get index of current selected gate
            cur_gate = find(~cellfun('isempty',regexpi(gates(:,1),gate_names{imh})));
            
            %Get row indices in sessionData corresponding to the current
            %selected gate
            if isempty(cur_gate)
                cur_img_idx = gates{SGsof_imageids_open(imh),2};
            else
                cur_img_idx = gates{cur_gate,2};
            end
            
            %Get the channel names from the channels listbox
            list_nam = get(handles.list_channels,'String');
            
            %Get the index of the currently selected channel for the
            %current gate
            idx_chan = find(~cellfun('isempty',regexpi(gates{cur_gate,3},list_nam{sel_channels})));
            
            %Get the column from sessionData that contains the values of
            %the selected channel and the rows that correspond to the
            %current gate
            singlecell_dat = sessionData(cur_img_idx, idx_chan);
            
            %Get the cellIDS corresponding to each row
            singlecell_label = sessionData(cur_img_idx, 2);
        end
        
        %Initialize
        tiff_matrix{1,imh} = [];
        drawnow;
        tab_axes = retr('tab_axes1');
        tab_axes.Position = [0 0 1.1 1];
        
        %Store the mask corresponding to the current gate
        lblImg = Mask_all(1,sample_orderIDX(imh)).Image;
        
        %Function call to overlay a heatmap of the selected channel on the image
        heatmap_images_overlay(lblImg, singlecell_label,...
            singlecell_dat,tab_axes, handles);
        
    %If apply RGBCMY is selected from the View Options drop down menu and
    %tiff of selected channel cannot be found, warn user and delete image
    %tab
    elseif (numel(get(handles.list_channels,'Value')) == 1 && (get(handles.list_channels,'Value') > numel(nums))) && (strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
            'Apply RGBCMY on selected samples') == 1)
        warning('Cannot find Tiff information for current channel!');
        delete(tabmaster_histonetiff.SelectedTab.Children);
        tiffntfound = 1;
        
    %Else function call to fuse the tiffs of the selected channels into one image
    %and display them as RGBCMY
    else
        [ tiff_matrix ] = fuse_images(tabchild,imh);
        
    end
          
    %If tiff channels were found
    if tiffntfound == 0 && isempty(tiff_matrix{1,imh}) ~= 1
        drawnow;
        tab_axes = retr('tab_axes1');
        tab_axes.Position = [0 0 1.1 1];
    end
    
    %Get the XY values from the previous plotAreaXY function
    PlotX{imh} = retr('vX_olay');
    PlotY{imh} = retr('vY_olay');
       
end

%Initialize loading bar
overlayingWaitbar = waitbar(0,'Preparing tabs for images...');

%Update the GUI variables
put('tabmaster_histonetiff',tabmaster_histonetiff);
put('PlotX',PlotX);
put('PlotY',PlotY);

%Loop through the created tabs
for i = 1:numel(tabmaster_histonetiff.Children)
    
    %Get the Line type with the tag 'Areaplot' (the centroids, stored as part of plotAreaXY in function myplotclr)
    foundline = tabmaster_histonetiff.Children(i).Children.findobj('Tag','Areaplot');
    
    %If found, switch the visibility of the lines off
    if isempty(foundline) ~= 1
        set(foundline,'Visible','off');
        
    %Else there was no single-cell data for this image
    else
        disp('Segmentation not done yet...');
    end
    
    %Update loading bar
    waitbar(i/numel(tabmaster_histonetiff.Children),overlayingWaitbar);
    
end

%If tiff channels were found
if tiffntfound ~= 1
    
    %If apply RGBCMY was selected, provide slider for adjusting color intensity
    if strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
            'Apply RGBCMY on selected samples') == 1
        
        %Function call to create slider for intensity scaling
        java_slider(tiff_matrix);
    else
        
        %Delete any existing java wrapper
        delete(handles.figure1.Children.findobj('Units','pixels'));
    end
end

%Close loading bar
waitbar(1, overlayingWaitbar, 'Images ready...');
close(overlayingWaitbar);


end

%Called when tabmaster is created
function tabchange(source,callbackdata)

%Get GUI handles
handles = gethand;

%Switch off both mask and areaxy plot
set(handles.mask_onoff,'Value',0);
set(handles.areaxy_onoff,'Value',0);

end
