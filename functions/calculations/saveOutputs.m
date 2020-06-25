% saveOutputs saves the outputs to disk, in csv text files as well as
% outputting the OutputStructure structure to disk, for other analysis if
% required.

function saveOutputs(OutputStructure, conversions, outputPath, iFile,...
    endToggle)
%Perform data processing here. This section will remove the data from
%the output structure, and output csv files for use in a graphing program
%of choice.
% NOTE: Size of lengths output will always be one less than the number of
% bands, due to the way lengths are calculated.
averageLength = [];
actualLength = [];
actualD1 = [];
actualD2 = [];
angleRatios = [];

% This checks to see if this is the final call or not.
if endToggle == 1
    iStart = 1;
    nOutputs = iFile;
else
    iStart = iFile;
    nOutputs = iFile;
end

for iOutput = iStart : nOutputs
    nLengths = size(OutputStructure(iOutput).lengths, 2);
    for jLength = 1 : nLengths
        ltemp = OutputStructure(iOutput).lengths(jLength).values(OutputStructure(iOutput).lengths(jLength).values > 0);
        thisLength = mean(ltemp);
        averageLength = [averageLength thisLength];
        actualLength = [actualLength (thisLength * conversions(iOutput))];
    end
end

for iOutput = iStart : nOutputs
    nLengths = size(OutputStructure(iOutput).lengths, 2);
    for jLength = 1 : nLengths
        nanIndices = find(isnan(OutputStructure(iOutput).residuals(jLength).D2));
        OutputStructure(iOutput).residuals(jLength).Angles(nanIndices) = [];
        OutputStructure(iOutput).residuals(jLength).D2(nanIndices) = [];
        
        D1Temp = OutputStructure(iOutput).residuals(jLength).D1;
        D2Temp = mean(rmmissing(OutputStructure(iOutput).residuals(jLength).D2));
        angleRatioTemp = mean(rmmissing(OutputStructure(iOutput).residuals(jLength).AngleRatios));
        
        actualD1 = [actualD1 D1Temp * conversions(iOutput)];
        actualD2 = [actualD2 D2Temp * conversions(iOutput)];
        angleRatios = [angleRatios angleRatioTemp];
        
    end
end

lengths = actualLength.';
residuals = [actualD1.' actualD2.' angleRatios.' ];
fractureArea = (actualD1 .* actualD2 .* angleRatios).';

if mean(conversions) == 1 % Stupidly unlikely if actual conversions are being used.
    lengthColumnName = {'Lengths_px'};
    residualColumnNames = {'D1_px', 'D2_px', 'AngleRatio'};
    fractureAreaColumnName = {'FractureArea_px2'};
else
    lengthColumnName = {'Lengths_nm'};
    residualColumnNames = {'D1 _nm', 'D2 _nm', 'AngleRatio'};
    fractureAreaColumnName = {'FractureArea_nm2'};
end

lengths = array2table(lengths, 'VariableNames', lengthColumnName);
residuals = array2table(residuals, 'VariableNames', residualColumnNames);
fractureArea = array2table(fractureArea, 'VariableNames', fractureAreaColumnName);

writetable(residuals, [outputPath '\processedResiduals.txt'])
writetable(lengths, [outputPath '\processedLengths.txt'])
writetable(fractureArea, [outputPath '\fractureAreas.txt'])

end