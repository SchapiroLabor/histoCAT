function show_selected_area_onTiff( Sample_Set_arranged,HashID,Fcs_Interest_all,Mask_all )
% SHOW_SELECTED_AREA_ONTIFF: Gets called when 'Highlight sample on tiff'
% from the Visualize options drop down menu is executed. Highlights the 
% cells of the currently selected gates in a separate color for each
% selected gate. The highlights are overlayed onto the selected image(s) from
% list_visual list box. Cells that are common to two gates are displayed
% in an additional color.
%
% Input:
% Sample_Set_arranged --> paths to all sample folders in session (historical)
% HashID --> Unique folder IDs
% Fcs_Interest_all --> all individual images as tables with their single-cell information in fcs
% format
% Mask_all --> segmentation masks of all samples (matrices)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%Retrieve GUI variables
tabmaster_histonetiff = retr('tabmaster_histonetiff');
sessionData = retr('sessionData');
sessiondata_index = retr('sessiondata_index');
selected_gates = get(handles.list_samples,'Value');
allids = retr('allids');
gates = retr('gates');

%Function call to get the imageIDs of the selected gates and the index of the
%selected gates in the session/ samples list box
[  imageids, ~, SGsof_imageids_open,sample_orderIDX ] = getimageids_of_selectedgates(Sample_Set_arranged,HashID,selected_gates, allids);

%If a sample in the list_visual listbox other than 'None' (the first option) 
%is selected, work with (highlight on) this image, otherwise
%use the selected sample(s) from the samples listbox (list_samples) from above
if unique(get(handles.list_visual,'Value') > 1) == 1
    selectedsample_tiff = get(handles.list_visual,'Value') - 1;
    imageids = imageids(selectedsample_tiff);
    sample_orderIDX = sample_orderIDX(selectedsample_tiff);
end

%Find colors that are most distinguishable from already used colors and
%store the colormap based on the number of selected gates
colorsalreadyused = [[64/255 224/255 208/255];[72/255 209/255 204/255];[0 0 0];[1 20/255 147/255];[199/255 21/255 133/255];[1 105/255 180/255];[1 0 0];[0 1 0];[0 0 1];[0 1 1];[1 0 1];[1 1 0];[0.8 0.5 0];[0 0 0.8];[0.5 0.5 0.5];[0 0.5 0]];
colorstouse = distinguishable_colors(numel(SGsof_imageids_open)+1,colorsalreadyused); %SGsof_imageids_open

