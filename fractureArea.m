%FRACAREA.m a script to calculate the fracture area of sarcomere structures
%from electron microscope images (.TIF format here, though other formats are
%compatible). Will create an output folder in the same folder as the chosen
%image, and create files in this folder pertaining to different variables:
%  - lengths.txt contains the lengths for the chosen image
%  - d1.txt contains the orthogonal residuals on the sarcomere scale
%  - d2.txt contains the average orthogonal residuals on the z-disk scale
%  - angles.txt contains the angle between d1 and d2
%  - fracarea.txt contains the calculated fracture area, according to
%  A_f = D_1 * D_2 * theta

% PAPER CITATION GOES HERE

%% INITIALISE

addpath(genpath(pwd)) % Add current directory to the path, so that 
% functions can be found.

% Prompt user for image, store file path and load original image.
[fileNames, filePath] = uigetfile('*.tif', 'Select sarcomere images',...
                            'MultiSelect','on');

% This accounts for either a single image, or multiple images.
if ischar(fileNames)
    nFiles = 1;
else
    nFiles = length(fileNames);
    pathToggle = 1;
end

% Initialise structure
OutputStructure = struct([]);

endToggle = 0;
    
for iFile = 1 : nFiles
    
    if ischar(fileNames)
        fileName = fileNames;
    else
        fileName = fileNames{iFile};
        mkdir(filePath, 'file_outputs')
    end
    
    mkdir(filePath, [fileName(1:end-4) '_outputs']) % Make output folder
    outputPath = [filePath fileName(1:end-4) '_outputs']; % Set output path
    
    %% IMAGE PROCESSING
    
    % Process the image and create the mask to use for Z-disk isolation.
    [image, imageMask] = processImage(filePath, fileName, outputPath);
    
    %% INDEXING
    
    % Ask for an esimate of sarcomere length to use in calculations.
    lengthGuess = guessLength(filePath, fileName, imageMask);
    
    % Creates matrix of indices corresponding to the y-coordinates of each
    % center of mass for all z-Disk lines.
    unsortedIndices = conglomerateIndices(imageMask, lengthGuess);
    
    % Plot figure for pretty plots.
    imageFigure = figure(1);
    clf
    imshow(imageMask)
    
    % Sorts indices into relevant columns
    [sortedIndices, ~] = sortIndices(lengthGuess, unsortedIndices, ...
                                imageFigure, outputPath, fileName);
    
    %% CALCULATIONS
    
    %Calculates the lengths between bands.
    [sarcomereLength, OutputStructure, nBands] = calculateLength(lengthGuess, ...
                                OutputStructure, sortedIndices, ...
                                imageFigure, outputPath, fileName, iFile);
                            
    % Creates the ImageSlices structure, which contains the isolated bands
    % of Z-disks for individual analysis.
    ImageSlices = seperateBands(size(imageMask, 1), sarcomereLength, nBands, ...
                    sortedIndices, imageMask);
                
    % Outputs the global residuals, local residuals, and angle outputs into
    % the Output Structure.
    OutputStructure = calculateOutputs(OutputStructure, ImageSlices, iFile, ...
                                        outputPath);
    
    
    % Conversions should be given in nm/px to output true size, and should
    % be listed in a 1-D vector. Return to this state for px basis.
    conversions = ones(1, size(OutputStructure, 2));
    
    % Saves the individual outputs to disk. Will be converted to nm if a conversion
    % vector is supplied above.
    saveOutputs(OutputStructure, conversions, outputPath, iFile, endToggle);
end % All files should now have been looped over, and the fracture area
% calculated, and saved to disk.
if pathToggle == 1
    endToggle = 1;
    outputPath = filePath;
    saveOutputs(OutputStructure, conversions, outputPath, iFile, endToggle);
    save([outputPath '\OutputStructure.mat'], 'OutputStructure')
else
end
