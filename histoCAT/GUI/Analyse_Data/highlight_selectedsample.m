function [ lightup_sample ] = highlight_selectedsample(current_axes)
% HIGHLIGHT_SELECTEDSAMPLE: Highlight the selected sample on any scatter plot.
%
% Input: 
% current_axes --> current scatter plot
% 
% Output: 
% lightup_sample --> locations to be highlighted in scatter plot
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH


%Get GUI handles
handles = gethand;

%Retrieve GUI variables
selected_gates = get(handles.list_samples,'Value');
sessionData = retr('sessionData');
sessiondata_index = retr('sessiondata_index');
nCH1 = retr('nCH1');
nCH2 = retr('nCH2');
nCH3 = retr('nCH3');
lightup_sample = retr('lightup_sample');
commonlight = retr('commonlight');
gates = retr('gates');

%Already used colors
colorsalreadyused = [[0 0 1];[0 1 1]];

%Store the distinguishable colormap based on the number of selected gates
colorstouse = distinguishable_colors(numel(selected_gates)+1,colorsalreadyused);

%Clear previous highlights before highlighting again
if isempty(lightup_sample) ~= 1
    delete([lightup_sample{:}]);
    put('lightup_sample',[]);
    lightup_sample = {};
end

%Clear previous common cells highlights before highlighting again
if isempty(commonlight) ~= 1
    delete(commonlight);
    commonlight = [];
    put('commonlight',commonlight);
end

%Initialize count for higlight colors
colorcount = 0;
gatenum = [];
litgate = {};

%Loop through selected gates to be highlighted
for lns= selected_gates
    
    %Increment colorcount in case of multiple gates to be highlighted
    colorcount = colorcount + 1;
    
    %Handle exception
    try
        %Initialize empty cell entry
        litgate{1,colorcount} = [];
        
        %Store the selected gate number
        gatenum = [gatenum lns];
        
        %Get the respective single cell information of the plot (nCH1,nCH2 -> selected channels) from the
        %currently selected gate
        litgate{1,colorcount} = sessionData(sessiondata_index{lns}{1}(1):sessiondata_index{lns}{1}(2),[1 2 nCH1 nCH2]);
        
        %Check if a third parameter is selected (nCH3 -> 3D plot)
        if nCH3 ~= 0
            litgate{1,colorcount} = [litgate{1,colorcount} sessionData(sessiondata_index{lns}{1}(1):sessiondata_index{lns}{1}(2),nCH3)];
        end
        
        %If single cell info of currently selected gate was not found in plot, then search entire sessionData
        if isempty(litgate{1,colorcount}) == 1
            
            %Check if the first two rows are found in the sessionData, if
            %yes get the corresponding indices of the rows
            lightindex_found = find(ismember(sessionData(:,1:2),sessionData(sessiondata_index{lns}{1}(1):sessiondata_index{lns}{1}(2),1:2),'rows'));
            
            %Store the corresponding single cell information of the
            %selected channels
            litgate{1,colorcount}   = sessionData(lightindex_found(find(sessionData(lightindex_found,nCH1))),[1 2 nCH1 nCH2]);
            
            %If three channels are selected (3D plot), concatenate the additional column in litgate
            if nCH3 ~= 0
                litgate{1,colorcount} = [litgate{1,colorcount} sessionData(lightindex_found(find(sessionData(lightindex_found,nCH3))),nCH3)];
            end
        end
        
        %Catch exception
    catch
        uiwait(msgbox('The cells of the selected gate are not in any of the samples'));
    end
    
    %Focus GUI on the current scatter plot axes
    axes(current_axes);
    hold on;
    
    %In case a third channel was selected, highlight on 3D plot
    if size(litgate{1,colorcount},2) == 5
        
        %Highlight the cells found from channels X Y Z as a 3D scatter plot
        %Use the colors from the stored, distinguishable colorstouse variable loopwise
        lightup_sample{colorcount} = scatter3(litgate{1,colorcount}(:,3),litgate{1,colorcount}(:,4),litgate{1,colorcount}(:,5),80,colorstouse(colorcount,:),'o','filled');
        hold on;
        
    %In case no third channel was selected, highlight on 2D plot
    else
        
        %Highlight the cells found from channels X Y as a 2D scatter plot
        %Use the colors from the stored, distinguishable colorstouse variable loopwise
        lightup_sample{colorcount} = scatter(litgate{1,colorcount}(:,3),litgate{1,colorcount}(:,4),80,colorstouse(colorcount,:),'o','filled');
        hold on;
        
    end
    
    %Update the highlighted scatter plot as GUI variable
    put('lightup_sample',lightup_sample);
    
%End of For loop for selected gates
end


%Initialize allcells
allcells = zeros(size(vertcat(litgate{:}),1),5);

%Store the litgate (highlighted single cell info) in allcells index
allcells(1:size(vertcat(litgate{:}),1),1:size(vertcat(litgate{:}),2)) = vertcat(litgate{:});

%If the number of gates is greater than 1, then show the common cells of
%the two gates in a separate color and set plot legend to corresponding
%gates/common cells
if numel(selected_gates) > 1
    
    %Get the unique rows only and their indices
    [~,idxofuniquevalues,~] = unique(allcells(:,1:2),'rows');
    
    %The other indices apart from the unique are the repeats/duplicates
    idxoflightup = [1:size(allcells,1)]';
    idxofduplicates = find(~ismember(idxoflightup,idxofuniquevalues));
    
    %Focus axes
    axes(current_axes);
    hold on;
    
    %If no duplicates were found
    if isempty(idxofduplicates) == 1
        
        disp('No common cells found, all samples are unique');
        
        %Store empty common cells highlight
        commonlight = [];
        put('commonlight',commonlight);
        
        %Set plot legend of highlights
        plotlegend=legend([lightup_sample{:}],cellfun(@(n)(num2str(n)),gates(gatenum,1), 'UniformOutput', false));
        set(plotlegend, 'DefaulttextInterpreter', 'none');
        
    %If there are duplicates
    else
        
        %Store the common cells
        common_cells = allcells(idxofduplicates,:);
        
        %Check if 3D values are not 0
        fndzeros = find(common_cells(:,end) ~= 0);
        
        %Increment the color assignment by one for the common cells
        colorcount = colorcount + 1;
        
        %If it is not a 3D plot
        if isempty(fndzeros) == 1
            
            %Highlight common cells in a separate color
            commonlight = scatter(common_cells(:,3),common_cells(:,4),80,colorstouse(colorcount,:),'o','filled');
            
        %In case of 3D plot
        else
            
            %Highlight common cells in a separate color
            commonlight = scatter3(common_cells(:,3),common_cells(:,4),common_cells(:,5),80,colorstouse(colorcount,:),'o','filled');
            
        end
        
        %Keep focus on axes
        hold on;
        
        %Update GUI variable of commonly highlighted cells
        put('commonlight',commonlight);
        
        %Set the plot legend of the highlights
        plotlegend=legend([lightup_sample{:} commonlight],cellfun(@(n)(num2str(n)),[gates(gatenum,1);{'CommonCells'}], 'UniformOutput', false));
        set(plotlegend, 'DefaulttextInterpreter', 'none');
        
    end
    
    %Set the location and size of the legend
    if numel(selected_gates) > 6
        set(plotlegend,'Location','NorthEastOutside');
    else
        set(plotlegend,'Location','NorthEast');
    end
    set(plotlegend,'FontSize',7.5);
    
end


end
