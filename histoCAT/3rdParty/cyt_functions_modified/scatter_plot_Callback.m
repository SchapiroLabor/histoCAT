function scatter_plot_Callback(hObject, eventdata, handles)
% SCATTER_PLOT_CALLBACK: Produces scatterplot of selected channels (select
% 2 channels for 2D plot or 3 channels for 3D plot) in selected
% gates. If multiple gates are selected they are displayed in different
% colors.
%
% This function is modified from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% hObject: handle to scatter_plot (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%Retrieve Variables
hplots_gates  = retr('hplots_gates');
selectedChannels = get(handles.list_channels,'Value');
sessionData  = retr('sessionData');
gates        = retr('gates');
gateContext  = retr('gateContext');
channelNames = retr('list_channels');

%Get only those gates which have single cell data
selected_gates_unfiltered = get(handles.list_samples,'Value');
get_tiffgates = find(cellfun('isempty',gates(selected_gates_unfiltered,2)));
if isempty(get_tiffgates) == 1
    selected_gates = selected_gates_unfiltered;
else
    selected_gates = selected_gates_unfiltered(find(~ismember(selected_gates_unfiltered,selected_gates_unfiltered(get_tiffgates))));
end

%Empty previous variables
put('meanslist',[]);
put('xv_polygon',[]);

%Set text interpreter from tex to none
set(0, 'DefaulttextInterpreter', 'none');

%Delete previous plots
delete(handles.panel_plots.Children);

%Keep track of what was plotted for other functions
selected_gates_plotted = selected_gates;
put('selected_gates_plotted',selected_gates_plotted);

%Clear previous plot variables
put('vX',[]);
put('vY',[]);
put('hplots',[]);
put('valmsg','');
put('area_selected',[]);
put('neighbr_scatter_plotcells',[]);
put('neighbr_scatter',[]);
put('selection_scatter',{});
put('lightup_sample',[]);
put('hplots',[]);
put('hplots_gates',[])
put('hist_plot',[])
delete(handles.panel_plots.Children);


if numel(selectedChannels) > 2
    if ~(selectedChannels(3) > 1)
        selectedChannels(3) = [];
    end
end

nSelChannels = numel(selectedChannels);

%Maximally 3 channels can be selected (3D scatter plot)
if nSelChannels>3
    msgbox('Too many channels for XYZ axes, choose Heat-map of channels');
    return;
end

%At least 2 channels have to be selected
if nSelChannels<2
    msgbox('Select atleast 2 channels to plot');
    return;
end

%If no gate selected, select all gates
if (numel(selected_gates)==0 || nSelChannels==0)
    selected_gates = 1:size(gates, 1);
end

%If a tiff without single cell info was selected
if (isempty(gateContext) || isempty(selectedChannels))
    msgbox('selected sample does not have fcs');
    return;
end

%Get first and second channels for x and y axes
nCH1 = selectedChannels(1);
nCH2 = selectedChannels(2);
[~,selchannels1] = ismember(channelNames{nCH1},gates{selected_gates(1),3});
[~,selchannels2] = ismember(channelNames{nCH2},gates{selected_gates(1),3});

%In case there is a third channel for z axis
nCH3 = 0;
selchannels3 = 0;
if (nSelChannels == 3)
    nCH3 = selectedChannels(3);
    [~,selchannels3] = ismember(channelNames{nCH3},gates{selected_gates(1),3});
end

  
%Get rows of session data corresponding to selected gates
intIndices = getIntIndices;

%Initialize variables
aggregateinds = [];
vColor = [];

%Loop through all selected gates and assign color to each
for gi=selected_gates
    
    %Get rows in session data corresponding to current gate
    currGate = gates{gi, 2};
    
    %Get the intersection between the rows of all selected gates and the
    %rows of the current gate
    if (~isempty(intIndices))
        currGate = intersect(intIndices, currGate);
    end
    
    %Assign color to each gate
    vColor = [vColor; ones(numel(currGate), 1)*gi];
    aggregateinds = [aggregateinds; currGate(:)];
end

%Get data points corresponding to all selected gates and the selected
%channels
vX = sessionData(aggregateinds, selchannels1);
vY = sessionData(aggregateinds, selchannels2);

%If there is a third channel selected, get the data points for that one too
if (nSelChannels == 3)
    vZ = sessionData(aggregateinds, nCH3);
else
    vZ = vColor;
end

%Get distinguishable colors for each gate
clr = distinguishable_colors(numel(selected_gates));

%Amount of different colors needed
vColor_discrete = vColor;
colors = unique(vColor)';
for ci=1:numel(colors);
    vColor_discrete(vColor==colors(ci)) = ci;
end

%Initialize plot
handles.panel_plots;
hplots_gates = subplot(1,1,1,'Parent',handles.panel_plots);

%Plot scatter plot
myplotclr(vX, vY, vZ, vColor_discrete, '.', clr, [min(vColor_discrete), max(vColor_discrete)], false,hplots_gates);
hold on;
grid off;
colorbar off;

%If more than one gate is selected, make legend of which gate corresponds
%to which color
if numel(selected_gates) > 1
    legend_gates = legend(remove_repeating_strings(gates(selected_gates, 1)));
    put('legend_gates',legend_gates);
    set(legend_gates, 'Interpreter', 'none');
    drawnow;
    hplots_gates.Position = [0.0750 0.0900 0.90 0.88];
    if (numel(selected_gates) > 6)
        set(legend_gates, 'Location','NorthEastOutside');
        set(legend_gates,'FontSize',6);
        drawnow;
        hplots_gates.Position = [0.1300 0.1100 0.6050 0.8150];
    end
else
    drawnow;
    hplots_gates.Position = [0.0750 0.0900 0.90 0.88];
end
    
%Set labels corresponding to the channels in the plot
xlabel(channelNames{nCH1}, 'Interpreter', 'none');
ylabel(channelNames{nCH2}, 'Interpreter', 'none');
if (nSelChannels == 3)
    zlabel(channelNames{nCH3});
    view(3);
end
hold on;


%Update variables
put('hplots_gates',hplots_gates);
put('vX',vX);
put('vY',vY);
put('nCH1',selchannels1);
put('nCH2',selchannels2);
put('nCH3',selchannels3);


end
