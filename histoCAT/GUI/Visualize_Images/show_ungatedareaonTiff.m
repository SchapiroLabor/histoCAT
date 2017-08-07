function show_ungatedareaonTiff( Sample_Set_arranged,HashID,Fcs_Interest_all,Mask_all )
% SHOW_UNGATEDAREAONTIFF: Gets called when 'Highlight excluding selected sample'
% from the Visualize options drop down menu is executed. Highlights all the 
% cells except for the ones of the selected gates(s) on the current image.
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
[imageids,~,SGsof_imageids_open,sample_orderIDX ] = getimageids_of_selectedgates(Sample_Set_arranged,HashID,selected_gates, allids);

%If a sample in the list_visual listbox other than 'None' (the first option) 
%is selected, work with (highlight excluding) this selected sample, otherwise
%use the selected sample(s) from the samples listbox (list_samples) from above
if unique(get(handles.list_visual,'Value') > 1) == 1
    selectedsample_tiff = get(handles.list_visual,'Value') - 1;
    imageids = imageids(selectedsample_tiff);
    sample_orderIDX = sample_orderIDX(selectedsample_tiff);
end

%Find colors that are most distinguishable from already used colors and
%store the colormap based on the number of selected gates
colorsalreadyused = [[0 0 0];[1 20/255 147/255];[199/255 21/255 133/255];[1 105/255 180/255];[1 0 0];[0 1 0];[0 0 1];[0 1 1];[1 0 1];[1 1 0];[0.8 0.5 0];[0 0 0.8];[0.5 0.5 0.5];[0 0.5 0]];
colorstouse = distinguishable_colors(numel(imageids),colorsalreadyused);%SGsof_imageids_open

%Loop through each of the selected imageIDs
for ik = 1:length(imageids)
       
    %If single-cell information was found for the current imageID
    if isempty(Fcs_Interest_all{sample_orderIDX(ik),1}) ~= 1
        
        %Initialize variables
        Cells_selected = [];
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
              
              %Set the cells which were found to 0 to omit them (show
              %everything but them)
              tempImg(find(ismember(tempImg,Cells_selected{count}))) = 0;
              
              %Function call to convert grayImg to color by highlighting the
              %cells of interest in color. Color is assigned based on the current count number and the
              %distinguishable colors-to-use.
              [ rgbimg_rest ] = make_rgb( tempImg,colorstouse,count);
              
              %Set the focus on the axes of the current tab
              handles.panel_tiff_images;
              axes(tabmaster_histonetiff.Children(ik).Children.findobj('Type','axes'));
              
              %Hold on to the axes
              hold on;
              
              %Show the image of the highlighted cells on top of the image of the selected tab
              highlightmaskoutline = imshow(rgbimg_rest);
              
              %Hold on to the image to layer other images of highlighted
              %cells from other selected gates for the current imageID
              hold on;
              
              %Freeze colormap
              freezeColors;
              
              %Adjust the intensity of the single-cell mask
              intensemask = imadjust(double(tempImg));
              set(highlightmaskoutline,'AlphaData',intensemask);
              hold off;
              
              %Increment count
              count = count + 1;
        
        end
        
        %Make the legend for the user to know which cells (colors) correspond to which selected gate
        L = line(ones(numel(countnum)),ones(numel(countnum)), 'LineWidth',2,'Parent',tabmaster_histonetiff.Children(ik).Children.findobj('Type','axes'));
        set(L,{'color'},mat2cell(colorstouse(countnum,:),ones(1,numel(countnum)),3))
        hl=legend(L,cellfun(@(n)(num2str(n)), strcat('not',gates(gatenum,1)), 'UniformOutput', false)); 
        
        %Set the location of the legend
        set(hl, 'Location','south');
        set(hl,'FontSize',8);
        
    %If single-cell information was not found, continue to next imageid    
    else     
        continue;
    end
    
%End of loop through imageids
end


end

