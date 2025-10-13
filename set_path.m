% compile.m creates two folders called compilation_output
% and installer_output. If you call addpath(genpath(pwd)) 
% when these two compilation folders are present, you will
% be adding files from compilation folder with duplicate 
% names as functional counterparts from sourcecode, but these
% files will be non functional. For example if there are two
% put.m, one in sourcecode and one in compiled code, they will
% conflict. Create path using this set_path.m command to add
% files to path while excluding compilation folders.

addpath('histoCAT/3rdParty/')
addpath(genpath_exclude(pwd, {'compilation_output','installer_output'}))
