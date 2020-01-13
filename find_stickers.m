function rows = find_stickers(im, box)
%FIND_STICKERS  Find areas that correspond to the white stickers
    
    [r, c, ~] = size(im);    
    rows = [];
    
    if box.type == "RECT"
        % For every row of the box
        for g = 0 : 4 : 15
            grid = box.grid(g+1 : g+4, :);
            xi = grid(:, 1);
            yi = grid(:, 2);
            
            % Fix points out of the image
            xi(xi > r) = r;
            yi(yi > c) = c;
            
            rowmask = poly2mask(xi, yi, r, c);
            maskedRow = maskRGB(im, rowmask);
                      
            % Only work with the middle 2 rows (?) TODO for now
            if g ~= 4 && g ~= 8
                continue;
            end
            
            % Find all circles in the region
            [sc, sr] = find_circles(maskedRow, box);
            imshow(maskedRow);
            viscircles(sc, sr, "Color", "r");
            
            % Save the stickers of the row
            row.sn = length(sr); 
            row.sc = sc;
            row.sr = sr;
            rows = [rows; row];
        end
    elseif box.type == "SQUARE"
        % TODO
        return
    end

end

%% Finds all circles in an image
function [sc, sr] = find_circles(img, box)
	[r, c, ~] = size(img);

    % Calculate an appropiate radius range
    if box.type == "SQUARE"     % TODO fix square's radii
        maxRad = ceil(box.majax / (box.expectedNumber * 1.1));
        minRad = floor(maxRad * 0.3);
        
    elseif box.type == "RECT"
        maxRad = floor((box.majax / box.expectedNumber + 1) / 2);
        minRad = floor(maxRad * 0.75);
    end
    
    sensitivity = 0.97;
    edgethresh = 0.4;
    colorthresh = 0.35;     % Colors below wich are not of a sticker
    [sc, sr] = imfindcircles(img, [minRad, maxRad], 'ObjectPolarity', 'bright', 'Sensitivity', sensitivity, 'EdgeThreshold', edgethresh, 'Method', 'twostage');
    
    for i = 1 : length(sr)
        cx = sc(i, 1);
        cy = sc(i, 2);
        rad = sr(i);
              
        % Ignore edge cases
        if cx <= rad || cy <= rad || cx + rad > r || cy + rad > c
            continue;
        end
        
        % Mask the boundig box with the circle
        bbox = img(round(cy-rad) : round(cy+rad), round(cx-rad) : round(cx+rad), :);
        [bboxR, bboxC, ~] = size(bbox);
        
        [W, H] = meshgrid(1:bboxR, 1:bboxC);
        mask = sqrt((W-rad).^2 + (H-rad).^2) <= rad;
        
        RGB = maskRGB(bbox, mask);
        M = mean(mean(mean(RGB, 3)));
        
        % Remove circles with an average color lower than the Threshold
        if M <= colorthresh 
            sc(i, 1) = 0;
            sc(i, 2) = 0;
            sr(i) = 0;
        end
    end
    
    % Rebuild the arrays
    cx = sc(:, 1);
    cy = sc(:, 2);

    cx(cx == 0) = [];
    cy(cy == 0) = [];
    sc = [cx, cy];
    sr(sr == 0) = [];
end


%% Returns true if a set of values is close to a set of targets (within range)
% TODO remove
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





