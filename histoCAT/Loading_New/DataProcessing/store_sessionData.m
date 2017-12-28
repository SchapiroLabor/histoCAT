function store_sessionData(samplefolders,fcsfiles_path,Sample_Set_arranged,Fcs_Interest_all,HashID,Mask_all)
% STORE_SESSIONDATA: Stores sessionData, sessiondata_index, gates, allids
% as GUI data during loading.
%
% GUI updates will be made to the following variables:
% sessionData --> the matrix where all the current analysis data will
% be stored
% sessiondata_index --> the index in the sessionData matrix for each sample
% gates --> every sample in samples-listbox will be update the 'gates' variable.
% allids--> stores Imageids
%
% Input variables:
% samplesfolders --> cell containing file paths to the folders containing
% the individual sample data that are being loaded
% fcsfiles_path --> filepath to fcs files if there were any
% Sample_Set_arranged --> file paths to all samples contained in the session
% Fcs_Interest_all --> single cell data of each sample in the session in fcs format
% HashID --> hashes representing individual image names for all samples in
% session
% Mask_all --> structure containing the masks corresponding to each image in the session
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Samples being loaded
disp(samplefolders')

%Retrieve GUI variables
allids = retr('allids');
sessiondata_index = retr('sessiondata_index');
Tiff_name = retr('Tiff_name');
Tiff_all = retr('Tiff_all');

%Function call to master tiff library to get the tiff names of the
%imageids, in the same order as the other samples
[ tiff_assigned,~,~ ] = MasterTiffNames_Generation(Mask_all,Tiff_name,Tiff_all);

%Find fcs files if there are any
fcsfilesfound_idx = find(~cellfun('isempty',fcsfiles_path));

%If there are fcs files
columnlength = 0;
if isempty(fcsfilesfound_idx) ~= 1
    %Retrieve fcs files if any from the path
    [fcsdats, fcshdrs]=cellfun(@fca_readfcs, fcsfiles_path(fcsfilesfound_idx), 'UniformOutput', false);
    
    %Find out how many 'channels' to be allocated
    columnlength = cellfun(@max,(cellfun(@(x) size(x,2),fcsdats,'UniformOutput',false)));

    %Initialize variable names and store the names as the exact index of fcs
    %files found
    variable_names = {};
    fcshdr_allnames = cellfun(@(f) {f.par.name},fcshdrs,'UniformOutput',false);
    variable_names(fcsfilesfound_idx) = fcshdr_allnames;
end


%Start time
tic
fprintf('Files loaded: %gs',toc);
nfcs = size(fcsfiles_path, 2);

%Initialize waitbar
hWaitbar = waitbar(0,'Allocating space for session data ...');


%Read all data to one huge matrix and define gates according to each filename

%Retrieve current session data matrix
sessionData  = retr('sessionData');

%If this matrix is empty (no session has been started yet)
if isempty(sessionData)
    
    %Initialize session data
    sessionData = zeros(0, columnlength);
    %Retrieve gates information to check if some tiffs are already in the
    %session
    gates = retr('gates');
    %If tiffs were loaded before
    if isempty(gates) ~= 1
        %Store the size of already existing gates
        last_gate_ind = size(gates, 1);
        start = last_gate_ind+1;
    %If no tiffs are already in the session
    else
        %Initialize gates
        gates = cell(nfcs,4);
        last_gate_ind = 0;
        start = 1;
    end
    
    %If we are adding gates that have extra channels (i.e. like after the user
    %has run tSNE)
    if (size(sessionData, 2) < columnlength)
        %Add zeros to samples that don't have these channels
        sessionData(:, end+1:columnlength) = zeros(size(sessionData,1), columnlength - size(sessionData,2));
    end
    
%If sessiondata was filled before
else
    %Get gates info and size
    gates = retr('gates');
    last_gate_ind = size(gates, 1);
    start = last_gate_ind+1;
end

disp(sprintf('Allocated space for data: %gs',toc));


%Time again
tic
waitbar(0, hWaitbar, 'Adding data to session ...')
count = 1;
fcsc = 1;

%Loop through files
for i=start:nfcs+start-1
    
    %If there is fcs info
    if isempty(fcsfiles_path{fcsc}) ~= 1       
        %Get the name of the fcs file
        [~, fcsname, ~] = fileparts(fcsfiles_path{fcsc});
        
        %If the sample was already found in the list box (has been already
        %loaded previously)
        try
            foundname = find(~cellfun('isempty',strfind(gates(:,1),char(fcsname))));
        catch
            %Handle exception if gates was empty before
            foundname = [];
        end
        if isempty(foundname) ~= 1
            disp('Sample already in listbox');
            count = count+1;
            %Continue to next file in loop
            continue;
            
        %If a new fcs file is being loaded
        else
            %Add data to giant sessionData matrix
            currInd = size(sessionData, 1);
            
            %From the index filled+1 to the size of the fcs
            sessionData(currInd+1:currInd+size(fcsdats{count},1), 1:size(fcsdats{count},2)) = fcsdats{count}(:, :);
            
            %Storing the index of each of the fcs files' start and end so that they can be removed later(as part of RemoveGatesCallback)
            sessiondata_index{1,i} = {[currInd+1,currInd+size(fcsdats{count},1)]};
            
            %Get the ImageIds from each of the fcs files added
            total_ids = unique(fcsdats{count}(:,1));
            
            %Check what are the image ids in the fcs file
            if numel(unique(fcsdats{count}(:,1))) > 1
                %Store in allids as a cell array
                allids{1,i} = total_ids';
            else
                allids{1,i} = unique(fcsdats{count}(:,1));
            end
            
            
            %Store into every column of gates the info of fcs
            
            %Name of fcs
            gates{i, 1} = char(fcsname);
            %Indices (rows) of the sample  in the sessionData matrix(also known as the gateContext)
            gates{i, 2} = currInd+1:currInd+size(fcsdats{count},1);
            %Channel names
            gates{i, 3} = variable_names{fcsc};
            %Name of the fcs
            gates{i, 4} = fcsfiles_path{fcsc};
            
            waitbar(i-1/nfcs+start-1, hWaitbar, sprintf('Adding %s data to session  ...', gates{i, 1}));
            count = count+1;
        end
        
    %If the files weren't fcs, then the paths lead to sample folder with tiffs and a mask
    else
        %Get the name of the samplefolder from the samplefolders index
        filename = strsplit(samplefolders{fcsc},filesep);
        
        %In case of a seriesid/sample conflict this would be empty
        if isempty(samplefolders{fcsc}) == 1
            continue;
        end
        
        %Check if sample name already exists in listbox
        %Exception incase gates is empty
        try
            foundname = find(~cellfun('isempty',strfind(gates(:,1),char(filename{end}))));
        catch
            foundname = [];
        end
        if isempty(foundname) ~= 1
            disp('Sample already in listbox');
            %Continue to next file
            continue;
            
        %If it's a new sample to be loaded
        else
            %Store gates information
            
            %Name of tiff
            gates{i, 1} = char(filename{end});
            %Find the hashID index
            hshidx = find(ismember(Sample_Set_arranged,samplefolders{fcsc}));
            %Get the imageid assigned to folder
            imageids = hex2dec(HashID{hshidx});
            %Store the path of the sample
            gates{i, 4} = samplefolders{fcsc};
            %Store the imageid of the tiff in allids
            allids{1,i} = imageids;
            %Check if single cell data exists
            
            if isempty(Fcs_Interest_all{hshidx,1}) ~= 1
                %Add data to giant sessionData matrix
                currInd = size(sessionData, 1);
                fcsdata = table2dataset(Fcs_Interest_all{hshidx,1});
                
                %From the index filled+1 to the size of the fcs
                sessionData(currInd+1:currInd+size(Fcs_Interest_all{hshidx,1},1), 1:size(Fcs_Interest_all{hshidx,1},2)) = double(fcsdata);
                
                %Storing the index of each of the fcs filesstart and end so that they can be removed later(as part of RemoveGatesCallback)
                sessiondata_index{1,i} = {[currInd+1,currInd+size(Fcs_Interest_all{hshidx,1},1)]};
                
                %No sessionData indices,hence store empty
                gates{i, 2} = currInd+1:currInd+size(Fcs_Interest_all{hshidx,1},1);
                
                %Store channel names
                gates{i, 3} = Fcs_Interest_all{hshidx,1}.Properties.VariableNames;

            %If not, store the tiff information
            else
                %No sessionData indices, hence store empty
                gates{i, 2} = [];
                
                %Get the tiff names from the corresponding imageid
                tiffim_files = [tiff_assigned{hshidx,:}];
                
                %Store as channel names for gates column 3
                gates{i, 3} = tiffim_files;
                
                %Store sessionData index as null
                sessiondata_index{1,i} = {[]};
            end
            
        end
        fcsc = fcsc + 1;
    end
end

%Update waitbar
fprintf('Read data into session: %gs',toc);
waitbar(1, hWaitbar, 'Saving ...');

%If any name was not stored, remove the row from gates
if isempty([gates{:}]) ~= 1
    gateempty =  find(cellfun('isempty',gates(:,1)));
    if isempty(gateempty) ~= 1
        gates(gateempty,:) = [];
        allids(gateempty) = [];
        sessiondata_index(gateempty) = [];
    end
end

%Update GUI data
put('sessionData', sessionData);
put('sessiondata_index',sessiondata_index);
put('gates', gates);
put('allids',allids);

close(hWaitbar);

end

