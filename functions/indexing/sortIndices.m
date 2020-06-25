% This sorts the indices from conglomerateIndices, shifting the index
% values into columns based on their value, informed by a check line
% of indices that contain the most Z-disk bands.

function [sortedIndices, scatterHandle] = sortIndices(lengthGuess, ...
                                indices, imageHandle, outputPath, fileName)
summed = sum(indices);

% Define threhold point by which indices will be grouped.
thresholdValue = ceil(lengthGuess / exp(1));

% Find where the largest number of peaks are
primaryIndices = indices(:, summed > 0);
nBands = size(primaryIndices, 2);

% Take largest number of peaks, and use those values are starting points

tempIndices = primaryIndices;
tempIndices(tempIndices > 0) = 1;
tempIndices = sum(tempIndices, 2);
[~, indexIndex] = max(tempIndices); % Just the indices of where the largest
% sums are.
checkValues = primaryIndices(indexIndex(1), :);

% Create copy of check_values to avoid possible ambiguity in second half
% of indexing.
checkValues2 = checkValues;

% Initialise empty matrix for sorted matrix
sortedIndices = zeros(size(primaryIndices));

disp('Sorting indices...')

% For each peak in starting values, check each column of indices and see if
% it is within the threshold value. (NOTE: only works for "straight" lines
% right now, will need to implement updating indices at some point)


% This part starts at the chosen points above, and moves "up" the
% picture, which is then added to the "bottom" part below.
for iBand = 1 : nBands
    for jRow = fliplr(1:indexIndex(1)) % From the first row of the picture,
        %to the row associated with checkValues.
        compareValue = checkValues(iBand);
        if primaryIndices(jRow, iBand) == 0
            continue
        else
            if primaryIndices(jRow, iBand) > compareValue - thresholdValue && primaryIndices(jRow, iBand) < compareValue + thresholdValue
                sortedIndices(jRow, iBand) = primaryIndices(jRow, iBand);
                checkValues(iBand) = primaryIndices(jRow, iBand);
            else
                primaryIndices(jRow, iBand + 1 : end) = primaryIndices(jRow, iBand : end - 1);
                primaryIndices(jRow, iBand) = 0;
            end
        end
    end
end

% Reset check_values for bottom part of the indexing.
checkValues = checkValues2;

% This portion looks for indices past the starting, "most lines"
% indices chosen above.
for iBand = 1 : nBands
    for jRow = indexIndex(1):size(primaryIndices, 1)
        compareValue = checkValues(iBand);
        if primaryIndices(jRow, iBand) == 0
            continue
        else
            if primaryIndices(jRow, iBand) > compareValue - thresholdValue && primaryIndices(jRow, iBand) < compareValue + thresholdValue
                sortedIndices(jRow, iBand) = primaryIndices(jRow, iBand);
                checkValues(iBand) = primaryIndices(jRow, iBand);
            else
                primaryIndices(jRow, iBand + 1 : end) = primaryIndices(jRow, iBand : end - 1);
                primaryIndices(jRow, iBand) = 0;
            end
        end
    end
end

% Check to see if sorted
if primaryIndices == sortedIndices
    disp('Sorted!')
end

%     Plot the indices in scatter form
figure(imageHandle)
hold on
scatterHandle = [];
for iBand = 1 : nBands
    ytemp = primaryIndices(:, iBand);
    xtemp = 1:size(primaryIndices, 1);
    xtemp = xtemp(ytemp > 0);
    ytemp = ytemp(ytemp > 0);
    s = scatter(ytemp, xtemp, '.', 'SizeData', 20);
    scatterHandle = [scatterHandle s];
end
figFrame = getframe;
imwrite(figFrame.cdata, [outputPath '\scatterPlot_' fileName 'F'])
end
