% calculateStraightness calculates the straightness factor of a given Z-disk.
% Only built for single Z-discs. It does so in a bit of roundabout way, by
% first ensuring the Z-disk is as vertical as possible, isolating the left
% and right sides, rotating these sides so that linear regression is more
% accurate, then comparing left and right regressions to weight how
% straight the Z-disk is. A disordered Z-disk is a sign of instability in
% the sarcomeric structure.

function out = calculateStraightness(zDisk)

%Reconstruct image matrix

x = zDisk(:, 1);
y = zDisk(:, 2);
X = [ones(length(x),1) x];
b = X\y;

xfit = min(x):max(x);
bestfit = xfit * b(2) + b(1);

inipos = [xfit(1) bestfit(1)];
bvec = [(xfit(end) - xfit(1)) (bestfit(end) - bestfit(1))];
magb = sqrt(sum(bvec .* bvec));

uniX = unique(x);

for Xc = 1:numel(uniX)
    orthog_dis = zeros(1, 2);
    xInd = find(x == uniX(Xc));
    xTemp = x(xInd);
    yTemp = y(xInd);
    
    nEnd = numel(xInd);
    
    for nc = 1:nEnd
        i = xTemp(nc) - inipos(1);
        j = yTemp(nc) - inipos(2);
        
        a = [i j];
        
        a1 = (dot(a, bvec, 2) * bvec) / (magb^2);
        a2 = a - a1;
        
        a1_end = [(inipos(1) + a1(1)) (inipos(2) + a1(2))];
        a_end = [(inipos(1) + a(1)) (inipos(2) + a(2))];
        orthog_dis(nc) = sqrt((a_end(1) - a1_end(1))^2 + (a_end(2) - a1_end(2))^2);
    end
    
    out = mean(abs(orthog_dis));
    
end
end