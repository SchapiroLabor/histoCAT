function mappedX = fast_tsne(X, initial_dims, perplexity, theta)
%FAST_TSNE Runs the (landmark) C++ implementation of t-SNE
%
%   mappedX = fast_tsne(X, initial_dims, perplexity, theta)
%
% Runs the C++ implementation of Barnes-Hut-SNE. The high-dimensional 
% datapoints are specified in the NxD matrix X. The dimensionality of the 
% datapoints is reduced to initial_dims dimensions using PCA (default = 50)
% before t-SNE is performed. Next, t-SNE reduces the points to two 
% dimensions. The perplexity of the input similarities may be specified
% through the perplexity variable (default = 30). The variable theta sets
% the trade-off parameter between speed and accuracy: theta = 0 corresponds
% to standard, slow t-SNE, while theta = 1 makes very crude approximations.
% Appropriate values for theta are between 0.1 and 0.7 (default = 0.5).
% The function returns the two-dimensional data points in mappedX.
%
% NOTE: The function is designed to run on large (N > 5000) data sets. It
% may give poor performance on very small data sets (it is better to use a
% standard t-SNE implementation on such data).


% Copyright (c) 2013, Laurens van der Maaten (Delft University of Technology)
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 1. Redistributions of source code must retain the above copyright
%    notice, this list of conditions and the following disclaimer.
% 2. Redistributions in binary form must reproduce the above copyright
%    notice, this list of conditions and the following disclaimer in the
%    documentation and/or other materials provided with the distribution.
% 3. All advertising materials mentioning features or use of this software
%    must display the following acknowledgement:
%    This product includes software developed by the Delft University of Technology.
% 4. Neither the name of the Delft University of Technology nor the names of 
%    its contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY LAURENS VAN DER MAATEN ''AS IS'' AND ANY EXPRESS
% OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
% OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO 
% EVENT SHALL LAURENS VAN DER MAATEN BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
% BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING 
% IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
% OF SUCH DAMAGE.

    %set_seed if want to reproduce
    rng(2);

    if ~exist('initial_dims', 'var') || isempty(initial_dims)
        initial_dims = 50;
    end
    if ~exist('perplexity', 'var')
        perplexity = 30;
    end
    if ~exist('theta', 'var')
        theta = 0.5;
    end
    
    work_dir = pwd;
    
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    curr_path = [curr_path filesep];
    
    cd(curr_path);
    try
        
        %checking for old tsne results for the same data
        fileCheck= exist ('tsneResults.mat', 'file');
        
        % create or load cache
        if (fileCheck==0) 
            mapMat = containers.Map(); % hash map for matrix name and tsne output
        else
            file= load('tsneResults.mat'); %loading the old tsne results
            mapMat=file.mapMat;
        end

        % getting the  matrix hash
        hashMat= DataHash(X+perplexity+theta); 
        

        % check for has in cache -> no need to run tsne again
        if (isKey(mapMat,hashMat)) 
            
            value=values(mapMat,{hashMat});
            mappedX=value{1};
            
            cd(work_dir); % cd to original directory
            
%             fprintf('\nfast_tsne: cached results found.');
            
            % returning cached result
            return;  
        end
        
        % Perform the initial dimensionality reduction using PCA
        X = double(X);
        X = bsxfun(@minus, X, mean(X, 1));
        covX = X' * X;
        [M, lambda] = eig(covX);
        [~, ind] = sort(diag(lambda), 'descend');
        if initial_dims > size(M, 2)
            initial_dims = size(M, 2);
        end
        M = M(:,ind(1:initial_dims));
        X = X * M;
        clear covX M lambda

        % Run the fast diffusion SNE implementation
        write_data(X, theta, perplexity);
        bh_tsne='';
        %Comment the two lines following this comment and the 
        %corresponding if...else statements if you dont wanna use the 
        %64 bit versions in case they are giving you trouble.
        %In both windows and linux the 64 bit version is abt 2 seconds
        %faster than the corresponding 32 bit version for 6000 datapoints

        arch_str=computer('arch');
        arch=arch_str(length(arch_str)-1:length(arch_str));
        if ismac==1
            bh_tsne='bh_tsne_mac64';
        elseif isunix==1
            if str2double(arch)==64
                bh_tsne='bh_tsne_linux64';
            else
                bh_tsne='bh_tsne_linux32';
            end
        elseif ispc==1
            if str2double(arch)==64
                bh_tsne='bh_tsne_win64';
            else        
                bh_tsne='bh_tsne_win32';
            end
        end
        tic, system([curr_path bh_tsne]); 
        toc
        [mappedX, landmarks, costs] = read_data;   
        landmarks = landmarks + 1;              % correct for Matlab indexing
        delete('data.dat');
        delete('result.dat');

        % while the hash map is too big removing the first element
        % TODO, implement LRU cachce
        if length(mapMat)>5 
            lstKeys= keys(mapMat); 
            remove(mapMat,lstKeys(1));
        end

        % Save results to cache file
        mapMat(hashMat)=mappedX; 
        save('tsneResults.mat','mapMat');
        
        cd(work_dir);
    catch ME
        cd(work_dir);
        rethrow(ME);
    end