%Loop through each of the selected ImageIDs
for ik = 1:length(imageids)
    
    %If single-cell information was found for the current imageID
    if isempty(Fcs_Interest_all{sample_orderIDX(ik),1}) ~= 1
        
        %Initialize variables
        count = 1;
        Cells_selected = [];
        gatenum = [];
        countnum = [];
        
        %Store the single-cell mask for the current image
        lblImg = Mask_all(1,sample_orderIDX(ik)).Image;
        
        %If there is no mask (and hence no songle-cell information), return
        if isempty(lblImg) == 1
            return;
        end
        
        %Loop through the selected gate indices
        for sesn = SGsof_imageids_open
            
            %Find the indices of the cells of the current gate in the entire sessionData
            Cells_selected{count}= Fcs_Interest_all{sample_orderIDX(ik),1}.CellId(find(ismember([Fcs_Interest_all{sample_orderIDX(ik),1}.ImageId,Fcs_Interest_all{sample_orderIDX(ik),1}.CellId],sessionData(sessiondata_index{sesn}{1}(1):sessiondata_index{sesn}{1}(2),1:2),'rows')));
            
            %If there were cells found
            if isempty(Cells_selected{count}) ~= 1
                
                %Store the current gate index off the listbox
                gatenum = [gatenum sesn];
                
                %Store the current count number
                countnum = [countnum count];
                
            %If no cells were found, continue with next gate index of
            %the loop
            else
                count = count + 1;
                continue;
            end
            
            %Temporarily store the single-cell mask in another variable
            tempImg = lblImg;
            
            %Set the cells which were not found to 0 to omit them (show
            %only cells contained in selected gate)
            tempImg(find(~ismember(tempImg,Cells_selected{count}))) = 0;
            
            %Convert to logical
            temp2Img=conv2(single(tempImg),[0 -1 0; -1 4 -1;0 -1 0],'same')>0;
            
            %Convert to uint8
            temp2Img = gray2ind(temp2Img,200);
            
            %Function call to convert grayImg to color by highlighting the
            %cells of interest in color. Color is assigned based on the current count number and the
            %distinguishable colors-to-use.
            [ rgbimg_rest ] = make_rgb( tempImg,colorstouse,count);
            
            %Set the focus on the axes of the current image tab
            handles.panel_tiff_images;
            axes(tabmaster_histonetiff.Children(ik).Children.findobj('Type','axes'));
            
            %Hold on to the axes
            hold on;
            
            %Overlay the image of the highlighted cells on top of the image of the selected tab
            highlightmaskoutline = imshow(rgbimg_rest);
            
            %Hold on to the image to layer other images of highlighted
            %cells from other selected gates for the current imageID
            hold on;
            
            %Freeze colormap
            freezeColors;
            
            %Adjust the intensity of the single-cell mask of the cells to
            %be highlighted
            intensemask = imadjust(double(tempImg));
            set(highlightmaskoutline,'AlphaData',intensemask);
            outline = imshow(temp2Img);
            set(outline,'AlphaData',0);
            hold off;
            
            %Increment count
            count = count + 1;
            
        end
        
        %Store count numbers
        countnum = [countnum count];
        
        %Prepare to deal with exception
        try
            
            %If multiple gates of cells are to be highlighted, show common
            %cells in a separate color
            if count > 1
                
                %Concatenate all cells to be highlighted
                allcells = vertcat(Cells_selected{:});
                
                %Find the indices of the unique cells
                [~,idxofuniquevalues,~] = unique(allcells,'stable');
                
                %The other indices apart from the unique ones are
                %duplicates and hence are common for two of the selected gates
                idxoflightup = [1:size(allcells,1)]';
                idxofduplicates = find(~ismember(idxoflightup,idxofuniquevalues));
                commoncells = allcells(idxofduplicates);

            %If only one gate was selected there are no common cells
            else
                commoncells = [];
            end
            
        %In case of exception no common cells will be displayed
        catch
            commoncells = [];
        end
        
        %If common cells have been found
        if isempty(commoncells) ~= 1
            
            %Temporarily store the single-cell mask in a new variable
            tempImg = lblImg;
            
            %Set the cells which were not found to be common cells to 0 in
            %order to overlay only the common cells with an additional color
            tempImg(find(~ismember(tempImg,commoncells))) = 0;
            
            %Function call to convert grayImg to color by highlighting the
            %cells of interest in color. Color is assigned based on the current count number and the
            %distinguishable colors-to-use.
            [ rgbimg ] = make_rgb( tempImg,colorstouse,count);
            
            %Set the focus on the axes of the current image tab
            handles.panel_tiff_images;
            axes(tabmaster_histonetiff.Children(ik).Children.findobj('Type','axes'));
            
            %Hold on to the axes
            hold on;
            
            %Overlay the image of the highlighted cells on top of the image of the selected tab
            highlightmaskoutline = imshow(rgbimg);
            
            %Hold on to the image
            hold on;
            
            %Freeze colormap
            freezeColors;
            
            %Adjust the intensity of the single-cell mask
            intensemask = imadjust(double(tempImg));
            set(highlightmaskoutline,'AlphaData',intensemask);
            hold off;
            
            %Make the legend for the user to know which cells (colors)
            %correspond to which gate/ the common cells
            L = line(ones(numel(countnum)),ones(numel(countnum)), 'LineWidth',2,'Parent',tabmaster_histonetiff.Children(ik).Children.findobj('Type','axes'));%;
            set(L,{'color'},mat2cell(colorstouse(countnum,:),ones(1,numel(countnum)),3))
            hl=legend(L,cellfun(@(n)(num2str(n)), [gates(gatenum,1);{'CommonCells'}], 'UniformOutput', false)); hold on;
            
            %Set the location of the legend
            set(hl, 'Location','south');
            set(hl,'FontSize',8);freezeColors;
           
        %If no common cells were found
        else
            
            %Make the legend for the user to know which cells (colors) correspond to which selected gate
            L = line(ones(numel(countnum)),ones(numel(countnum)),'LineWidth',2,'Parent',tabmaster_histonetiff.Children(ik).Children.findobj('Type','axes'));  %tabmaster_histonetiff.Children(ik).Children.findobj('Type','axes'));hold on;%tabmaster_histonetiff.Children(ik).Children
            set(L,{'color'},mat2cell(colorstouse(countnum,:),ones(1,numel(countnum)),3))
            hl=legend(L,cellfun(@(n)(num2str(n)), gates(gatenum,1), 'UniformOutput', false));
            
            %Set the location of the legend
            set(hl, 'Location','south');
            set(hl,'FontSize',8,'Interpreter', 'none');freezeColors;
            
        end
        
    %If single-cell information was not found, continue to next imageid   
    else
        
        continue;

    end
    
%End of loop through imageids
end


end

