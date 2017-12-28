function [meanslist] = plot_histograms(by_gates)
% PLOT_HISTOGRAMS Plots histograms with their mean intensities.
%
% This function is modified from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Input: by_gates --> If 1, labels are shown
% 
% Output: mean intensities
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve variables
handles = gethand;
sessionData	= retr('sessionData');
gateContext	= retr('gateContext');
gates       = retr('gates');
channelNames = retr('list_channels');
selectedChannels = get(handles.list_channels,'Value');
nSelChannels     = numel(selectedChannels);
put('xv_polygon',[]);
delete(handles.panel_plots.Children);
%Get selected gates

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

%function call to get indices of the current selected gates
intIndices  = getIntIndices;

%Channels for which histogram will be plotted
displayChannels = selectedChannels;
%Store the length of the selected gates
nSelGates     = numel(selectedGates);

%clear the figure panel containing hist
try
    
    %To clear earlier plots from view channels
    put('hplots',[]);
    put('hplots_gates',[]);
    put('hist_plot',[]);
    delete(handles.panel_plots.Children);
catch
    
end


%If there were no indices(since for tiffs the gateContext is not filled)
if (isempty(gateContext))
    msgbox('selected sample does not have fcs');
    return;
end

%Create an axes
hist_sub1 = subplot(1,1,1,'Parent',handles.panel_plots);

% If no channels were selected
if (nSelChannels <= 0)
    return;
end


% begin plotting
% Create as sqrt of as many columns as selected channels
nrows = round(sqrt(nSelChannels+1));
%If this value squared is than channels selected
if nrows^2 < (nSelChannels+1)
    ncols = nrows+1;
else
    ncols = nrows;
end

%If only two channels to display
if nSelChannels == 2
    nrows = 2;
    ncols = 3;
end

%set colors and reset num of subplots
ColorMtx = distinguishable_colors(max(2, nSelGates));
%Create an axes on which dummy lines can be created for each gate
hist_sub2 = subplot(1,1,1,'Parent',handles.panel_plots);
%Function call to create different dummy lines for different gates
dplot(1:100, 'colors', ColorMtx);
%Initialize legend flag
%legend_space = 0;

%Plot Legend
if (by_gates)
    %flag to present a legend !!Do NOT CHANGE!!
    legend_space = 1;
    
    %generate as many dummy lines as are gates selected
    handles.panel_plots;
    hPlot_histogram = subplot(nrows, ncols, 1,'Parent',handles.panel_plots);
    
    %For every gate
    for j = selectedGates
        hLine = dplot(1:100, 'colors', ColorMtx);
        set(hLine,'Visible','off');
    end
    %Create legend having the selected gates as string
    hist_legend = legend(remove_repeating_strings(gates(selectedGates, 1)), 'Interpreter', 'none');
    %Update variables
    put('hPlot_histogram',hPlot_histogram);
    put('hist_legend',hist_legend);
    %hide dummy plot and keep legend ;)
    set(hPlot_histogram,'Visible','off');
end

%plot histograms
i = 1+legend_space;
meanslist = [];
%count is 1 because the first set is for the header in the xls file.
count = 1;
meanslist{count,1} = 'SelectedGates';
meanslist{count,2} = 'Channel';
meanslist{count,3} = 'Mean_Intensity';

%Loop through the selected channels to plot
for channel = displayChannels
    
    [~,curchan] = ismember(channelNames{channel},gates{selectedGates(1),3});%find(~cellfun('isempty',strfind(gates{selectedGates(1),3},channelNames{channel})));
    
    %Create axes for each histogram plot
    hist_plot(i) = subplot(nrows, ncols, i,'Parent',handles.panel_plots);
    %%Increment
    i = i+1;
    count = count+1;
    %For the selected gates
    for j = selectedGates
        %get the indices
        currGate = gates{j, 2};
        %Get the common ones from the selected gates
        if ~isempty(intIndices)
            currGate = intersect(intIndices, currGate);
        end
        %Plot the different lines based on selected gate
        dplot_hist(j) = dplot(sessionData(currGate, curchan),'colors',ColorMtx);
    end
    %store the app data
    put('dplot_hist',dplot_hist);
    
    %Store the means into the variable
    [meanchannel_gates] = histmean( selectedGates,curchan );
    meanslist{count,1} = char(horzcat(gates{selectedGates,1})); %str2mat
    meanslist{count,2} = char(channelNames{channel});
    meanslist{count,3} = mat2str(meanchannel_gates);
    box on
    
    %Set the labels,title
    set(gca,'ytick',[]);
    set(gca,'yticklabel',{});
    if exist('dists', 'var')
        title(sprintf('%s\ndiff: %g', channelNames{channel}, meanchannel_gates),'FontSize',8,'Interpreter', 'none');
    else
        title(sprintf('%s\nmean intensity: %g', channelNames{channel}, meanchannel_gates),'FontSize',8,'Interpreter', 'none');
        store_channelvalues = retr('store_channelvalues');
        individualmeans = cellfun(@mean,store_channelvalues)';
        dist_means = cellfun(@num2str, num2cell(individualmeans)', 'UniformOutput', false);
        legend(dist_means, 'Interpreter', 'none')
    end
end

%Update variables
put('hist_plot',hist_plot);
put('hist_sub1',hist_sub1);
put('hist_sub2',hist_sub2);
sprintf('Plotted %i points', length(gateContext));
put('meanslist',meanslist);
put('dist_means',dist_means);

end