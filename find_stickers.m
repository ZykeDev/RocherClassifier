function rows = find_stickers(img, box)
%FIND_STICKERS  Find areas that correspond to the white stickers
    
    [r, c, ~] = size(img);    
    rows = [];
    
    if box.type == "RECT"
        edgethresh = 0.4;
        
        % For every row of the box
        for g = 0 : 4 : 15
            grid = box.grid(g+1 : g+4, :);
            xi = grid(:, 1);
            yi = grid(:, 2);
            
            % Fix points out of the image
            xi(xi > r) = r;
            yi(yi > c) = c;
            
            rowmask = poly2mask(xi, yi, r, c);
            maskedRow = maskRGB(img, rowmask);
                      
            % Find all circles in the region
            [sc, sr] = find_circles(maskedRow, box, edgethresh);
            [sc, sr] = remove_overlaps(sc, sr);
                        
            % Save the stickers of the row
            row.sn = length(sr); 
            row.sc = sc;
            row.sr = sr;
            rows = [rows; row];
        end
    elseif box.type == "SQUARE"
        edgethresh = 0.45;
        [sc, sr] = find_circles(img, box, edgethresh);
        [sc, sr] = remove_overlaps(sc, sr);
        [sc, sr] = remove_outliers(img, sc, sr);

        plot(sc(:, 1), sc(:, 2), 'ro', 'MarkerSize', 20, "LineWidth", 5, "Color", "blue");
        
        if isempty(sr)
            %rows = [rows; [0, 0, 0, 0, 0, 0]];
            row.sn = 0; 
            row.sc = [];
            row.sr = [];

            rows = [rows; row];
        else
            row.sn = length(sr); 
            row.sc = sc;
            row.sr = sr;

            rows = [rows; row];
        end
    end

end

function [sc, sr] = remove_outliers(img, sc, sr)
    [r, c, ~] = size(img);
    colorthresh = 0.44;
    
    if length(sr) <= 1
        return
    end
    
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
       
    if isempty(sr)
        sc = [];
        sr = [];
    else
        % Rebuild the arrays
        cx = sc(:, 1);
        cy = sc(:, 2);
        
        cx(cx == 0) = [];
        cy(cy == 0) = [];
        sc = [cx, cy];
        sr(sr == 0) = [];
    end
    
   
      
end


%% Finds all circles in an image
function [sc, sr] = find_circles(img, box, edgethresh)
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
    
    if isempty(sr)
        sc = [];
        sr = [];
    else
        % Rebuild the arrays
        cx = sc(:, 1);
        cy = sc(:, 2);

        cx(cx == 0) = [];
        cy(cy == 0) = [];
        sc = [cx, cy];
        sr(sr == 0) = [];
    end
end


%% Removes overlapping circles
function [sc, sr] = remove_overlaps(sc, sr)
    if length(sr) <= 1
        return
    end
    
    for i = 1 : length(sr) - 1
        for j = i + 1 : length(sr)
            cdist = sqrt((sc(i,1) - sc(j,1)) .^2 + (sc(i,2) - sc(j,2)) .^2);
            rdist = sr(i) + sr(j) + 1;

            if cdist < rdist && sr(j) > 0
                if sr(i) >= sr(j)
                	sc(i, 1) = 0;
                    sc(i, 2) = 0;
                    sr(i) = 0;
                    break;
                else
                    sc(j, 1) = 0;
                    sc(j, 2) = 0;
                    sr(j) = 0; 
                end
            end
        end
    end
    
    cx = sc(:, 1);
    cy = sc(:, 2);

    cx(cx == 0) = [];
    cy(cy == 0) = [];
    sc = [cx, cy];
    sr(sr == 0) = [];        
end



