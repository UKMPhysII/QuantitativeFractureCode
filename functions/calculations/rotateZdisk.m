% rotateZDisk is a function that takes input zDisk and rotates it into a vertical
% alignment.

function [out, origTh, newTh] = rotateZdisk(zDisk, th)
    
    %Find the indices of the Z-disk, and perform linear regression.
    [y, x] = find(zDisk > 0);
    
    %Add random rotation to enable better linear regression.
    [TH, R] = cart2pol(x, y);
    TH = TH + th;
    newTh = mean(TH);
    [x, y] = pol2cart(TH, R);
    
    if size(x, 1) == 1
        x = x.';
        y = y.';
    end
    
     X = [ones(length(x),1) x];
    fit = X\y;
    
    %Create the triangle
    bestfit = x * fit(2) + fit(1);
    a = (x(end) - x(1));
    b = (bestfit(end) - bestfit(1));
%     c = sqrt(a^2 + b^2);
    
    %Calculate angle of line of best fit
    origTh =  atan(b/a);
    
    %Convert to polar coordinates
%     [TH, R] = cart2pol(x, y);
% %     TH = TH - pi/2 - theta;
%     [x, y] = pol2cart(TH, R);
%     
    x = x - min(x) + 1;
    y = y - min(y) + 1;
    
    out = [x y];
end