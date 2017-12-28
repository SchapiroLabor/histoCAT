function plot_boxplots_per_gate() 
% PLOT_BOXPLOTS_PER_GATE: Plots boxplots of the different gates next to each other for each selected channel.
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve GUI variables
handles = gethand;
sessionData	= retr('sessionData');
gateContext	= retr('gateContext');
gates       = retr('gates');
channelNames = retr('list_channels');
selectedChannels = get(handles.list_channels,'Value');
nSelChannels     = numel(selectedChannels);
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

%Function call to get sessionData indices of the current selected gates
intIndices  = getIntIndices;

%Channels for which boxplots will be plotted
displayChannels = selectedChannels;

%Store the length of the selected gates
nSelGates = numel(selectedGates);

%Clear the figure panel
try
    %To clear earlier plots if there are any
    put('bplots',[]);
    put('bplots_gates',[]);
    put('box_plot',[]);
    delete(handles.panel_plots.Children);
catch
end

%Create plot axes
box_sub1 = subplot(1,1,1,'Parent',handles.panel_plots);

%If no channels were selected return
if (nSelChannels <= 0) 
    return;
end
    
%Set distinguishable colors and reset number of subplots
ColorMtx = distinguishable_colors(max(2, nSelGates));

%Create an axes on which dummy lines can be created for each gate
box_sub2 = subplot(1,1,1,'Parent',handles.panel_plots);

%Intitialize counter
counter = 1;

%Loop through the selected channels to create a boxplot for each
for channel = displayChannels
    
    %Get current channel index
    [~,curchan] = ismember(channelNames{channel},gates{selectedGates(1),3});
    
    %Initialize variables
    allGatesData = [];
    allGatesName = {};
    
    %Create axes for each individual boxplot
    box_plot = subplot(length(selectedChannels), 1, counter,'Parent',handles.panel_plots);
    counter=counter+1;
    
    %Loop through selected gates for each channel to put into same plot
    for j = selectedGates

        %Get the sessionData rows corresponding to the current gate
        currGate = gates{j, 2};
        
        %Get intersection between all selected gates and the current one
        if ~isempty(intIndices)
            currGate = intersect(intIndices, currGate);
        end
        
        %Store current gate name
        currGateName = gates{j,1};
        put('currGateName',currGateName);
        
        %Keep track of data of all selected gates
        allGatesData = [allGatesData; sessionData(currGate,curchan)];
        
        %Repeate gate name for each row of current gate and store in cell
        oneGate = repmat(currGateName,[length(currGate),1]);
        cellGate = num2cell(oneGate,2);
        
        %Keep track of all gate names
        allGatesName = [allGatesName; cellGate];
        
        %Make boxplots of all selected gates next to each other
        bplot=boxplot(allGatesData, allGatesName,'colors', ColorMtx(1:length((selectedGates)-1),:));

        %Store the plot data
        put('bplot',bplot);

        %Set the labels and title
        title(sprintf(channelNames{channel}),'FontSize',8,'Interpreter', 'none');
     
    end

end

%Update variables
put('box_plot',box_plot);
put('box_sub1',box_sub1);
put('box_sub2',box_sub2);
sprintf('Plotted %i points', length(gateContext));
   
end