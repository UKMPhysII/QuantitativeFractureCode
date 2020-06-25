% This helper function stores required outputs into OutputStructure, and
% saves a copy to disk. Oh, it also actually calls the other calculation
% functions necessary to get the required outputs.
function OutputStructure = calculateOutputs(OutputStructure, ImageSlices, ...
                           iFile, outputPath)
    disp('Calculating orthogonal projection...')
    for iSlice = 1:length(ImageSlices)
        if isempty(ImageSlices(iSlice).slice)
            continue
        end
        [D1, mainAngle, ImageSlices] = calculateD1(ImageSlices, iSlice);
        [D2, originalThetas, ImageSlices] = calculateD2(ImageSlices, iSlice, 10);
        OutputStructure(iFile).residuals(iSlice).D1 = D1;
        OutputStructure(iFile).residuals(iSlice).D2 = D2;
        OutputStructure(iFile).residuals(iSlice).mainAngle = mainAngle;
        OutputStructure(iFile).residuals(iSlice).Angles = originalThetas;
        OutputStructure(iFile).residuals(iSlice).AngleRatios = 1 - ...
                            abs(rad2deg(mainAngle - originalThetas))/90;
    end
    thisOutputStructure = OutputStructure(iFile);
    save([outputPath '\thisOutputStructure.mat'], 'thisOutputStructure')
end