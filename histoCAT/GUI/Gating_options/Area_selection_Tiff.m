function Area_selection_Tiff(current_axes,Sample_Set_arranged,Mask_all,Fcs_Interest_all)
% AREA_SELECTION_TIFF: Enables user to manually gate on tiff-image by
% encircleing an area with the cursor.
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Switch off all the external GUI functions
zoom off;
pan off;
rotate3d off;
datacursormode off;

%Get GUI handles
handles = gethand;

%Retrieve variables
notNan = retr('notNan');
sessionData = retr('sessionData');
gates=retr('gates');
tabmaster_histonetiff = retr('tabmaster_histonetiff');
%Retrieve the X and Y coordinates
%A cell containing all the tab's axes' X coords
vX = retr('PlotX'); 
%A cell containing all the tab's axes' Y coords
vY = retr('PlotY'); 

%Get the index of the image in the current tab
splitSamplename = cellfun(@(x) strsplit(x,fullfile('/')),Sample_Set_arranged,'UniformOutput',false);
allcutnames = cellfun(@(x) x(end),splitSamplename);
idxfound_name = find(~cellfun('isempty',regexpi(allcutnames,tabmaster_histonetiff.SelectedTab.Title)));
%Store the image index
put('idxfound_name',idxfound_name);

%Get the X and Y coordinates of the centroid of each cell
areaXY = struct2cell(regionprops(Mask_all(idxfound_name).Image,'Centroid'));

%In case of missing cellIDs (this can only be the case for older stored 
%sessions, the current loading function corrects for missing cellIDs)
if ~isempty(notNan)
    curr_notNan = notNan{idxfound_name};
    areaXY = areaXY(curr_notNan);
end

%Convert individual cell coordinate douplets into arrays of all x/y coordinates
allfcs_sessionX = cellfun(@(x) double(x(:,1)),areaXY)';
allfcs_sessionY = cellfun(@(x) x(:,2),areaXY)';

%If no single cell information is present, return
if isempty(allfcs_sessionX) == 1
    disp('Cannot gate, no single cell information found..');
    put('area_selected',[]);
    return;
end

%Get the serial number of the current tab
vxyid = find(tabmaster_histonetiff.Children == tabmaster_histonetiff.SelectedTab);
%And store it
put('vxyid',vxyid);
   
%Clear all previous selections
put('selected_position',[]);
      
%Set current axes
axes(current_axes);
hold on;

        
%Brief on how selectdata function works:
%pointslist is the index of the points(rows of the cellIds) but it is
%specific for each cellarray(or gate), hence it isnt continuous, so we find the
%CellIdrows from the xselect and yselect which are the coordinates of the
%points(or space) within the selection area.

%Function call tio selectdata
[~,xselect,yselect] = selectdata('selectionmode','lasso');

%Store the selected positions
selected_position(:,1) = vertcat(xselect{:});
selected_position(:,2) = vertcat(yselect{:});
put('selected_position',selected_position);

     
%Find the rows from vX and vY which are within the selected area:
%These rows correspond to the current tiff-image's fcs information, hence CellIds and their
%respective ImageIds.
[CellIdrows_vXvY] = find(ismember(vX{vxyid},selected_position(:,1)) & ismember(vY{vxyid},selected_position(:,2))); 
%Get the area that is not selected
CellIdrows_NOTvXvY  = find(~(ismember(vX{vxyid},selected_position(:,1)) & ismember(vY{vxyid},selected_position(:,2))));

%Get the cellid rows by just using allfcs_session, where there is
%no repetition of Cellid numbers.
[CellIdrows] = find(ismember(allfcs_sessionX,vX{vxyid}(CellIdrows_vXvY)) & ismember(allfcs_sessionY,vY{vxyid}(CellIdrows_vXvY)));
[notCellIdrows] = find(ismember(allfcs_sessionX,vX{vxyid}(CellIdrows_NOTvXvY)) & ismember(allfcs_sessionY,vY{vxyid}(CellIdrows_NOTvXvY)));

%Get the corresponding rows of the sessionData
rows = gates{idxfound_name,2};
sessdat = sessionData(rows,:);

%Get the current tab's fcs information
if isempty(Fcs_Interest_all{idxfound_name}) ~= 1
    allfcs_session = sessdat;
else
    disp('No fcs found, but storing other information for current sample');
    allfcs_session = [allfcs_sessionX,allfcs_sessionY];
end

%Store the selected and not selected area's single-cell info
area_selected = allfcs_session(CellIdrows,:);
area_notselected = allfcs_session(notCellIdrows,:);

%Update GUI variables
put('area_selected',area_selected);
put('CellIdrows',CellIdrows);
put('area_notselected',area_notselected);

end

