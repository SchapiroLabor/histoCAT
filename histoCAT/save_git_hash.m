function save_git_hash()
%SAVE_GIT_HASH Retrieves the Git commit hash and saves it to a file.
%   histoCAT_version = SAVE_GIT_HASH(base_version) attempts to get the
%   Git commit hash. If successful, it combines it with base_version
%   and saves the full version string to 'get_git_hash.m'.
%   If the Git command fails, it throws an error.

    % Get the first seven characters of the current commit hash
    [status, cmdout] = system('git rev-parse HEAD');

    if status == 0 % Command executed successfully
        commit_hash = strtrim(cmdout); % Remove any leading/trailing whitespace

        % Create/overwrite 'get_git_hash.m' with the hardcoded version
        fid = fopen('histoCAT/get_git_hash.m', 'wt'); % Open for writing, discard existing content
        if fid == -1
            error('save_git_hash:FileWriteError', 'Could not open get_git_hash.m for writing.');
        end

        fprintf(fid, 'function git_hash = get_git_hash()\n');
        fprintf(fid, '%%GET_GIT_HASH Returns the git hash that was saved during compilation.\n');
        fprintf(fid, 'git_hash = ''%s'';\n', commit_hash);
        fprintf(fid, 'end\n');

        fclose(fid);
        fprintf('Successfully saved Git hash "%s" to get_git_hash.m\n', commit_hash);

    else
        % Throw an error if Git command fails
        error('save_git_hash:GitCommandFailed', ...
              'Git command failed. Output: "%s". Please ensure Git is installed and you are in a Git repository.', cmdout);
    end
end