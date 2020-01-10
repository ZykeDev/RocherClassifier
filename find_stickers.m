function [n, centers, radii] = find_stickers(im, box)
%COMPUTE_STICKERS
    % Find areas that correspond to the white stickers
    % Count them and save their positions
    
    [r, c, ~] = size(im);
    n = 0;          % Stickers counter
    
    avgSticker = [213*0.5/255, 196*0.5/255, 165*0.6/255]; % TODO better
    overlapfactor = 0;
        
    %% Find all small circles
    maxRadius = ceil(box.majax / box.expectedNumber * 1.1);
    minRadius = floor(maxRadius * 0.3);
     
    sensitivity = 0.97;
    [stickersC, stickersR] = imfindcircles(im, [minRadius, maxRadius], 'ObjectPolarity', 'bright', 'Sensitivity', sensitivity, 'Method', 'twostage');
    
    %% Compute the color variance of each circle
    possibleIndexs = [];
    
    for i = 1 : length(stickersR)       
        cx = round(stickersC(i, 1));
        cy = round(stickersC(i, 2));
        rad = floor(stickersR(i));
        
        % Ignore edge cases for now
        if cx < rad || cy < rad || cx + rad > r || cy + rad > c
            continue;
        end
        
        % Mask the boundig box with the circle
        bbox = im(cx-rad : cx+rad, cy-rad : cy+rad, 1:end);
        [bboxR, bboxC, ~] = size(bbox);

        [W, H] = meshgrid(1:bboxR, 1:bboxC);
        mask = sqrt((W-rad).^2 + (H-rad).^2) <= rad;
        
        R = bbox(:, :, 1);
        G = bbox(:, :, 2);
        B = bbox(:, :, 3);
       
        mR = mean(R(mask));
        mG = mean(G(mask));
        mB = mean(B(mask));
        
        if mR > 0 && mG > 0 && mB > 0
            if true
                variance = [var(R(mask)), var(G(mask)), var(B(mask))];
                variance = mean(variance);
                if variance < 0.03
                    possibleIndexs = [possibleIndexs, i];
                end
            end
        end
    end
   
    if isempty(possibleIndexs)
        centers = [];
        radii = [];
        return
    end
    
    %% Filter circles
    filteredC = [];
    filteredR = [];
    for i = 1 : length(possibleIndexs)
        fx = stickersC(i, 1);
        fy = stickersC(i, 2);
        filteredC = [filteredC; [fx, fy]];
        filteredR = [filteredR; stickersR(i)];
    end
    
    [filteredC, filteredR] = remove_overlaps(filteredC, filteredR, overlapfactor, []);
    
    centers = filteredC;
    radii = filteredR;
    
end

% Returns true if a set of values is close to a set of targets (within range)
function res = isWithinRange(values, targets, range)
    res = true;
    for i = 1 : length(values)
        res = res && values(i) > targets(i)-range && values(i) < targets(i)+range;
    end
end


