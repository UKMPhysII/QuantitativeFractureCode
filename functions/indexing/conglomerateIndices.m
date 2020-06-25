% conglomerateIndices assigns an index value to each band of Z-disks in a
% given horizontal row of pixels. It does this by taking an average of each
% localised peak area, to gain a "center of mass" for the disk.

function unsortedIndices = conglomerateIndices(image, lengthGuess)
yDimension = size(image, 1);
nLines = 50;
% Initialise variable into memory with far more columns than needed, to
% ensure there are enough columns available.
unsortedIndices = zeros(yDimension, nLines);

%     Define threhold point by which indices will be grouped.
thresholdValue = ceil(lengthGuess / exp(1));

% Find peaks and their indices in each horizontal "line" in the picture.
% Conglomerate peaks if they are too close together.
for iLine = 1 : yDimension
    checkline = image(iLine, :);
    [~, index] = findpeaks(double(checkline));
    
    if isempty(index)
        continue
    end
    
    checkVal = 1;
    
    % This part deals with peaks that are too close together to be
    % considered distinct peaks.
    while checkVal ~= length(index)
        if abs(index(checkVal + 1) - index(checkVal)) < lengthGuess - thresholdValue
            index(checkVal + 1) = [];
        elseif abs(index(checkVal + 1) - index(checkVal)) > lengthGuess - thresholdValue
            checkVal = checkVal + 1;
        else
            error('Something went wrong with the index conglomeration (line 178).')
        end
    end
    
    % Sometimes peaks decide they want to be where they shouldn't, and
    % this keeps them in line by eliminating them. Otherwise known as a
    % Stalin Sort.
    for iInd = 1 : length(index) - 1
        if index(iInd + 1) < index(iInd)
            index(iInd + 1) = [];
        end
    end
    
    % This takes the above indices, and imposes boundary conditions on
    % them. Also finds the average point (somewhat analagous to a
    % center of mass).
    for iInd = 1 : length(index)
        if index(iInd) - thresholdValue < 1
            leftIndex = 1;
            rightIndex = index(iInd) + thresholdValue;
        elseif index(iInd) + thresholdValue > size(image, 1)
            leftIndex = index(iInd) - thresholdValue;
            rightIndex = size(image, 1);
        else
            leftIndex = index(iInd) - thresholdValue;
            rightIndex = index(iInd) + thresholdValue;
        end
        tempLine = checkline(leftIndex:rightIndex);
        tempIndex = find(tempLine > 0);
        avInd = round(length(tempIndex)/2);
        index(iInd) = leftIndex - 1 + tempIndex(avInd);
    end
    
    unsortedIndices(iLine, 1:length(index)) = index;
end
end