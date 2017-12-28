function removegates_commonfunction(remGates)
% REMOVEGATES_COMMONFUNCTION: Updates all involved variables during gate removal
%
% Input:
% remGates --> indices of gates to be removed
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve GUI Variables
gates = retr('gates');
allids = retr('allids');
sessionData = retr('sessionData');
sessiondata_index = retr('sessiondata_index');

%Remove the selected gates from gates and allids variables
gates(remGates, :) = [];
allids(:,remGates) = [];
allids(cellfun(@isempty,allids)) = [];
sessiondata_index(remGates) = [];

%Use the sessiondata_index to clear the data of the removed gates also from
%sessionData:

%Initialize new variables
newdata = [];

%Loop through sessiondata_index
for numidx = 1:numel(sessiondata_index)
    
    %If current index is empty, continue to next
    if isempty(sessiondata_index{numidx}{:}) == 1
        continue;
    end
    
    %Get the current index and add the corresponding data to newdata
    currInd = size(newdata,1);
    data = sessionData(sessiondata_index{numidx}{1}(1):sessiondata_index{numidx}{1}(2),:);
    newdata = vertcat(newdata,sessionData(sessiondata_index{numidx}{1}(1):sessiondata_index{numidx}{1}(2),:));
    
    %Updating session_index
    session_index{1,numidx} = {[currInd+1,currInd+size(data,1)]};
    
    %Updating gate indices
    gates{numidx,2} = currInd+1:currInd+size(data,1);
end

try
    if isempty(session_index) == 1
        session_index = [];
    end
catch
    session_index = [];
end

%Update GUI variables
put('sessionData',newdata);
put('sessiondata_index',session_index);
put('gates', gates);
put('allids',allids);

end

