function [n, centers, radii] = find_stickers(im, box)
%COMPUTE_STICKERS
    % Find areas that correspond to the white stickers
    % Count them and save their positions
    
    [r, c, ~] = size(im);
    n = 0;          % Stickers counter
    
    avgSticker = [175/255, 148/255, 103/255];
    overlapfactor = 0;
    
    if box.type == "RECT"
        % For every row of the box
        for g = 0 : 4 : 16
            grid = box.grid(g+1 : g+4, :);
            disp(box.grid)
            xi = grid(:, 1);
            yi = grid(:, 2);
        
            xi(xi > r) = r;
            yi(yi > c) = c;

            rowmask = poly2mask(xi, yi, r, c);
            maskedRow = maskRGB(im, rowmask);
            
            % TODO try to find the best 4 circles with small variance
            % (candidate stickers)
        end
    end
    
    
        
    %% Find all small circles
    if box.type == "SQUARE"
        maxRadius = ceil(box.majax / (box.expectedNumber * 1.1));
        minRadius = floor(maxRadius * 0.3);
        
    elseif box.type == "RECT"
        maxRadius = floor((box.majax / box.expectedNumber + 1) / 2);
        minRadius = floor(maxRadius * 0.75);
    end
   
    sensitivity = 0.97;
    [stickersC, stickersR] = imfindcircles(im, [minRadius, maxRadius], 'ObjectPolarity', 'bright', 'Sensitivity', sensitivity, 'Method', 'twostage');
    
    %% Compute the color variance of each circle
    possibleIndexs = [];
    
    for i = 1 : length(stickersR)       
        cx = round(stickersC(i, 1));
        cy = round(stickersC(i, 2));
        rad = floor(stickersR(i));
              
        % Ignore edge cases for now
        if cx <= rad || cy <= rad || cx + rad > r || cy + rad > c
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
        
        % Lighter than gray
        if mR > 0 && mG > 0 && mB > 0
            variance = [var(R(mask)), var(G(mask)), var(B(mask))];
            variance = mean(variance);
 
            if isWithinRange([mR, mG, mB], avgSticker, 0.1)
                possibleIndexs = [possibleIndexs, i];
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
        idx = possibleIndexs(i);
        fx = stickersC(i, 1);
        fy = stickersC(i, 2);
        filteredC = [filteredC; [fx, fy]];
        filteredR = [filteredR; stickersR(i)];
    end
    
    [filteredC, filteredR] = remove_overlaps(filteredC, filteredR, overlapfactor, []);
    
    centers = filteredC;
    radii = filteredR;
    viscircles(centers, radii);
    
end


%% Returns true if a set of values is close to a set of targets (within range)
function res = isWithinRange(values, targets, range)
    res = true;
    for i = 1 : length(values)
        res = res && values(i) > targets(i)-range && values(i) < targets(i)+range;
    end
end



%% Masks every RGB channel with a mask and returns the concatenated img     
function masked = maskRGB(img, mask)
    R = img(:, :, 1);
    G = img(:, :, 2);
    B = img(:, :, 3);

    R(~mask) = 0;
    G(~mask) = 0;
    B(~mask) = 0;
    
    masked = cat(3, R, G, B);

end





