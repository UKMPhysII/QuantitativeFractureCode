% filterImage applies a bottom hat filter to the input image, filters by
% intensity, then calculates 8-way connectedness matrix. The areas are
% labelled and filtered by size, to hopefully isolate the Z-disks of a
% given sarcomere image.

function imageMask = filterImage(image, diskSize, maxIntensity, ...
                                    lowerPixelBound, upperPixelBound)
% Use bottom hat filter to highlight Z-disc bands
% larger/smaller diskSize has huge influence. Want to be approx the width
% of Z-disk.
botFilterImage = imbothat(image, strel('disk', diskSize));

% Use imadjust to saturate Z-disc bands
adjsutFilterImage = imadjust(botFilterImage);

% Now we create a black-and-white mask, to filter out anything that isn't
% z-band.  First we remove everything below a certain intensity, then we
% create a 8-way connection map.  These regions are then labelled, and only
% areas that are between a certain size are kept.

BWImage = adjsutFilterImage >= maxIntensity;     

% Calculate connectedness
connectedness = bwconncomp(BWImage, 8);
pixelDetails = regionprops(connectedness, 'Area');
pixelLabels = labelmatrix(connectedness);

pixelSizeFilter = find([pixelDetails.Area] <= upperPixelBound & ...
                        [pixelDetails.Area] >= lowerPixelBound);
BWImage = ismember(pixelLabels, pixelSizeFilter);
% And so we have identified the pixels that correspond to the
% Z-disks.


% This multiplies our black-and-white map onto our original image,
% retrieving the z-discs and creating the final mask.
imageMask = uint8(BWImage.*double(adjsutFilterImage));
end