function plot_mask_Callback(hObject, eventdata, handles)
% PLOT_MASK_CALLBACK: This function is executed upon checking/unchecking of 
% the 'Mask on/off' checkbox. It displayes the segmentation mask outlines
% (outlines of the individual cells) on top of the currently selected image tab.
%
% hObject: handle to figure (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve GUI and global variables
tabmaster_histonetiff = retr('tabmaster_histonetiff');
global Mask_all
global Sample_Set_arranged

%Retrieve previously stored mask outline image (image of outlined single
%cells)
maskoutline = retr('maskoutline');

%Get the current tab number
tabnum = find(tabmaster_histonetiff.Children == tabmaster_histonetiff.SelectedTab);

%If the checkbox is checked, show mask
if handles.mask_onoff.Value == 1
    
    %If a mask outline for this image has already been generated and stored previously,
    %there is no need to regenerate it
    if isempty(maskoutline) ~= 1
        
        %Handle exceptions
        try
            
            %Check if the mask outline for this specific tab exists, if so
            %display it on the current image
            if isempty(maskoutline{tabnum}) ~= 1
                cmap = retr('cmap');
                maskoutline{tabnum}.Visible = 'on';
                
            %If mask outline for current tab does not already exist, generate it
            else
                
                %Split the filepaths and extract the sample name of all samples
                splitSamplename = cellfun(@(x) strsplit(x,fullfile('/')),Sample_Set_arranged,'UniformOutput',false);
                allcutnames = cellfun(@(x) x(end),splitSamplename);
                
                %Find the index of the sample that corresponds to the currently
                %visualized image
                idxfound_name = find(~cellfun('isempty',regexpi(allcutnames,tabmaster_histonetiff.SelectedTab.Title)));

                %Store the corresponding single-cell mask (each pixel of a
                %cell is marked with the corresponding cell number)
                lblImg_filled = Mask_all(1,idxfound_name).Image;
                
                %If there is no mask and hence no single-cell data, return
                if isempty(lblImg_filled) == 1
                    return;
                end
                
                %Get only the outlines of the individual cells (not all the pixels of a
                %cell, but only the edges)
                lblImg=conv2(single(lblImg_filled),[0 -1 0; -1 4 -1;0 -1 0],'same')>0;
                
                %Set focus on current axes and hold on to it
                axes(tabmaster_histonetiff.SelectedTab.Children.findobj('Type','axes'));
                hold on;
                
                %Display the mask outline image on top of the current image
                %axes, and set the transparancy of the mask to a level such
                %that both the cell outlines and the background image are visible
                cmap = colormap;
                lblImg = gray2ind(lblImg,200);
                maskoutline{tabnum} = imshow(lblImg);
                freezeColors;
                set(maskoutline{tabnum},'AlphaData',0.4);
                put('maskoutline',maskoutline);
            end
            
        %Catch exceptions and generate mask outlines for current image
        catch
            
            %Split the filepaths and extract the sample name of all samples
            splitSamplename = cellfun(@(x) strsplit(x,fullfile('/')),Sample_Set_arranged,'UniformOutput',false);
            allcutnames = cellfun(@(x) x(end),splitSamplename);
            
            %Find the index of the sample that corresponds to the currently
            %visualized image
            idxfound_name = find(~cellfun('isempty',regexpi(allcutnames,tabmaster_histonetiff.SelectedTab.Title)));
            
            %Store the corresponding single-cell mask (each pixel of a
            %cell is marked with the corresponding cell number)
            lblImg_filled = Mask_all(1,idxfound_name).Image;
            
            %If there is no mask and hence no single-cell data, return
            if isempty(lblImg_filled) == 1
                return;
            end
            
            %Get only the outlines of the individual cells (not all the pixels of a
            %cell, but only the edges)
            lblImg=conv2(single(lblImg_filled),[0 -1 0; -1 4 -1;0 -1 0],'same')>0;
            
            %Set focus on current axes and hold on to it
            axes(tabmaster_histonetiff.SelectedTab.Children.findobj('Type','axes'));
            hold on;
            
            %Display the mask outline image on top of the current image
            %axes, and set the transparancy of the mask to a level such
            %that both the cell outlines and the background image are visible
            cmap = colormap;
            lblImg = gray2ind(lblImg,200);
            maskoutline{tabnum} = imshow(lblImg);
            freezeColors;
            set(maskoutline{tabnum},'AlphaData',0.4);
            put('maskoutline',maskoutline);
            
        end
        
    %If there is no previously stored mask outline image, generate it for
    %the currently displayed image
    else
        
        %Split the filepaths and extract the sample name of all samples
        splitSamplename = cellfun(@(x) strsplit(x,fullfile('/')),Sample_Set_arranged,'UniformOutput',false);
        allcutnames = cellfun(@(x) x(end),splitSamplename);
        
        %Find the index of the sample that corresponds to the currently
        %visualized image
        idxfound_name = find(~cellfun('isempty',regexpi(allcutnames,tabmaster_histonetiff.SelectedTab.Title)));
        
        %Store the corresponding single-cell mask (each pixel of a
        %cell is marked with the corresponding cell number)
        lblImg_filled = Mask_all(1,idxfound_name).Image;
        
        %If there is no mask and hence no single-cell data, return
        if isempty(lblImg_filled) == 1
            return;
        end
        
        %Get only the outlines of the individual cells (not all the pixels of a
        %cell, but only the edges)
        lblImg=conv2(single(lblImg_filled),[0 -1 0; -1 4 -1;0 -1 0],'same')>0;
        
        %Using white to display the mask outlines
        white = [1 1 1];
        mycolormap = repmat(white,length(unique(lblImg)),1);
                
        %Set focus on current axes and hold on to it
        axes(tabmaster_histonetiff.SelectedTab.Children.findobj('Type','axes'));
        hold on;
        
        %Display the mask outline image on top of the current image
        %axes, and set the transparancy of the mask to a level such
        %that both the cell outlines and the background image are visible
        cmap = mycolormap;
        lblImg = gray2ind(lblImg,200);
        maskoutline{tabnum} = imshow(lblImg);
        freezeColors;
        set(maskoutline{tabnum},'AlphaData',0.4); %replace 0.4 with lblImg in order to not darken the image
        put('maskoutline',maskoutline);
        
    end
    
%If the mask on/off checkbox is not checked, do not display the mask
else
    
    %If a mask outline already exists
    if isempty(maskoutline) ~= 1
        
        %If a mask outline for the current tab exists, switch the visibility
        %off
        try
            if isempty(maskoutline{tabnum}) ~= 1
                cmap = retr('cmap');
                maskoutline{tabnum}.Visible = 'off';
            end
        catch
            return;
        end
        
    %If no mask outline has been generated before, it was not displayed in the first
    %place
    else
        return;
    end
    
end

%Store the colormap if it has been generated
if isempty(cmap) ~= 1
    put('cmap',cmap);
    tabmaster_histonetiff.SelectedTab.Children.findobj('type','colorbar');
else
    colorbar(tabmaster_histonetiff.SelectedTab.Children.findobj('Type','axes'),'off');
end

%Set axes position
tabmaster_histonetiff.SelectedTab.Children.findobj('Type','axes').Position = [0 0 1.1 1];


end

