%processImage is the helper function to call all the other functions
%necessary isolate Z-disks in a given electron microscope image of
%sarcomeres.

function [image, imageMask] = processImage(filePath, fileName, outputPath)
% Read image into memory
image = imread(fullfile(filePath, fileName));
doesImageMaskExist = isfile([filePath fileName(1:end-4) ...
                                '_outputs\imageMask_' fileName 'F']);
    if ~doesImageMaskExist
        % Remove linear background from image
        removedBackgroundImage = backgroundRemove(image);
        
        figureRotate = figure(1);
        clf
        imshow(removedBackgroundImage)
        
        % Need to rotate the image so the streamlines are vertical for this
        % algorithm to work.
        rotatedImage = rotateImage(removedBackgroundImage);
        
        close(figureRotate)
        
        % Filter the image to isolate Z-disks. Vars = size of disk,
        % intensity limit, lower bound, upper bound.
        imageMask = filterImage(rotatedImage, 20, 200, 50, 10000);
        
        % Output mask to file, so that manual modification can be made.
        imwrite(imageMask, [outputPath '\imageMask_' fileName 'F']);
        disp('Modify mask, then press any key.')
        pause()
        
        % Save out un/modified mask to disk.
        imageMask = imread([outputPath '\imageMask_' fileName 'F']);
        imageMask = imageMask(:, :, 1); % This accounts for layering, in 
        %case of weird modification shenanigans.
        imwrite(imageMask, [outputPath '\imageMask_' fileName 'F']);
        
    elseif doesImageMaskExist
        % If a mask already exists, load it.
        imageMask = imread([outputPath '\imageMask_' fileName 'F']);
        imageMask = imageMask(:, :, 1);
    else
        error(['Something went wrong with loading and/or saving the ' ...
               'image mask.'])
    end
end