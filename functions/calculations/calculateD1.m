% Calculates the residuals between the indices associated with a given band
% of Z-disks and a linear regression. The residuals are calculated in an
% orthogonal way, to minimize distances.

function [D1, mainAngle, ImageSlices] = calculateD1(ImageSlices, iSlice)

% Get rid of empty columns and rows on the sides of the slice.
ImageSlices(iSlice).slice = ImageSlices(iSlice).slice(~all(ImageSlices(iSlice).slice == 0, 2), :);
ImageSlices(iSlice).slice = ImageSlices(iSlice).slice(:, ~all(ImageSlices(iSlice).slice == 0, 1));

% Find all points corresponding to z-disks, and assign an x and y
% value
[x, y] = find(ImageSlices(iSlice).slice > 0);

% Begin linear regression
X = [ones(length(x),1) x];
b = X\y;

xFit = min(x):max(x);
bestFit = xFit * b(2) + b(1);
rise = (bestFit(end) - bestFit(1));
run = xFit(end) - xFit(1);
% Calculate angle to compare to individual Z-disks.
mainAngle = atan(rise/run);

iniPos = [xFit(1) bestFit(1)];
bVec = [(xFit(end) - xFit(1)) (bestFit(end) - bestFit(1))];
magb = sqrt(sum(bVec .* bVec));

% Use only the unique X's, because Z-disk pixels tend to overlap
% with regards to x-position.
uniqueX = unique(x);

% Find all points for a given unique X
for iXVal = 1:numel(uniqueX)
    orthogonalDistance = zeros(1, 2);
    xIndices = find(x == uniqueX(iXVal));
    xTemp = x(xIndices);
    yTemp = y(xIndices);
    
    nEnd = numel(xIndices);
    
    % Iterate over all points for a given unique X
    for iN = 1:nEnd
        i = xTemp(iN) - iniPos(1);
        j = yTemp(iN) - iniPos(2);
        
        a = [i j];
        
        a1 = (dot(a, bVec, 2) * bVec) / (magb^2);
        
        a1End = [(iniPos(1) + a1(1)) (iniPos(2) + a1(2))];
        aEnd = [(iniPos(1) + a(1)) (iniPos(2) + a(2))];
        
        orthogonalDistance(iN) = sqrt((aEnd(1) - a1End(1))^2 + ...
                                (aEnd(2) - a1End(2))^2);
    end
    
    orthogonalDistance = abs(mean(orthogonalDistance));
    ImageSlices(iSlice).residuals(iXVal) = orthogonalDistance;
end
D1 = mean(ImageSlices(iSlice).residuals(iXVal));
end