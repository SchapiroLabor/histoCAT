function histoCAT_version = get_histoCAT_version()
    base_version = '1.78';
    
    % Get the first seven characters of the current commit hash
    [status, cmdout] = system('git rev-parse --short HEAD');
    
    if status == 0 % Command executed successfully
        commit_hash_short = strtrim(cmdout); % Remove any leading/trailing whitespace
        histoCAT_version = [base_version, '.', commit_hash_short];
    else
        % Handle case where Git is not found or command fails
        warning('Git command failed or not found. Using base version only.');
        histoCAT_version = base_version;
    end
end