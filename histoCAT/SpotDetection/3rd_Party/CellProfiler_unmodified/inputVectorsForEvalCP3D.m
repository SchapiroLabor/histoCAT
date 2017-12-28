function [bnIsAllowed evalStr] = inputVectorsForEvalCP3D(Str,varargin)
% - Formats CP input such that it can be used to make a vector;
% - Ensures that input does not contain potentially harmful code
% [bnIsAllowed evalStr] = inputVectorsForEvalCP3D(Str,varargin)
% checks string, which should be eval'ed, for absence of characters of
% whitelist. optional second input argument can be TRUE/FALSE to indicate
% whether NaN should be allowed - default is FALSE.
%
% BNISALLOWED is TRUE or FALSE and indicates whether string is allowed
% EVALSTRING is (reformatted> add [ and ]) STR to evaluate. In case of non
% allowed STR, EVALSTRING will be empty
%
% Authors:
%   Nico Battich
%   Thomas Stoeger
%   Lucas Pelkmans
%
% Battich et al., 2013.
% Website: http://www.imls.uzh.ch/research/pelkmans.html
% *************************************************************************

switch nargin
    case 1
        bnAllowNaN = false;
        bnOutputBrackets = true;
    case 2
        bnAllowNaN = varargin{1};
        bnOutputBrackets = true;
    case 3
        bnAllowNaN = varargin{1};
        bnOutputBrackets = varargin{2};
    otherwise
        error('Number of input arguments not correct');
end

allowedChar = ismember(Str,'0123456789.,:[] ');
if bnAllowNaN == true;
    NaNStart = strfind(Str,'NaN');
    if any(NaNStart)
        allowedChar(NaNStart)= true;
        allowedChar(NaNStart+1)= true;
        allowedChar(NaNStart+2)= true;
    end
end

if any(~allowedChar) == true
    bnIsAllowed = false;
    evalStr = [];           % report empty string to eval so that bad code does not get accidentally eval'ed
else
    bnIsAllowed = true;
    evalStr = Str;
    if bnOutputBrackets == true
        if evalStr(1) ~= '['         % reformat: add square brackets
            evalStr = ['[' evalStr];
        end
        if evalStr(end) ~= ']'
            evalStr = [evalStr ']'];
        end
    end
end

end