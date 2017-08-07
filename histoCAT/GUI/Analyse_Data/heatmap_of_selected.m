function heatmap_of_selected()
% HEATMAP_OF_SELECTED: Displays heatmap, of selected channels (means/medians)
% and the selected gates, in analyse section of the GUI
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve GUI variables
gates = retr('gates');
sessionData = retr('sessionData');
handles = gethand;
channelNames = retr('list_channels');
selectedChannels = get(handles.list_channels,'Value');
put('xv_polygon',[]);
delete(handles.panel_plots.Children);

%Get only those gates which have single cell data
selected_gates_unfiltered = get(handles.list_samples,'Value');
get_tiffgates = find(cellfun('isempty',gates(selected_gates_unfiltered,2)));
if isempty(get_tiffgates) == 1
    selectedGates = selected_gates_unfiltered;
else
    selectedGates = selected_gates_unfiltered(find(~ismember(selected_gates_unfiltered,selected_gates_unfiltered(get_tiffgates))));
end

%Store the selected gates in another variable
selected_gates_plotted = selectedGates;
put('selected_gates_plotted',selected_gates_plotted);

%Channels for which heatmap will be plotted
displayChannels = selectedChannels;

%If median checkbox is checked, display medians, otherwise take means
if handles.median.Value == 0
    
    %Loop through selected channels and selected gates and calculate mean of each channel
    %for each gate and store in matrix
    
    %Initialize variable
    summarized_Intensities = [];
    
    %Loop through selected channels
    for i=displayChannels
        
       %Get current channel index in selected gates
       [~,curchan] = ismember(channelNames{i},gates{selectedGates(1),3});

       %Initialize variable
       summary_by_columns = [];
       
       %Loop through selected gates
       for j = selectedGates
           
            %Get the index of the current gate
            currGate = gates{j, 2};

            %Get data of current channel in current gate
            currChanGate = sessionData(currGate, curchan);
            
            %Take mean of the channel values in current gate and store
            summarized_currChanGate = mean(currChanGate);
            summary_by_columns = [summary_by_columns; summarized_currChanGate];
       end
       
       %Scale per channel (column)and store values
       summary_by_columns_norm = (summary_by_columns - min(summary_by_columns))/(max(summary_by_columns)-min(summary_by_columns));
       summarized_Intensities = [summarized_Intensities summary_by_columns_norm];
    end
    
elseif handles.median.Value == 1
    
    %Loop through selected channels and selected gates and calculate median of each channel
    %for each gate and store in matrix
    
    %Initialize variable
    summarized_Intensities = [];

    %Loop through selected channels
    for i=displayChannels
        
       %Get current channel index in selected gates
       [~,curchan] = ismember(channelNames{i},gates{selectedGates(1),3});

       %Initialize variable
       summary_by_columns = [];
       
       %Loop through selected gates
       for j = selectedGates
           
            %Get the index of the current gate
            currGate = gates{j, 2};

            %Get data of current channel in current gate
            currChanGate = sessionData(currGate, curchan);
            
            %Take median of the channel values in current gate and store
            summarized_currChanGate = median(currChanGate);
            summary_by_columns = [summary_by_columns; summarized_currChanGate];
       end
       
       %Scale per channel (column)and store
       summary_by_columns_norm = (summary_by_columns - min(summary_by_columns))/(max(summary_by_columns)-min(summary_by_columns));
       summarized_Intensities = [summarized_Intensities summary_by_columns_norm];
    end
end

%Get the names of the gates
gateNames={};
count=1;
for g =selectedGates
    gateNames{count}=gates{g,1};
    count=count+1;
end

%Get the names of the channels
channelNames_curr = channelNames(selectedChannels)';

%Initialize plot
ax = subplot(1,1,1,'Parent',handles.panel_plots);

%Labels
y=gateNames;
x=channelNames_curr;

%Add another last row and last column of zeros because pcolor
%ignors last row and column
addcol = zeros(1,length(selectedGates))';
addrow = zeros(1,(length(selectedChannels)+1));

%If b2r checkbox is checked, display b2r heatmap
if handles.b2r.Value == 1
    
    %Take zscore per channel for different gates to be comparable
    Zperchannel=[];
    for channel=1:length(selectedChannels)
        Zperchannel = [Zperchannel zscore(summarized_Intensities(:,channel))];
    end
    
    %Generate heatmap
    meanInt = [Zperchannel addcol];
    mI = [meanInt; addrow];
    pcolor(ax,mI);
    colormap(ax,b2r(min(mI(:)),max(mI(:))));
else
    %If b2r is not checked, display regular heatmap with default colors
    meanInt = [summarized_Intensities addcol];
    mI = [meanInt; addrow];
    colormap default;
    pcolor(ax,mI); 
end

%Change default interpreter from tex to none
set(gca,'TickLabelInterpreter','none')

%Add colorbar
colorbar(ax);

%Reverse direction of Y axis, pcolor uses by default the other direction 
set(ax,'XTick',1:length(selectedChannels),'XTickLabel',x,'YTick',1:length(selectedGates),'YTickLabel',y,'YDir','reverse');

%Rotate x-axis labels
ax.XTickLabelRotation=45;

end

