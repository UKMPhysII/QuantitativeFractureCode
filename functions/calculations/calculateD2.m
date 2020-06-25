% Calculates the residuals between the indices associated with a given
% Z-disk. These residuals are calculated for each "side" of a Z-disk, and
% these are modified to give weight to how straight the Z-disk is. 

function [D2, originalThetas, ImageSlices] = calculateD2(ImageSlices, iSlice, minSize)
% Now to isolate the individual Z-disks, linearly regress them, and
% compare the angle with the overall fit for the line of Z-disks.

% Find connected regions and label them
zDiskConnect = bwconncomp(ImageSlices(iSlice).slice, 8);
zDiskLabels = labelmatrix(zDiskConnect);

D2 = [];
originalThetas = [];

% To calcualte D2, each individual Z-disk must be isolated, and
% linearly regressed.
for iLabel = 1:max(max(zDiskLabels))
    zDisk = zeros(size(zDiskLabels));
    zDisk(zDiskLabels == iLabel) = 1;
    
    % Remove all empty columns and rows surrounding the zDisk
    zDisk = zDisk(~all(zDisk == 0, 2), :);
    zDisk = zDisk(:, ~all(zDisk == 0, 1));
    
    % If the Z-disk is too small, do not regress.
    if numel(zDisk) <= minSize
        continue
    end
    
    ImageSlices(iSlice).zDisks(iLabel).disk = zDisk;
    
    % Rotate Z-disk to vertical orientation, without user input.
    theta = 0;
    checkValue = 0;
    [~, originalTheta, ~] = rotateZdisk(zDisk, 0);
    if originalTheta > pi/2
        originalTheta = pi - originalTheta;
    end
    
    % This part tries to get the average angle to around pi/4, so
    % that the linear regression can work properly. If it's too
    % vertical, it will fail.
    while checkValue == 0
        [zDiskRotation, ~, newTheta] = rotateZdisk(zDisk, theta);
        if newTheta <= pi/4
            checkValue = checkValue + 1;
        else
            if newTheta >= pi/4
                theta = theta - pi/8;
            elseif newTheta >= pi
                theta = theta - 5*pi/8;
            elseif newTheta >= 3*pi/4
                theta = theta - 9*pi/8;
            else
            end
        end
    end
    %             Store calculated variables in memory
    D2 = [D2 calculateStraightness(zDiskRotation)];
    originalThetas = [originalThetas originalTheta];
end
end