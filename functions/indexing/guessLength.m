% lengthGuess prompts the user to click on two Z-disks bands to set an
% "estimated" sarcomere length. Typically the guess is within 50-100 pixels
% of the calculated mean, which is a nice check.

function lengthGuess = guessLength(filePath, fileName, image)
if isfile([filePath fileName(1:end-4) '_outputs\lengthGuess.mat'])
    load([filePath fileName(1:end-4) '_outputs\lengthGuess.mat'])
else
    lengthFig = figure(1);
    clf
    imshow(imcomplement(image));
    disp('Please click on two sides of a sarcomere (to set approximate length')
    [xlen, ~] = ginput(2);
    lengthGuess = abs(xlen(2) - xlen(1));
    save([filePath fileName(1:end-4) '_outputs\lengthGuess.mat'], 'lengthGuess')
    close(lengthFig)
end
end