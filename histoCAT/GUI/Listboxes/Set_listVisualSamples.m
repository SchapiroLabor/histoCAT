function Set_listVisualSamples( handles,allids,selected_gates,Sample_Set_arranged,HashID )
% SET_LISTVISUALSAMPLES: Executed when visualize option is set. Displays
% the source images from which a gate's cells stem, if the currently 
% selected gate's cells are from multiple images. Updates the list_visual 
% box(subsamples/source_images list).
%
% Input:
% handles --> GUI handles
% allids --> contains a list of the unique imageIDs (first column of sessionData)
% for each gate in the session
% selected_gates --> gates from list_samples box that have been selected by
% user
% Sample_Set_arrange --> file paths to all samples in session in the order
% they appear in GUI
% HashID --> hashes of all image names representing the imageIDs in the
% first column of sessionData (same order as Sample_Set_arranged)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Check which selected gates contain cells from more than just one imageid
foundlengthgrt = find(cellfun('length',allids([selected_gates])) > 1);

%If any are found
if isempty(foundlengthgrt) ~= 1
    
    %Get their original imageids and gate names
    [  ~, gate_names_pre, ~ ,~] = getimageids_of_selectedgates(Sample_Set_arranged,HashID,selected_gates(foundlengthgrt), allids);
    
    %Find idexes of unique ones
    [~, idxs, ~] = unique(gate_names_pre);
    
    %Store in the list_visual listbox (subsample list)
    set(handles.list_visual,'String',['None' gate_names_pre(sort(idxs))]);
    
    %Allow only upto 10 selections simultaneously
    set(handles.list_visual,'Min',1,'Max',10);
    set(handles.list_visual,'Value',1);
    
%If the cells of the selected gates only came from the one imageID each
%(the imageID of that gate)
else
    
    %Set list_visual box to null string
    set(handles.list_visual,'String','');
    set(handles.list_visual,'Value',1);   
    
end

end

