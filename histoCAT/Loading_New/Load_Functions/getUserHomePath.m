function UserHomePath = getUserHomePath()
%getUserHomePath Retrieves the operating system's user home directory.
%   osUserHomePath = GETOSUSERHOME() returns the path to the current
%   user's home directory on the operating system.
%
%   This function works cross-platform (Windows, macOS, Linux).
%
%   Output:
%     osUserHomePath - A string containing the operating system's user home directory path.
%
%   Example:
%     userHome = getOsUserHome();
%     disp(['Your OS Home Directory: ', userHome]);
%
%   See also GETENV, ISPC.

if ispc % On Windows
    UserHomePath = getenv('USERPROFILE');
else % On Linux or macOS
    UserHomePath = getenv('HOME');
end

end