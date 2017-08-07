function ExportCSV_singlecells( hObject, eventdata, handles )
% EXPORTCSV_SINGLECELLS: Exports the single cell data (including the 
% neighbors) of the selected gates as CSV (in fcs format) and stores them 
% in custom gates folder
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve Variables
handles = gethand;
gates = retr('gates');
selected_gates = get(handles.list_samples,'Value');
custom_gatesfolder = retr('custom_gatesfolder');
global Fcs_Interest_all
global Sample_Set_arranged

%Split the file paths of all gates and get the sample names
[~,names] = cellfun(@fileparts,Sample_Set_arranged,'UniformOutput',false);

disp(['All selected gates/samples will be exported as .csv files to ',fullfile(custom_gatesfolder)]);

%Loop through the selected gates
for sg = selected_gates
    
    %Check if sample is present as fcs file
    checkif_fcs = strfind(gates{sg,4},'.fcs');

    %Get the name of the current sample
    [~,name,~] = fileparts(gates{sg,4});
    
    %Check if CSV file of sample already exists in the custom gates folder
    if exist(fullfile(custom_gatesfolder,strcat(gates{sg},'.csv'))) || exist(fullfile(custom_gatesfolder,strcat(name,'.csv')))
        disp(['Sample already exported ',gates{sg,1}]);
        continue;
    end
    
    %If sample is not already fcs file
    if isempty(checkif_fcs) == 1

        %Get the index of the current sample in the entire sample set
        [~,fnd] = ismember(gates{sg,1},names);
          
        if isempty(Fcs_Interest_all{fnd})
            %If the user is tryin to export a tiff sample without single
            %cell information
            disp(['Cannot export tiff without single cell information as csv: ',gates{sg,1}]);
            continue;
        end
        
        %Get the fcs format data from FCS_Interest_all and save as csv to
        %custom gates folder
        writetable(Fcs_Interest_all{fnd},fullfile(custom_gatesfolder,strcat(gates{sg},'.csv')));
        
    %If the sample is an fcs file, read it, store the contents and write the
    %csv
    else
        [fcsdata,fcshdrs]  = fca_readfcs_J(gates{sg,4});
        variables = {fcshdrs.par.name};
        fcstable = array2table(fcsdata,'VariableNames',variables);
        writetable(fcstable,fullfile(custom_gatesfolder,strcat(name,'.csv')));
    end
end
    
end

