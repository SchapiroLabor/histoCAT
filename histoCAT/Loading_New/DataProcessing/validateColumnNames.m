function validateColumnNames(columnNames)
%VALIDATECOLUMNNAMES Checks if all the provided column names contain only letters and underscores.
%   validateColumnNames(columnNames) throws an error if any string in the
%   input cell array 'columnNames' contains characters other than
%   alphabetic letters (a-z, A-Z) or underscores.

if ~iscellstr(columnNames)
    error('Input must be a cell array of strings.');
end

% Regular expression to match any character that is NOT a letter or an underscore.
% '[^a-zA-Z_]' means 'not a letter and not an underscore'.
invalidCharPattern = '[^a-zA-Z_0-9]';

for i = 1:numel(columnNames)
    currentName = columnNames{i};

    % Check if the current name contains any invalid characters
    if regexp(currentName, invalidCharPattern, 'once')
        % If regexp finds a match, it returns a non-empty value (e.g., the starting index).
        % 'once' ensures it stops after the first match for efficiency.
        error('InvalidColumnName:IllegalCharacters', ...
              'File name "%s" contains characters other than letters, numbers, or underscores. Please change the tiff filenames to only contain allowed characters.', currentName);
    end
end

% If the loop completes without throwing an error, all names are valid.
fprintf('All column names conform to the letters and underscore constraint.\n');

end