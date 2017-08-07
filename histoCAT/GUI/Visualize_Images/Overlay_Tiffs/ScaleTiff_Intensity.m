function ScaleTiff_Intensity( Alltiffsmat,sliderintensityScale,RGBColourChkboxindex,noise_checkbox )
% SCALETIFF_INTENSITY: Adjusts color intensity of selected colors (tiff-images) based on
% the slider value set by the user.
%
% Input:
% Alltiffsmat --> tiff-matrices of each channel (color) of the currently displayed
% image
% sliderintensityScale --> slider value set by user
% RGBColourChkboxindex --> index of checked box (altered color)
% noise_checkbox --> handle to the noise checkbox
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve GUI variables
tabmaster_histonetiff = retr('tabmaster_histonetiff');

%Store the colormap based on the number of selected gates
%in order: 'r','g','b','c','m','y'
colorstouse = [[1 0 0];[0 1 0];[0 0 1];[0 1 1];[1 0 1];[1 1 0]];

%Apply to all open tabs
for tb=1:numel(tabmaster_histonetiff.Children)
    
    %Apply for each checked color
    for clrcode = RGBColourChkboxindex'
        
        %Delete the rgbimage that was create as part of visualize function
        %for the current channel
        delete(tabmaster_histonetiff.Children(tb).Children.findobj('type','axes').Children.findobj('tag',strcat('rgbimage',int2str(clrcode))))
        
        %Store the matrix of the current channel's tiff-image
        tiffimage_read = Alltiffsmat{1,tb}{clrcode};
        
        %Convert it from uint16 to double
        scale_tiff = im2double(tiffimage_read) ./ 65535;
        
        %Multiply the mat2gray version of the double image with the slider value
        %(this image will be used for the alphadata of the image)
        scale_tiffslider = mat2gray(scale_tiff) * sliderintensityScale;
        
        %Check if noise cancellation is requested
        if noise_checkbox.Value == 0
            
            %If no noise cancellation is requested convert the image to RGB
            %directly
            [ rgb_Image ] = make_rgb( tiffimage_read,colorstouse,clrcode);
            
        else
            
            %If noise cancellation is checked, use the Matlab medfilt2 function
            %to obtain a median based filtered matrix of the image.
            [ rgb_Image ] = make_rgb( medfilt2(tiffimage_read),colorstouse,clrcode);
        end
        
        %Set the focus to the current axes and hold on to it
        axes(tabmaster_histonetiff.Children(tb).Children.findobj('type','axes'));
        hold on;
        
        %Display the rgb image
        imagesh = imshow(rgb_Image);freezeColors;hold on;
        
        %Tag image
        set(imagesh,'Tag',strcat('rgbimage',int2str(clrcode)));
        hold off;
        
        %Freeze colors
        freezeColors;
        
        %Set the alphadata (intensity) of the RGB image to the adjusted
        %grayimage from above
        set(imagesh,'AlphaData',scale_tiffslider);freezeColors;
        
        hold off;
        
    end
    
end


end





