% seperateBands takes a sorted list of indices and uses these indices as a
% seed to seperate out bands of Z-disks from the original image. It saves
% these seperated bands into the ImageSlices structure, for further
% analysis.

function ImageSlices = seperateBands(imageSize, lengthGuess, nBands, ...
                            sortedIndices, imageMask)
% Isolate bands into new variables, taking into account the edges cases
% of the image. Technically the bounds were set before, but I don't
% mind having a backup in case something funky happens.

ImageSlices = [];
nRows = size(sortedIndices, 1);
leftIndices = zeros(nBands, nRows);
rightIndices = zeros(nBands, nRows);

% Iterate over all the bands and all the rows, and take 1/4 of a sarcomere
% length guess from the left and right of said index in the original image.
% Store this in a new matrix.
for iBand = 1 : nBands
    for jRow = 1 : nRows
        if sortedIndices(jRow, iBand) == 0
            continue
        else
            leftIndices(iBand, jRow) = sortedIndices(jRow, iBand) - ceil(lengthGuess/4);
            if leftIndices(iBand, jRow) <= 0
                leftIndices(iBand, jRow) = 1;
            end
            rightIndices(iBand, jRow) = sortedIndices(jRow, iBand) + ceil(lengthGuess/4);
            if rightIndices(iBand, jRow) > imageSize
                rightIndices(iBand, jRow) = imageSize;
            end
            indexVector = leftIndices(iBand, jRow) : rightIndices(iBand, jRow);
            tempVal = imageMask(jRow, indexVector);
            isolatedBands(jRow, indexVector, iBand) = tempVal;
        end
    end
end


% Put into imageSlices.
for iBand = 1 : nBands
    tempBand = isolatedBands(:, :, iBand);
    tempSum = sum(tempBand);
    nonzeroIndices = find(tempSum > 0, 1) : find(tempSum > 0, 1, 'last');
    ImageSlices(iBand).slice = isolatedBands(:, nonzeroIndices, iBand);
end

disp('Done!')
end