function [sel_channels,tiff_matrix] = Comparetiffnames_tolistchannels(Mask_all)
% COMPARETIFFNAMES_TOLISTCHANNELS: This function finds the correct tiffs corresponding 
% to the selected channels and stores the corresponding tiff matrices. It is used
% for RGBCMY visualizations.
%
% Input:
% Mask_all --> segmentation masks of all samples (matrices)
%
% Output:
% sel_channels --> currently selected channels
% tiff_matrix --> tiffs corresponding to the currently selected channels
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%Retrieve variables
sample_orderIDX = retr('sample_orderIDX');
Tiff_name = retr('Tiff_name');
Tiff_all = retr('Tiff_all');
imageids = retr('imageids');
gates = retr('gates');
selected_gates = get(handles.list_samples,'value');

%Initialize
tiff_matrix = [];

%Function call to the 'library' to get the tiffs of the session in order
[ tiff_assigned,~,cell_name ] = MasterTiffNames_Generation(Mask_all,Tiff_name,Tiff_all);

%Find the indices of the samples containing single-cell information (a
%segmentation mask)
idx_cel = find(~cellfun('isempty',struct2cell(Mask_all)));

%If there are samples with single-cell information
if isempty(idx_cel) ~= 1
    
    %Extract all channel names
    allvarnames = unique([cell_name{idx_cel}],'stable');
    
    %Remove special characters from channel names
    removesplcharacters = regexprep(allvarnames,'[^a-zA-Z0-9_]','');
    remove_beginnum_varnames = regexprep(removesplcharacters,'^[0-9]*','');
    
end

%Get all the channel names listed in the list_channels listbox
getallchannels = retr('list_channels');

%Retrieve the order in which RGBCMY channels were selected
valchannel = retr('valchannel');
if size(valchannel,1) > 1
    valchannel = valchannel';
end

%If valchannel is empty, there was no RGBCMY selection
if isempty(valchannel) == 1    
    
    %Retrieve the currently selected channel(s) for the channels listbox
    sel_channels = get(handles.list_channels,'Value');
else
    
    %Use the selected channels from the RGBCMY selection
    sel_channels = [valchannel];
end

%Get the idx of the channels (columns in sessionData) starting with Cell_ 
%(these correspond to the measured channels that containe tiffs, i.e. not 
%the CellID column)
cell_idx = find(~cellfun('isempty',regexp(getallchannels,'(^Cell_)')));

if isempty(cell_idx) == 1
    chan_idx = [];
else
    %Compensating for ImageId and CellId (the first two columns)
    chan_idx = sel_channels - 2;
    loopidx = chan_idx;
end

%If any sample other than 'None' is selected from the list_visual listbox, work 
%with this sample, else get the selected samples from the samples listbox
if unique(get(handles.list_visual,'Value') > 1) == 1
    selectedsample_tiff = get(handles.list_visual,'Value') - 1;
    imageids   = imageids(selectedsample_tiff);
    sample_orderIDX = sample_orderIDX(selectedsample_tiff);
end

%If no channels starting with 'Cell_' were found, search for channels
%containing tiffs
if isempty(chan_idx) == 1
    allvarnames = [];
    loopidx = sel_channels;
end

if isempty(loopidx) ~= 1
    
    %Loop through the selected imageids
    for sg = 1:length(imageids)
        
        %Initialize count
        count = 1;
        
        %Store idx
        id = sample_orderIDX(sg);
        
        %Loop through every selected channel for the current imageID
        for ch = loopidx
            
            %Find idx which is not empty in Tiff_name for the current id
            idx_nempty = find(~cellfun('isempty',Tiff_name(id,:)));
            
            try
                %Check which channel name from the listbox is a member of the
                %allvarnames
                if isempty(chan_idx) == 1
                    varname_idx = find(ismember(remove_beginnum_varnames,getallchannels(ch)));%%remove_beginnum_varnames
                else
                    varname_idx = find(ismember(remove_beginnum_varnames,getallchannels(ch+2)));%%remove_beginnum_varnames
                end
                
                %Check which idx of cellname is equal to this channel in
                %the listbox
                idx_cellname = find(ismember(cell_name{id,1},allvarnames(varname_idx)));
            catch
                idx_cellname = find(ismember(gates{selected_gates(1),3},getallchannels{ch}));
            end
            
            %To display
            try 
                %Find which string is a member of the current channel in loop
                char(tiff_assigned{id,1}{idx_cellname})
                tiffchan_idx = find(~cellfun('isempty',strfind([Tiff_name{id,idx_nempty}],char(tiff_assigned{id,1}{idx_cellname}))));
                
                %Store in matrix
                tiff_matrix{sg}{count} = Tiff_all{id,idx_nempty(tiffchan_idx)};
                count = count+1;
            catch
                
                %Spatial channel do not contain tiffs
                msgbox('Please use the Heatmap channel on selected samples to view spatial channels');
                return;
            end
        end
    end
else
    tiff_matrix = [];
end

end


