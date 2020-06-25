% Calculates the length of a sarcomere by taking the distance between two
% adjacent center of masses in a given horizontal line of pixels.

function [length, OutputStructure, nBands] = calculateLength(lengthGuess, ...
                                    OutputStructure, sortedIndices, ...
                                    imageHandle, outputPath, fileName, ...
                                    iFile)

% Define threhold point by which indices will be grouped.
thresholdValue = ceil(lengthGuess / exp(1));

% Calculate average length
lengthsByBand = 0;
allLengths = [];

nBands = size(sortedIndices, 2);

% Calculate lengths by taking distance between points in neighbouring
% lines.  Will work best when perfectly vertical, but error should
% scale with angle.
disp('Calculating lengths...')
for iBand = 1 : nBands - 1
    lengths = [];
    for jIndex = 1 : size(sortedIndices, 1)
        
        testIndex = abs(sortedIndices(jIndex, iBand + 1) - ...
            sortedIndices(jIndex, iBand));
        upperValue = lengthGuess + thresholdValue;
        lowerValue = lengthGuess - thresholdValue;
        
        % If index in line ic is empty, continue.
        if sortedIndices(jIndex, iBand) == 0
            continue
            
            % If index in line ic+1 is empty, continue.
        elseif sortedIndices(jIndex, iBand + 1) == 0
            continue
            
            % If next index is inside of the user guess minus the threshold
            % range, or outside of the user guess plus the threshold,
            % continue
        elseif testIndex > upperValue || testIndex < lowerValue
            continue
            
            % If the indices are juuuust right, calculate the length.
        else
            tempLength = abs(sortedIndices(jIndex, iBand + 1) - ...
                sortedIndices(jIndex, iBand));
            lengths = [lengths; tempLength];
        end
    end
    
    OutputStructure(iFile).lengths(iBand).values = lengths;
    lengthsByBand(iBand, 1) = mean(lengths);
    
    % This equalizes the size of the lengths, so I can avoid having to
    % figure out how to open a text file and write to it properly.
    if size(allLengths, 1) > numel(lengths)
        allLengths = [allLengths [lengths; NaN(size(allLengths, 1) - ...
            numel(lengths), 1)]];
    elseif size(allLengths, 1) < numel(lengths)
        allLengths = [[allLengths; NaN(numel(lengths) - size(allLengths, 1), ...
            size(allLengths, 2))] lengths];
    end
end
writematrix(allLengths, [outputPath '/Lengths.txt'], 'Delimiter', ',')

figure(imageHandle)
hold on
% Plot the bands on top of the previous image.
for iBand = 1 : nBands - 1
    for jIndex = 1:10:size(sortedIndices, 1)
        
        testIndex = abs(sortedIndices(jIndex, iBand + 1) - ...
            sortedIndices(jIndex, iBand));
        upperValue = lengthGuess + thresholdValue;
        lowerValue = lengthGuess - thresholdValue;
        
        if sortedIndices(jIndex, iBand) == 0
            continue
        elseif sortedIndices(jIndex, iBand + 1) == 0
            continue
        elseif testIndex > upperValue || testIndex < lowerValue
            continue
        else
            plot([sortedIndices(jIndex, iBand + 1) sortedIndices(jIndex, iBand)], ...
                [jIndex jIndex], 'Color', [1,1,1,0.5], 'LineWidth', 2)
        end
    end
end

figFrame = getframe;
imwrite(figFrame.cdata, [outputPath '\lengthPlot_' fileName 'F'])

%     The calculated length
length = mean(lengthsByBand(:));

disp(['Average length is ' num2str(length) ' px'])
end