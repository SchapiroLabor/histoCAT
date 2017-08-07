function Area_selection_plot( current_axes )
% AREA_SELECTION_PLOT: Enables user to manually gate on scatter plot by
% encircleing an area with the cursor.
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Switch off external GUI functions
zoom off;
pan off;
rotate3d off;
datacursormode off;
handles = gethand;

%Retrieve Variables
sessionData = retr('sessionData');
sessiondata_index = retr('sessiondata_index');
vX  = retr('vX');
vY  = retr('vY');
nCH1  = retr('nCH1');
nCH2  = retr('nCH2');
gates = retr('gates');
selected_gates_plotted = retr('selected_gates_plotted');
set(handles.list_samples,'Value',selected_gates_plotted);
selected_gates = get(handles.list_samples,'Value');
allids = retr('allids'); 
lightup_sample = retr('lightup_sample');
commonlight = retr('commonlight');
put('vxyid',[]);

%If the user has highlighted samples before
if isempty(lightup_sample) ~= 1
    
    %Ask whether to clear highlights
    questlighted = questdlg('Would you like to clear the highlight before gating?');
    if strcmp(questlighted,'Yes') == 1
        %Set all highlights to invisible
        set([lightup_sample{:}],'Visible','off');
        set(commonlight,'Visible','off');
        %Clear sample highlight variable
        lightup_sample = [];
        put('lightup_sample',lightup_sample);
    end
end

%Initialize variables
CellIdrows = [];
notCellIdrows = [];

%Focus on current axes   
axes(current_axes);
hold on;
       

%Brief on how selectdata function works:
%pointslist is the index of the points(rows of the cellIds) but it is
%specific for each cellarray(or gate), hence it isnt continuous, so we find the
%CellIdrows from the xselect and yselect which are the coordinates of the
%points(or space) within the selection area.

%Function call to selectdata
[~,xselect,yselect] = selectdata('selectionmode','lasso');
       
%Store the selected positions
selected_position(:,1) = vertcat(xselect{:});
selected_position(:,2) = vertcat(yselect{:});


%Find the rows from vX and vY which are within the selected area. These
%rows correspond to the sessionData information, hence CellIds and their
%respective ImageIds. We pick the neighbour_CellIds from the fcs
%file(gates) and form a new matrix with ImageId
[CellIdrows_vXvY] = find(ismember(vX,selected_position(:,1)) & ismember(vY,selected_position(:,2))); %seems correct, check later anyway
%Find area that is not selected
CellIdrows_NOTvXvY  = find(~(ismember(vX,selected_position(:,1)) & ismember(vY,selected_position(:,2))));


%Loop through the selected gates
for k = selected_gates
    %Get the current gate's index in sessionData
    index_cur = (sessiondata_index{k}{1}(1):sessiondata_index{k}{1}(2))';
    %Check which values of X and Y plotted are part of sessionData's channel columns
    [CellIdrows_pre] = find(ismember(sessionData(sessiondata_index{k}{1}(1):sessiondata_index{k}{1}(2),nCH1),vX(CellIdrows_vXvY)) & ismember(sessionData(sessiondata_index{k}{1}(1):sessiondata_index{k}{1}(2),nCH2),vY(CellIdrows_vXvY)) & ismember(sessionData(sessiondata_index{k}{1}(1):sessiondata_index{k}{1}(2),1),[allids{k}]));
    %Check which values of X and Y plotted are not a part of sessionData's channel columns
    [CellIdrows_notpre] = find(ismember(sessionData(sessiondata_index{k}{1}(1):sessiondata_index{k}{1}(2),nCH1),vX(CellIdrows_NOTvXvY)) & ismember(sessionData(sessiondata_index{k}{1}(1):sessiondata_index{k}{1}(2),nCH2),vY(CellIdrows_NOTvXvY)) & ismember(sessionData(sessiondata_index{k}{1}(1):sessiondata_index{k}{1}(2),1),[allids{k}]));
    %Get the corresponding rows of the sessionData
    CellIdrows = vertcat(CellIdrows,index_cur(CellIdrows_pre));
    notCellIdrows = vertcat(notCellIdrows,index_cur(CellIdrows_notpre));
end
    

%Get the maximum amount of channels in the selected gates
end_max = max(cellfun(@length,gates([selected_gates],3)));

%Store the selected area and the area that is not part of the selection
area_selected = sessionData(CellIdrows,1:end_max);
area_notselected = sessionData(notCellIdrows,1:end_max);

%Update GUI variables    
put('selected_position',selected_position);
put('area_selected',area_selected);
put('area_notselected',area_notselected);

end



