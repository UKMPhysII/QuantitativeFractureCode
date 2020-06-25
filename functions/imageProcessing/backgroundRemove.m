% backgroundRemove linearly removes background noise for the four cardinal
% rotatations of the image. This method was chosen over more robust methods
% of background removal because otherwise too much information A-Band and
% I-band information is lost. This reduces the contrast, and makes
% isolating the Z-disks more difficult.

function removedBackgroundImage = backgroundRemove(image)

backgroundRemoveImage = image;
rots  = [1 2 3 4];

% Remove linear background differences. Chosen linear method, as
% more typical methods tend to remove too much I- and A-band
% information.
for i = 1:4
    backgroundRemoveImage = rot90(backgroundRemoveImage, rots(i));
    intensity = double(backgroundRemoveImage(:, 1).');
    index = 1:length(backgroundRemoveImage(:, 1));
    p = polyfit(index, intensity, 1);
    yfit = p(1) * index + p(2);
    adjust = yfit(1);
    yfit(length(yfit)/2:end) = yfit(length(yfit)/2:end) - yfit(length(yfit)/2);
    yfit(1:length(yfit)/2) = yfit(length(yfit)/2) - fliplr(yfit(1:length(yfit)/2)) + adjust;
    
    totalfit = repmat(yfit.', 1, length(backgroundRemoveImage(1,:)));
    backgroundRemoveImage = uint8(double(backgroundRemoveImage) - totalfit*1);
end

removedBackgroundImage = backgroundRemoveImage;
end