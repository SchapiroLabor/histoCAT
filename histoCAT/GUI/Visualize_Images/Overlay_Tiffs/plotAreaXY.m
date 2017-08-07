function plotAreaXY(tabchild,imh,imageids,sample_orderIDX)
% PLOTAREAXY: This function plots the single-cell centroids once for each 
% selected gate and stores them as part of the image tab.
% 
% Input:
% tabchild --> handle to image tab
% imh --> current number of selected sample (this function is part of a
% loop through all selected samples)
% imageids --> image IDs of all selected samples
% sample_orderIDX --> indices of currently selected samples in the session/
% list box
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles and global variables
handles = gethand;
global Mask_all

%Initialize variable
vColor = [];

%Centroids get plotted only once for each selected gate (imh -> count)
%by function call to regionprops
areaXY = struct2cell(regionprops(Mask_all(sample_orderIDX(imh)).Image,'Centroid'));

%If no centroids were found, there is no single-cell information
if isempty(areaXY) == 1
    
    vX_olay = [];
    disp('Sample not segmented yet...');
    put('tab_axes1',[]);
    put('vX_olay',vX_olay);
    return;
    
%If centroids were found, extract x and y variables for plotting
else
    vX_olay = cellfun(@(x) double(x(:,1)),areaXY)';
    vY_olay = cellfun(@(x) x(:,2),areaXY)';
    vColor = [vColor; ones(size(areaXY,2), 1)*1];
    vZ_olay = vColor;
    
    %Update and store the variables
    put('vX_olay',vX_olay);
    put('vY_olay',vY_olay);   
end

%Set the color for the dots to be plotted
clr = distinguishable_colors(numel(imageids));

%Create dummy third dimension
vColor_discrete = vColor;
colors = unique(vColor)';
for ci=1:numel(colors);
    vColor_discrete(vColor==colors(ci)) = ci;
end
            
%Plot on the tiff images panel
handles.panel_tiff_images;

%Create axes to plot on
tab_axes1 = subplot(1,1,1,'Parent',tabchild);

%Function call 'myplotclr' to plot centroids
myplotclr(vX_olay, vY_olay, vZ_olay, vColor_discrete, '.', clr, [min(vColor_discrete), max(vColor_discrete)], false,tab_axes1);%(imh,:)
freezeColors;

%Switch off colorbar
colorbar(tab_axes1,'off');
hold on;
   
%Update variable
put('tab_axes1',tab_axes1);
   
end