end


% Writes the datafile for the fast t-SNE implementation
function write_data(X, theta, perplexity)
    [n, d] = size(X);
    h = fopen('data.dat', 'wb');
	fwrite(h, n, 'integer*4');
	fwrite(h, d, 'integer*4');
    fwrite(h, theta, 'double');
    fwrite(h, perplexity, 'double');
	fwrite(h, X', 'double');
	fclose(h);
end


% Reads the result file from the fast t-SNE implementation
function [X, landmarks, costs] = read_data
    h = fopen('result.dat', 'rb');
	n = fread(h, 1, 'integer*4');
	d = fread(h, 1, 'integer*4');
	X = fread(h, n * d, 'double');
    landmarks = fread(h, n, 'integer*4');
    landmarks = landmarks + 1;
    costs = fread(h, n, 'double');      % this vector contains only zeros
    X = reshape(X, [d n])';
	fclose(h);
end


function Hash = DataHash(Data, Opt)
% DATAHASH - Checksum for Matlab array of any type
% This function creates a hash value for an input of any type. The type and
% dimensions of the input are considered as default, such that UINT8([0,0]) and
% UINT16(0) have different hash values. Nested STRUCTs and CELLs are parsed
% recursively.
%
% Hash = DataHash(Data, Opt)
% INPUT:
%   Data: Array of these built-in types:
%           (U)INT8/16/32/64, SINGLE, DOUBLE, (real or complex)
%           CHAR, LOGICAL, CELL (nested), STRUCT (scalar or array, nested),
%           function_handle.
%   Opt:  Struct to specify the hashing algorithm and the output format.
%         Opt and all its fields are optional.
%         Opt.Method: String, known methods for Java 1.6 (Matlab 2009a):
%              'SHA-1', 'SHA-256', 'SHA-384', 'SHA-512', 'MD2', 'MD5'.
%            Known methods for Java 1.3 (Matlab 6.5):
%              'MD5', 'SHA-1'.
%            Default: 'MD5'.
%         Opt.Format: String specifying the output format:
%            'hex', 'HEX':      Lower/uppercase hexadecimal string.
%            'double', 'uint8': Numerical vector.
%            'base64':          Base64 encoded string, only printable
%                               ASCII characters, 33% shorter than 'hex'.
%            Default: 'hex'.
%         Opt.Input: Type of the input as string, not case-sensitive:
%             'array': The contents, type and size of the input [Data] are
%                      considered  for the creation of the hash. Nested CELLs
%                      and STRUCT arrays are parsed recursively. Empty arrays of
%                      different type reply different hashs.
%             'file':  [Data] is treated as file name and the hash is calculated
%                      for the files contents.
%             'bin':   [Data] is a numerical, LOGICAL or CHAR array. Only the
%                      binary contents of the array is considered, such that
%                      e.g. empty arrays of different type reply the same hash.
%             Default: 'array'.
%
% OUTPUT:
%   Hash: String, DOUBLE or UINT8 vector. The length depends on the hashing
%         method.
%
% EXAMPLES:
% % Default: MD5, hex:
%   DataHash([])                % 7de5637fd217d0e44e0082f4d79b3e73
% % MD5, Base64:
%   Opt.Format = 'base64';
%   Opt.Method = 'MD5';
%   DataHash(int32(1:10), Opt)  % bKdecqzUpOrL4oxzk+cfyg
% % SHA-1, Base64:
%   S.a = uint8([]);
%   S.b = {{1:10}, struct('q', uint64(415))};
%   Opt.Method = 'SHA-1';
%   DataHash(S, Opt)            % ZMe4eUAp0G9TDrvSW0/Qc0gQ9/A
% % SHA-1 of binary values:
%   Opt.Method = 'SHA-1';
%   Opt.Input  = 'bin';
%   DataHash(1:8, Opt)          % 826cf9d3a5d74bbe415e97d4cecf03f445f69225
%
% NOTE:
%   Function handles and user-defined objects cannot be converted uniquely:
%   - The subfunction ConvertFuncHandle uses the built-in function FUNCTIONS,
%     but the replied struct can depend on the Matlab version.
%   - It is tried to convert objects to UINT8 streams in the subfunction
%     ConvertObject. A conversion by STRUCT() might be more appropriate.
%   Adjust these subfunctions on demand.
%
%   MATLAB CHARs have 16 bits! In consequence the string 'hello' is treated as
%   UINT16('hello') for the binary input method.
%
%   DataHash uses James Tursa's smart and fast TYPECASTX, if it is installed:
%     http://www.mathworks.com/matlabcentral/fileexchange/17476
%   As fallback the built-in TYPECAST is used automatically, but for large
%   inputs this can be more than 100 times slower.
%   For Matlab 6.5 installing typecastx is obligatory to run DataHash.
%
% Tested: Matlab 6.5, 7.7, 7.8, 7.13, WinXP/32, Win7/64
% Author: Jan Simon, Heidelberg, (C) 2011-2012 matlab.THISYEAR(a)nMINUSsimon.de
%
% See also: TYPECAST, CAST.
% FEX:
% Michael Kleder, "Compute Hash", no structs and cells:
%   http://www.mathworks.com/matlabcentral/fileexchange/8944
% Tim, "Serialize/Deserialize", converts structs and cells to a byte stream:
%   http://www.mathworks.com/matlabcentral/fileexchange/29457
% Jan Simon, "CalcMD5", MD5 only, faster C-mex, no structs and cells:
%   http://www.mathworks.com/matlabcentral/fileexchange/25921

% $JRev: R-k V:011 Sum:kZG25iszfKbg Date:28-May-2012 12:48:06 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $File: Tools\GLFile\DataHash.m $
% History:
% 001: 01-May-2011 21:52, First version.
% 007: 10-Jun-2011 10:38, [Opt.Input], binary data, complex values considered.
% 011: 26-May-2012 15:57, Fails for binary input and empty data.

% Main function: ===============================================================
% Java is needed:
if ~usejava('jvm')
   error(['JSimon:', mfilename, ':NoJava'], ...
      '*** %s: Java is required.', mfilename);
end

% typecastx creates a shared data copy instead of the deep copy as Matlab's
% TYPECAST - for a [1000x1000] DOUBLE array this is 100 times faster!
persistent usetypecastx
if isempty(usetypecastx)
   usetypecastx = ~isempty(which('typecastx'));  % Run the slow WHICH once only
end

% Default options: -------------------------------------------------------------
Method    = 'MD5';
OutFormat = 'hex';
isFile    = false;
isBin     = false;

% Check number and type of inputs: ---------------------------------------------
nArg = nargin;
if nArg == 2
   if isa(Opt, 'struct') == 0   % Bad type of 2nd input:
      error(['JSimon:', mfilename, ':BadInput2'], ...
         '*** %s: 2nd input [Opt] must be a struct.', mfilename);
   end
   
   % Specify hash algorithm:
   if isfield(Opt, 'Method')
      Method = upper(Opt.Method);
   end
   
   % Specify output format:
   if isfield(Opt, 'Format')
      OutFormat = Opt.Format;
   end
   
   % Check if the Input type is specified - default: 'array':
   if isfield(Opt, 'Input')
      if strcmpi(Opt.Input, 'File')
         isFile = true;
         if ischar(Data) == 0
            error(['JSimon:', mfilename, ':CannotOpen'], ...
               '*** %s: 1st input is not a file name', mfilename);
         end
         
         if exist(Data, 'file') ~= 2
            error(['JSimon:', mfilename, ':FileNotFound'], ...
               '*** %s: File not found: %s.', mfilename, Data);
         end
         
      elseif strncmpi(Opt.Input, 'bin', 3)  % Accept 'binary'
         isBin = true;
         if (isnumeric(Data) || ischar(Data) || islogical(Data)) == 0
            error(['JSimon:', mfilename, ':BadDataType'], ...
               '*** %s: 1st input is not numeric, CHAR or LOGICAL.', mfilename);
         end
      end
   end
   
elseif nArg ~= 1  % Bad number of arguments:
   error(['JSimon:', mfilename, ':BadNInput'], ...
      '*** %s: 1 or 2 inputs required.', mfilename);
end

% Create the engine: -----------------------------------------------------------
try
   Engine = java.security.MessageDigest.getInstance(Method);
catch
   error(['JSimon:', mfilename, ':BadInput2'], ...
      '*** %s: Invalid algorithm: [%s].', mfilename, Method);
end

% Create the hash value: -------------------------------------------------------
if isFile
   % Read the file and calculate the hash:
   FID = fopen(Data, 'r');
   if FID < 0
      error(['JSimon:', mfilename, ':CannotOpen'], ...
         '*** %s: Cannot open file: %s.', mfilename, Data);
   end
   Data = fread(FID, Inf, '*uint8');
   fclose(FID);
   
   Engine.update(Data);
   if usetypecastx
      Hash = typecastx(Engine.digest, 'uint8');
   else
      Hash = typecast(Engine.digest, 'uint8');
   end

elseif isBin             % Contents of an elementary array:
   if isempty(Data)      % Nothing to do, Engine.update fails for empty input!
      Hash = typecastx(Engine.digest, 'uint8');
   elseif usetypecastx   % Faster typecastx:
      if isreal(Data)
         Engine.update(typecastx(Data(:), 'uint8'));
      else
         Engine.update(typecastx(real(Data(:)), 'uint8'));
         Engine.update(typecastx(imag(Data(:)), 'uint8'));
      end
      Hash = typecastx(Engine.digest, 'uint8');
      
   else                  % Matlab's TYPECAST is less elegant:
      if isnumeric(Data)
         if isreal(Data)
            Engine.update(typecast(Data(:), 'uint8'));
         else
            Engine.update(typecast(real(Data(:)), 'uint8'));
            Engine.update(typecast(imag(Data(:)), 'uint8'));
         end
      elseif islogical(Data)               % TYPECAST cannot handle LOGICAL
         Engine.update(typecast(uint8(Data(:)), 'uint8'));
      elseif ischar(Data)                  % TYPECAST cannot handle CHAR
         Engine.update(typecast(uint16(Data(:)), 'uint8'));
         Engine.update(typecast(Data(:), 'uint8'));
      end
      Hash = typecast(Engine.digest, 'uint8');
   end
   
elseif usetypecastx  % Faster typecastx:
   Engine = CoreHash_(Data, Engine);
   Hash   = typecastx(Engine.digest, 'uint8');
   
else                 % Slower built-in TYPECAST:
   Engine = CoreHash(Data, Engine);
   Hash   = typecast(Engine.digest, 'uint8');
end

% Convert hash specific output format: -----------------------------------------
switch OutFormat
   case 'hex'
      Hash = sprintf('%.2x', double(Hash));
   case 'HEX'
      Hash = sprintf('%.2X', double(Hash));
   case 'double'
      Hash = double(reshape(Hash, 1, []));
   case 'uint8'
      Hash = reshape(Hash, 1, []);
   case 'base64'
      Hash = fBase64_enc(double(Hash));
   otherwise
      error(['JSimon:', mfilename, ':BadOutFormat'], ...
         '*** %s: [Opt.Format] must be: HEX, hex, uint8, double, base64.', ...
         mfilename);
end

% return;

end

% ******************************************************************************
function Engine = CoreHash_(Data, Engine)
% This mothod uses the faster typecastx version.

% Consider the type and dimensions of the array to distinguish arrays with the
% same data, but different shape: [0 x 0] and [0 x 1], [1,2] and [1;2],
% DOUBLE(0) and SINGLE([0,0]):
Engine.update([uint8(class(Data)), typecastx(size(Data), 'uint8')]);

if isstruct(Data)                    % Hash for all array elements and fields:
   F      = sort(fieldnames(Data));  % Ignore order of fields
   Engine = CoreHash_(F, Engine);    % Catch the fieldnames
   
   for iS = 1:numel(Data)            % Loop over elements of struct array
      for iField = 1:length(F)       % Loop over fields
         Engine = CoreHash_(Data(iS).(F{iField}), Engine);
      end
   end
   
elseif iscell(Data)                  % Get hash for all cell elements:
   for iS = 1:numel(Data)
      Engine = CoreHash_(Data{iS}, Engine);
   end
      
elseif isnumeric(Data) || islogical(Data) || ischar(Data)
   if isempty(Data) == 0
      if isreal(Data)                % TRUE for LOGICAL and CHAR also:
         Engine.update(typecastx(Data(:), 'uint8'));
      else                           % typecastx accepts complex input:
         Engine.update(typecastx(real(Data(:)), 'uint8'));
         Engine.update(typecastx(imag(Data(:)), 'uint8'));
      end
   end
   
elseif isa(Data, 'function_handle')
   Engine = CoreHash(ConvertFuncHandle(Data), Engine);
   
else  % Most likely this is a user-defined object:
   try
      Engine = CoreHash(ConvertObject(Data), Engine);
   catch
      warning(['JSimon:', mfilename, ':BadDataType'], ...
         ['Type of variable not considered: ', class(Data)]);
   end
end

% return;

end

% ******************************************************************************
function Engine = CoreHash(Data, Engine)
% This methods uses the slower TYPECAST of Matlab
% See CoreHash_ for comments.

Engine.update([uint8(class(Data)), typecast(size(Data), 'uint8')]);

if isstruct(Data)                    % Hash for all array elements and fields:
   F      = sort(fieldnames(Data));  % Ignore order of fields
   Engine = CoreHash(F, Engine);     % Catch the fieldnames
   for iS = 1:numel(Data)            % Loop over elements of struct array
      for iField = 1:length(F)       % Loop over fields
         Engine = CoreHash(Data(iS).(F{iField}), Engine);
      end
   end
elseif iscell(Data)                  % Get hash for all cell elements:
   for iS = 1:numel(Data)
      Engine = CoreHash(Data{iS}, Engine);
   end
elseif isempty(Data)
elseif isnumeric(Data)
   if isreal(Data)
      Engine.update(typecast(Data(:), 'uint8'));
   else
      Engine.update(typecast(real(Data(:)), 'uint8'));
      Engine.update(typecast(imag(Data(:)), 'uint8'));
   end
elseif islogical(Data)               % TYPECAST cannot handle LOGICAL
   Engine.update(typecast(uint8(Data(:)), 'uint8'));
elseif ischar(Data)                  % TYPECAST cannot handle CHAR
   Engine.update(typecast(uint16(Data(:)), 'uint8'));
elseif isa(Data, 'function_handle')
   Engine = CoreHash(ConvertFuncHandle(Data), Engine);
else  % Most likely a user-defined object:
   try
      Engine = CoreHash(ConvertObject(Data), Engine);
   catch
      warning(['JSimon:', mfilename, ':BadDataType'], ...
         ['Type of variable not considered: ', class(Data)]);
   end
end

% return;

end

% ******************************************************************************
function FuncKey = ConvertFuncHandle(FuncH)
%   The subfunction ConvertFuncHandle converts function_handles to a struct
%   using the Matlab function FUNCTIONS. The output of this function changes
%   with the Matlab version, such that DataHash(@sin) replies different hashes
%   under Matlab 6.5 and 2009a.
%   An alternative is using the function name and name of the file for
%   function_handles, but this is not unique for nested or anonymous functions.
%   If the MATLABROOT is removed from the file's path, at least the hash of
%   Matlab's toolbox functions is (usually!) not influenced by the version.
%   Finally I'm in doubt if there is a unique method to hash function handles.
%   Please adjust the subfunction ConvertFuncHandles to your needs.

% The Matlab version influences the conversion by FUNCTIONS:
% 1. The format of the struct replied FUNCTIONS is not fixed,
% 2. The full paths of toolbox function e.g. for @mean differ.
FuncKey = functions(FuncH);

% ALTERNATIVE: Use name and path. The <matlabroot> part of the toolbox functions
% is replaced such that the hash for @mean does not depend on the Matlab
% version.
% Drawbacks: Anonymous functions, nested functions...
% funcStruct = functions(FuncH);
% funcfile   = strrep(funcStruct.file, matlabroot, '<MATLAB>');
% FuncKey    = uint8([funcStruct.function, ' ', funcfile]);

% Finally I'm afraid there is no unique method to get a hash for a function
% handle. Please adjust this conversion to your needs.

% return;

end

% ******************************************************************************
function DataBin = ConvertObject(DataObj)
% Convert a user-defined object to a binary stream. There cannot be a unique
% solution, so this part is left for the user...

% Perhaps a direct conversion is implemented:
DataBin = uint8(DataObj);

% Or perhaps this is better:
% DataBin = struct(DataObj);

% return;

end

% ******************************************************************************
function Out = fBase64_enc(In)
% Encode numeric vector of UINT8 values to base64 string.

Pool = [65:90, 97:122, 48:57, 43, 47];  % [0:9, a:z, A:Z, +, /]
v8   = [128; 64; 32; 16; 8; 4; 2; 1];
v6   = [32, 16, 8, 4, 2, 1];

In  = reshape(In, 1, []);
X   = rem(floor(In(ones(8, 1), :) ./ v8(:, ones(length(In), 1))), 2);
Y   = reshape([X(:); zeros(6 - rem(numel(X), 6), 1)], 6, []);
Out = char(Pool(1 + v6 * Y));

% return;

end