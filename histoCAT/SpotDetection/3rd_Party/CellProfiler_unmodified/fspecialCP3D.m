function H = fspecialCP3D(varargin)
%FSPECIALCP3D Create predefined 2-D and 3-D filters.
%   H = FSPECIALCP3D(TYPE) creates a two-dimensional or three-dimensional
%   filter H of the specified type. Possible values for TYPE are:
%
%     '2D LoG'      2D Laplacian of Gaussian filter
%     '3D LoG, Raj' 3D Laplacian of Gaussian filter, according to Raj et
%     al. 2008
%
%   H = FSPECIALCP3D('2D LoG',HSIZE,SIGMA) returns a rotationally symmetric
%   Laplacian of Gaussian filter of size HSIZE with standard deviation
%   SIGMA (positive). HSIZE can be a vector specifying the number of rows
%   and columns in H or a scalar, in which case H is a square matrix.
%   The default HSIZE is [5 5]. SIGMA's default is HSIZE-1/3 (see original
%   IdentifyPrimLoG2 by Author: Baris Sumengen -sumengen@ece.ucsb.edu)
%
%   H = FSPECIALCP3D('3D LoG, Raj',HSIZE,SIGMA,PLANES) returns a rotationally symmetric
%   Laplacian of Gaussian filter of size HSIZE with standard deviation
%   SIGMA (positive), which is stretched orthogonally along PLANE .
%   HSIZE can be a vector specifying the number of rowsand columns in H or
%   a scalar, in which case H is a square matrix. PLANES is a scalar describing
%   the amount of adjacent planes used for filtering. The default HSIZE is
%   [5 5]. SIGMA's default is HSIZE-1/3 (see original IdentifyPrimLoG2 by
%   Author of IdentifyprimLoG2: Baris Sumengen -sumengen@ece.ucsb.edu).
%   3D is constructed according to Raj et al. by copying the 2D Laplacian
%   of Gaussian into adjacent z planes. Default for PLANES is 3 (Raj et al. 2008)
%
%   ----------------------------------
%   Authors:
%   Nico Battich
%   Thomas Stoeger
%   Lucas Pelkmans
%   
%   Battich et al. 2013
%   Website: http://www.imls.uzh.ch/research/pelkmans.html
%
%   See also FSPECIAL, CONV2, EDGE, FILTER2, FSAMP2, FWIND1, FWIND2, IMFILTER.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% DETERMINE FILTER %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Filter = varargin{1};

if ischar(Filter)
    switch Filter
        case '2D LoG'
            switch nargin
                case 1
                    numRadius = [5 5];
                    sigma = (numRadius-1)/3; % corresponds to the initial sigma used for spot detection by Baris Sumengen in the initial IdentifyPrimLoG2 module
                case 2
                    numRadius = varargin{2};
                    sigma = (numRadius-1)/3;
                case 3
                    numRadius = varargin{2};
                    sigma = varargin{3};
                otherwise
                    error('Wrong numbers of input arguments for 2D LOG filtering by fspecialCP\n');
            end
            
            op = fspecial('log',numRadius,sigma);
            op = op - sum(op(:))/numel(op); % make the op to sum to zero
            
        case '3D LoG, Raj'
            switch nargin
                case 1
                    numRadius = [5 5];
                    sigma = (numRadius-1)/3;    % corresponds to the initial sigma used for spot detection by Baris Sumengen in the initial IdentifyPrimLoG2 module
                    numPlanes = 3;              % corresponds to default by Raj et al.
                case 2
                    numRadius = varargin{2};
                    sigma = (numRadius-1)/3;
                    numPlanes = 3;
                case 3
                    numRadius = varargin{2};
                    sigma = varargin{3};
                    numPlanes = 3;
                case 4
                    numRadius = varargin{2};
                    sigma = varargin{3};
                    numPlanes = varargin{4};
                    
                    if isempty(sigma)       % in case that sigma was not specified, derive it according to Sumengen
                        sigma=(numRadius-1)/3;
                    end
                otherwise
                    error('Wrong numbers of input arguments for 3D LOG, Raj filtering by fspecialCP\n');
            end
            
            op = fspecial('log',numRadius,sigma);
            op = op - sum(op(:))/numel(op);
            % make the op to sum to zero
            %If 3 dimensions, follow code of Raj et al., used for
            % singlemoleculefish: (see his comments & code commented below)
            % Here, we amplify the signal by making the filter "3-D"
            % H = 1/3*cat(3,H,H,H);
            op = 1/numPlanes*cat(numPlanes,op,op,op);
            
        otherwise
            error('Input Filter Type not supported.')
    end
else
    error('Input Filter Type not supported.')
end

H = op;