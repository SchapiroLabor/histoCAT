function [Output] = SourceExtractorDeblend(Image,BaseImageCC,FiltImage,Options)

%[NB] this function is an implementation of the spots deblendig algorithm
%of source extractor Bertin et al. 1996
%Usage: [OutputCC] = SourceExtractorDeblend(Image,BaseImageCC,FiltImage,Options)
%Where Image is the original image to be segmented. BaseImageCC is the base
%segmentation of the image, FiltImage is the LoG Filter image of Image (the
% third output of ObjByFilter).
%Options is a structutre with the following filds and default values:
%
%Options.ObSize = 6;
%Options.limQuant = [0.05 0.995];
%Options.RescaleThr = [nan nan 166 nan]
%Options.ObjIntensityThr = 98;
%Options.closeHoles = false;
%Options.ObjSizeThr = [];
%Options.ObjThr = 0.02;
%Options.StepNumber = 50;
%Options.DetectBias = DetectionBias;

if nargin < 4
    Options = struct();
end

if ~isfield(Options,'ObSize')
    Options.ObSize = 6;
end

if ~isfield(Options,'limQuant')
    Options.limQuant = [0.05 0.995];
end

if ~isfield(Options,'RescaleThr')
    Options.RescaleThr = [nan nan 166 nan];
end

if ~isfield(Options,'ObjIntensityThr')
    Options.ObjIntensityThr = 98;
end

if ~isfield(Options,'closeHoles')
    Options.closeHoles = false;
end

if ~isfield(Options,'ObjSizeThr')
    Options.ObjSizeThr = [];
end

if ~isfield(Options,'ObjThr')
    Options.ObjThr = 0.02;
end

if ~isfield(Options,'StepNumber')
    Options.StepNumber = 50;
end

if ~isfield(Options,'numRatio')
    Options.numRatio = 0.20;
end

if ~isfield(Options,'doLog')
    Options.doLog = 1;
end

if ~isfield(Options,'DetectBias')
    Options.DetectBias = [];
end

% create filter
Options.Filter = fspecialCP3D('2D LoG',Options.ObSize);

%[ObjCount BaseImageCC FiltImage] = ObjByFilter(Image,se.Filter,se.ObjThr,se.limQuant,[],se.ObjIntensityThr,true,se.ObjSizeThr);
%L = labelmatrix(BaseImageCC);
%figure;imagesc(L)


%get the range of thresholds to test... Note the threshold in SE are dor in
%a Log scale, here is linear! this can be changed
if Options.doLog
    minFiltImage = abs(min(FiltImage(:)));
    convFiltImage = FiltImage(:)+minFiltImage;
    UpLimit = quantile(convFiltImage,0.999);
    matThresToTest = linspace(log10(Options.ObjThr+minFiltImage),log10(UpLimit),Options.StepNumber);
    matThresToTest = 10.^matThresToTest;
    matThresToTest = matThresToTest-minFiltImage;
    
    
else
    UpLimit = quantile(FiltImage(:),0.999);
    matThresToTest = linspace(Options.ObjThr,UpLimit,Options.StepNumber);
    
end


fprintf('%s: Calculating all thresholded images. Total Number %d. ',mfilename,Options.StepNumber)
tic
[~, structSegCC] = ObjByFilter(Image,Options.Filter,matThresToTest,...
    Options.limQuant,Options.ObjSizeThr,Options.ObjIntensityThr,false,Options.ObjSizeThr,Options.DetectBias);
toc

% calculating all centroid for higly expressed gene takes too much memory
% fprintf('%s: Calculating all centroids. ',mfilename)
% tic
% cellAllCentroid = cellfun(@(x) regionprops(x,'Centroid'),structSegCC,'uniformoutput',false);
% cellAllCentroid = cellfun(@(x) cat(1,x(:).Centroid), cellAllCentroid,'uniformoutput',false);
% cellAllCentroid = cellfun(@(x) round(x), cellAllCentroid,'uniformoutput',false);
% cellAllCentroid = cellfun(@(x) sub2ind(size(FiltImage),x(:,2),x(:,1)),cellAllCentroid,'uniformoutput',false);
% toc


