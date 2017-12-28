function [ tiff_matrix ] = fuse_images(tabchild,imh)
% FUSE_IMAGES: If more than one tiff (channel) is selected, fuse the
% images into one displaying the different channel's pixel intensities in different
% colors.
%
% tabchild --> the current tab created for the sample by the
% overlay_maskandchannels function
% imh --> the loop/gatenames number to keep in sequence
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI variables
handles = gethand;
tab_axes = retr('tab_axes1');

%Delete javawrapper classes
delete(tabchild.Children.findobj('Units','pixels'));

%Retrieve global variables
global Mask_all

%Function call to get the index and the tiff name of the selected channels
[sel_channels,tiff_matrix] = Comparetiffnames_tolistchannels(Mask_all);

%Store the colormap based on the number of selected channels
%in order: 'r','g','b','c','m','y'
colorstouse = [[1 0 0];[0 1 0];[0 0 1];[0 1 1];[1 0 1];[1 1 0]];

%If no axes found, create one
if isempty(tab_axes) == 1
    handles.panel_tiff_images;
    tab_axes = subplot(1,1,1,'Parent',tabchild);
    put('tab_axes1',tab_axes);
end

%We can only visualize 6 colors - Show error
if length(tiff_matrix{1,imh})<=6
    
    %Loop through the selected tiffs (channels)
    for k=1:length(tiff_matrix{1,imh})
        
        %Scale image
        tiffimage_read = mat2gray(tiff_matrix{1,imh}{k});
        
        %Focus on axes
        handles.panel_tiff_images;
        axes(tab_axes);
        hold on;
        
        %If it is the first image, set background as the BWimage
        if k == 1
            blackim = imshow(tiffimage_read);
            set(blackim,'Tag','firstgrayimage');
            hold on;
        end
        
        %Function call to convert image to RGB
        [rgb_Image] = make_rgb( tiffimage_read,colorstouse,k);
        hold on;
        
        %Display RGB image
        imagesh = imshow(rgb_Image);freezeColors;
        hold on;
        
        %Tag image
        set(imagesh,'Tag',strcat('rgbimage',int2str(k)));
        hold off;
        
        %Freeze colors
        freezeColors;
        
        %Adjust the intensity of the cell colors if multiple channels are
        %selected
        if length(tiff_matrix{1,imh}) ~= 1
            disp('Applying contrast to image to display all markers')
            intensemask =  imadjust(tiffimage_read);
        else
            intensemask =  tiffimage_read;
        end
        
        %Set the alphadata of the RGB image to the adjusted grayimage
        set(imagesh,'AlphaData',intensemask);
        freezeColors;
        
        hold off;
       
    end  
    
else
    %Show error if more than 6 markers
    errordlg('Please select maximum 6 channels simultaneously');
end

%If multiple channels are selected
if numel(sel_channels) > 1
    
    %Set up legend of which color correspond to which channel
    string_channels = retr('list_channels');
    La = line(ones(numel(sel_channels)),ones(numel(sel_channels)),'LineWidth',2,'Parent',tabchild.Children.findobj('Type','axes'));
    set(La,{'color'},mat2cell(colorstouse(1:numel(sel_channels),:),ones(1,numel(sel_channels)),3)); freezeColors;
    hla=legend(La,cellfun(@(n)(num2str(n)), string_channels(sel_channels), 'UniformOutput', false));
    
    %Define the location of the legend
    set(hla, 'Location','South');
    set(hla,'FontSize',8,'Interpreter','none');
    
end

end

