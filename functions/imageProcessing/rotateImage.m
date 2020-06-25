% rotateImage does exactly as described. It prompts for user-input to set
% the rotation of the image such that the streamlined Z-disks run as
% vertically as possible.

function rotatedImage = rotateImage(image)
% Algorithm depends on the sarcomeres being vertically aligned, so
% ask for user input to rotate image appropriately.
disp('Please click on both ends of z-band, to set rotation.')
[xtri, ytri] = ginput(2);

xlen = xtri(2) - xtri(1);
ylen = ytri(2) - ytri(1);
theta = atand(xlen / ylen);

% Rotate to vertical using -theta
rotatedImage = imrotate(image,  - theta, 'bilinear', 'crop');
end