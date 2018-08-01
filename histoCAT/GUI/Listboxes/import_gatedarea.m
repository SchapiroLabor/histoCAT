function import_gatedarea( gatedfile )
% IMPORT_GATEDAREA: Reads and saves the data of the gated area fcs-file.
%
% Input: gatedfile --> path to fcs-file of the gated area
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%Retrieve variables
allids = retr('allids');
gates = retr('gates');
sessiondata_index = retr('sessiondata_index');

%Store file path in a cell. This is then added to allids cellarray len_allids+1.
files = {gatedfile};

if isequal(files,0) ~=0
    return 
end

%Start timing
tic

%Separate path from file name and file extension
[path, filename, ext] = fileparts(files{1});

%Store path
put('currentfolder_gated', [path filesep]);

%Check that file is and fcs-file
if strcmp(ext,'.fcs') == 1
    
    %Read fcs-files
    [fcsdats_raw,fcshdrs_raw]=cellfun(@fca_readfcs_J, files, 'UniformOutput', false);
    disp(sprintf('File loaded: %gs',toc));
    
    %Include amount of cells present in the fcs file into the matrix
    fcsdats = fcsdats_raw;
    fcsdats{:}(:,end+1) = size(fcsdats_raw{:},1);
    
    %Include name for amount of cell present in the fcs file
    fcshdrs = fcshdrs_raw;
    fcshdrs{1,1}.NumOfPar = size(fcsdats_raw{:},1);
    fcshdrs{1,1}.par(end+1).name = 'Amount_cells_in_sample';  
    fcshdrs{1,1}.par(end).name2 = 'Amount_cells_in_sample';
    
    %Start timing
    tic
    
    %Find out how many channels to allocated
    y = 0;
    nfcs = size(fcsdats, 2);
    hWaitbar = waitbar(0,'Allocating space for session data ...');
    for i=1:nfcs
        waitbar(i/nfcs, hWaitbar);
        y = max([y size(fcsdats{i}, 2)]);
    end

    %Allocate space in order to read all data to one huge matrix and 
    %define gates according to each filename.
    %If there is already a sessionData, append to it.
    sessionData  = retr('sessionData');
    if isempty(sessionData) 
        sessionData = zeros(0, y);
        last_gate_ind = 0;
    else 
        last_gate_ind = size(gates, 1);
        %If we're adding gates that have extra channels. E.g. after the
        %user ran tSNE.
        if (size(sessionData, 2)< y) 
            sessionData(:, end+1:y) = zeros(size(sessionData,1), y - size(sessionData,2));
        end
    end
    
    %End timing and print used time
    disp(sprintf('Allocated space for data: %gs',toc));

    %Adding data to matrix
    waitbar(0, hWaitbar, 'Adding data to session ...')
    
    %Loop through each file being added to the session
    for i=1:nfcs
        
        %Add data to giant matrix
        currInd = size(sessionData, 1);
        sessionData(currInd+1:currInd+size(fcsdats{i},1), 1:size(fcsdats{i},2)) = fcsdats{i}(:, :);
        sessiondata_index{1,last_gate_ind+i} = {[currInd+1,currInd+size(fcsdats{i},1)]};
        
        %Update allids
        total_ids = unique(fcsdats{i}(:,1));
        if numel(unique(fcsdats{i}(:,1))) > 1
              allids{1,last_gate_ind+i} = [total_ids'];
        else
              allids{1,last_gate_ind+i} = [unique(fcsdats{i}(:,1))];
        end
        
        %Save file names as gate names and store all necessary information 
        %corresponding to each gate
        [~, fcsname, ~] = fileparts(files{i});
        gates{last_gate_ind+i, 1} = char(fcsname);
        gates{last_gate_ind+i, 2} = currInd+1:currInd+size(fcsdats{i},1);     
        gates{last_gate_ind+i, 3} = get_channelnames_from_header(fcshdrs{i});        
        gates{last_gate_ind+i, 4} = files{i};
        waitbar(i-1/nfcs, hWaitbar, sprintf('Adding %s data to session  ...', gates{last_gate_ind+i, 1}));
        
    end

%If the file is a mat-file
elseif strcmp(ext,'.mat') == 1

    %Read in mat-file and store in matrix
    matfileread = importdata(files{1});
    matarray = table2array(matfileread);

    %Start timing 
    tic
    y = 0;
    y = max([y size(matarray, 2)]);
    hWaitbar = waitbar(0,'Allocating space for session data ...');
    
    %Allocate space in order to read all data to one huge matrix and 
    %define gates according to each filename.
    %If there is already a sessionData, append to it.
    sessionData  = retr('sessionData');
    if (isempty(sessionData)) 
        sessionData = zeros(0, y);
        last_gate_ind = 0;
    else 
        last_gate_ind = size(gates, 1);
        %If we're adding gates that have extra channels. E.g. after the
        %user ran tSNE.
        if (size(sessionData, 2)< y) 
            sessionData(:, end+1:y) = zeros(size(sessionData,1), y - size(sessionData,2));
        end
    end
    %Stop timing and display used time
    disp(sprintf('Allocated space for data: %gs',toc));

    %Add data to matrix
    waitbar(0, hWaitbar, 'Adding data to session ...')
    currInd = size(sessionData, 1);
    sessionData(currInd+1:currInd+size(matarray,1), 1:size(matarray,2)) = matarray;
    sessiondata_index{1,last_gate_ind+1} = {[currInd+1,currInd+size(matarray,1)]};
    
    %Update allids
    total_ids = unique(matarray(:,1));
    if numel(total_ids) > 1
          allids{1,last_gate_ind+1} = [total_ids'];
    else
          allids{1,last_gate_ind+1} = [total_ids];
    end

    %Save file names as gate names and store the rest of the necessary
    %information for eah gate
    gates{last_gate_ind+1, 1} = char(filename);
    gates{last_gate_ind+1, 2} = currInd+1:currInd+size(matarray,1);     
    gates{last_gate_ind+1, 3} = matfileread.Properties.VariableNames;        
    gates{last_gate_ind+1, 4} = files{1}; % opt cell column to hold filename
    waitbar(0.5, hWaitbar, sprintf('Adding %s data to session  ...', gates{last_gate_ind+1, 1}));
end

disp(sprintf('Read data into session: %gs',toc));
waitbar(1, hWaitbar, 'Saving ...');

%Save the sessionData matrix and gates
put('sessionData', sessionData);
put('gates', gates);
put('allids',allids);
put('sessiondata_index',sessiondata_index);

%Update GUI
[names_add]=gates(:,1);
set(handles.list_samples,'String',names_add);
Scatter = 0;
put('Scatter',Scatter);

%Call function to update list boxes and store sample and channels data.
list_samples_Callback;
close(hWaitbar); 
end

