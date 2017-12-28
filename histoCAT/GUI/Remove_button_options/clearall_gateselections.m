function clearall_gateselections
% CLEARALL_GATESELECTION: Clears all gated selections of cells on the image
% or plot
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve selections
add_selections = retr('add_selections');

%If there was a selection, delete it
if isempty(add_selections) ~= 1
    for j = 1:length(add_selections);
        delete(add_selections{j});
    end
    clear add_selections;
else
    uiwait(msgbox('Nothing to clear'));
end