fprintf('%s: Deblending Images, please wait. ',mfilename)
tic
%go via all images
for i = 1:length(structSegCC)
    
    tempImage = structSegCC{i};
    
    %Calculate centroids of the temporary image
    %propsCentroid = cellAllCentroid{i};
    %     tic
    %     propsCentroid = regionprops(tempImage,'Centroid');
    %     propsCentroid = cat(1,propsCentroid(:).Centroid);
    %     propsCentroid = round(propsCentroid);
    %     propsCentroid = sub2ind(size(FiltImage),propsCentroid(:,2),propsCentroid(:,1));
    %     toc
    % %     calculate centroind without region Props.
    %     oldpropsCentroid=propsCentroid;
    
    %     [a,b]=ind2sub(tempImage.ImageSize,cat(1,tempImage.PixelIdxList{:}));
    %     matLengths = cellfun(@length ,tempImage.PixelIdxList);
    %     numMax = max(matLengths);
    %     matIndXY = 1:numMax:length(matLengths)*numMax;
    %     indXY = arrayfun(@(a,b) [a:b+a-1],matIndXY',matLengths','uniformout',false);
    %     indXY = cat(2,indXY{:});
    %     matMeanA = nan(numMax,length(matLengths));
    %     matMeanB = matMeanA;
    %     matMeanA(indXY) = a;
    %     SubIndA = round(nanmean(matMeanA,1));
    %
    %     matMeanB(indXY) = b;
    %     SubIndB = round(nanmean(matMeanB,1));
    %
    %     propsCentroid = sub2ind(size(FiltImage),SubIndA,SubIndB);
    
    
    %       propsCentroid = cellfun(@(x) x(1),tempImage.PixelIdxList);
    %       propsCentroid = cat(1,propsCentroid(:));
    
    propsCentroid = nan(length(tempImage.PixelIdxList),1);
    SubIndA = propsCentroid;
    SubIndB = propsCentroid;
    
    
    for ispot = 1:length(tempImage.PixelIdxList);
        
        propsCentroid(ispot)=tempImage.PixelIdxList{ispot}(1);
        [a,b]=ind2sub(tempImage.ImageSize,tempImage.PixelIdxList{ispot});
        
        SubIndA(ispot) = round(mean(a,1));
        SubIndB(ispot) = round(mean(b,1));
    end
    
    propsCentroid = sub2ind(size(FiltImage),SubIndA,SubIndB);
    
    
    %     [a,b]=ind2sub(tempImage.ImageSize,cat(1,tempImage.PixelIdxList{:}));
    %     cellSubIndexes = mat2cell([a,b],cellfun(@length ,tempImage.PixelIdxList)',2);
    %     propsCentroid = cellfun(@(a) mean(a,1),cellSubIndexes,'uniformoutput',false);
    %     propsCentroid = cat(1,propsCentroid{:});
    %     propsCentroid = round(propsCentroid);
    %     propsCentroid = sub2ind(size(FiltImage),propsCentroid(:,1),propsCentroid(:,2));
    
    
    
    tempIsMemb = ismember(cat(1,BaseImageCC.PixelIdxList{:}),propsCentroid)';
    LengthVector = cellfun(@length, BaseImageCC.PixelIdxList);
    IxSpotsI = cell2mat(arrayfun(@(a,b) ones(1,a).*b,LengthVector,(1:length(BaseImageCC.PixelIdxList)),'uniformoutput',false));
    IxSpotsJ = cell2mat(arrayfun(@(a) [1:a],LengthVector,'uniformoutput',false));
    matTempSort = zeros(max(IxSpotsI),max(IxSpotsJ));
    IxIJ = sub2ind(size(matTempSort),IxSpotsI,IxSpotsJ);
    matTempSort(IxIJ) = tempIsMemb;
    matBinaryReadout = sum(matTempSort,2)';
    
    
    %matBinaryReadout = cellfun(@(x) sum(ismember(x,propsCentroid)),BaseImageCC.PixelIdxList);
    
    %find spots to be deblended
    matSpottoDebl = find(matBinaryReadout>1);
    
    
    if ~isempty(matSpottoDebl)
        
        tempBasePixelList = BaseImageCC.PixelIdxList(matSpottoDebl);
        cellCentroidIx = cellfun(@(x) find(ismember(propsCentroid,x)), tempBasePixelList,'uniformoutput',false );
        
        %measure intensities for the new spots
        SumSpotInt = mat2cell(arrayfun(@(k) sum(Image(tempImage.PixelIdxList{k})),cell2mat(cellCentroidIx')),...
            cellfun(@length ,cellCentroidIx)',1);
        
        tempTotalIntOverThre = cellfun(@(x) (x./sum(x))>Options.numRatio,SumSpotInt,'uniformoutput',false);
        tempIX = cellfun(@(x) sum(x),tempTotalIntOverThre)>1;
        
        BaseImageCC.PixelIdxList(matSpottoDebl(tempIX)) = [];
        BaseImageCC.PixelIdxList = [BaseImageCC.PixelIdxList tempImage.PixelIdxList(cat(1,cellCentroidIx{tempIX}))];
        BaseImageCC.NumObjects = length(BaseImageCC.PixelIdxList);
    end
    
end
toc

% Reformat output
if BaseImageCC.NumObjects > 0
    CentroidsOutput = regionprops(BaseImageCC,'Centroid');
    CentroidsOutput = cat(1,CentroidsOutput(:).Centroid);
    CentroidsOutput = round(CentroidsOutput);
    CentroidsOutput = sub2ind(size(FiltImage),CentroidsOutput(:,2),CentroidsOutput(:,1));
    matImageOut = zeros(size(Image));
    matImageOut(CentroidsOutput) = 1;
    Output = bwlabel(matImageOut);
else
    Output = zeros(BaseImageCC.ImageSize);
end
