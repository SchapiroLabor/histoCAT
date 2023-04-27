function a = struct2array(s)
%STRUCT2ARRAY Convert structure with doubles to an array.

%   Author(s): R. Losada
%   Copyright 1988-2013 The MathWorks, Inc.

narginchk(1,1);

% Convert structure to cell
c = struct2cell(s);

% Construct an array
a = [c{:}];

