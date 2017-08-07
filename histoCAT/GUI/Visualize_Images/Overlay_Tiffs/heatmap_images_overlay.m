function heatmap_images_overlay( labelimg, labelvec, valuevec, axis ,handles )
% HEATMAP_IMAGES_OVERLAY: This function gets called to overlay the tiff-image 
% with a heatmap of the single-cell intensities of the selected channel.
% It maps the intensity values to the cell labels and assigns colors.
%
% Input:
% labelimg --> single-cell mask where the pixels of each individual cell
% are labelled with the corresponding cell number
% labelvec --> vector of single-cell labels
% valuevec --> vector of intensity values corresponding to the single cells
% axis --> handle to current axis
% handles --> handle to GUI variables
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Initialize amount of colors
ncols =100;

%Retrieve current percentile cut-off slider value
global currentsliderValue;
perc = currentsliderValue;

%If a percentile cut-off has been set
if ~(isempty(perc) == 1)
    
    %Function call to cut off the values above a given percentile
    %(outliers)
    valuevec = percentile_cutoff(labelvec, valuevec, handles, perc);
    
end

%Sort the label vector and the value vector according to the same order
[labelvec, ord] = sort(labelvec);
valuevec = valuevec(ord);

%Normalize the value vector
maxval = max(valuevec);
minval = min(valuevec);
res_valuevec = (valuevec-minval)/(maxval-minval);

%If there are no values found, return
if isnan(res_valuevec) == 1
    disp('No Data found to visualize');
    return;
end

%Make a 'full vector' in case some cell labels were missing
full_valuevec = zeros(max(labelimg(:)),1);
full_valuevec(labelvec) = res_valuevec;
full_valuevec = (full_valuevec-min(full_valuevec(:))) ./ (max(full_valuevec(:)-min(full_valuevec(:))));

%Define the color map
colmap = jet(ncols+1);

%Assign the colors to the values
full_valuevec = round(full_valuevec*ncols)+1;
colmap_lab = colmap(full_valuevec,:);

%Remove labels that are not in the labelvector from the image mask
labelimg(~ismember(labelimg, labelvec)) = 0;

%Apply the colormap
rgb_img = label2rgb(labelimg, colmap_lab, [0,0,0]);

%Set focus on axis and hold on to it
axes(axis);
hold on;

%Display image
intenseim = imshow(rgb_img);
hold on;

%Set colorbar
colormap(axis,colmap);
cbr = colorbar(axis);
cbr.Location = 'SouthOutside';
hold on;

%Set labels, lims and ticks
drawnow;
lims = get(cbr,'Limits');
yval = linspace(lims(1), lims(2),11);
set(cbr,'ytick',yval);
ylab=linspace(minval,maxval,11);
ylab =round(ylab, 2, 'significant');
set(cbr,'YTickLabel',ylab);
freezeColors;

%Set position of colorbar
cbr.Position = [0.1542 0.022 0.7274 0.0200];

%Tag the image
set(intenseim,'Tag','rgbimage1');

end

