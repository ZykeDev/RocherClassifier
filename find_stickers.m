function [n, centers, radii] = find_stickers(im)
%COMPUTE_STICKERS
    % Find areas that correspond to the white stickers
    % Count them and save their positions
    
    [r, c, ~] = size(im);
    n = 0;          % Stickers counter
    
    maxNumberOfStickers = 24;
    avgSticker = [213*0.5/255, 196*0.5/255, 165*0.6/255];
    overlapfactor = 0.5;
    
    
    %% Find all small circles (TODO fix range)
    [stickersC, stickersR] = imfindcircles(im, [18, 22], 'ObjectPolarity', 'bright', 'Sensitivity', 0.95, 'Method', 'twostage');
    
    %% Compute the average color of each circle
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
            %disp([mR, mG, mB, avgSticker(1), avgSticker(3), avgSticker(2)]);
            if isWithinRange(mR, avgSticker(1), 0.37)
                if isWithinRange(mG, avgSticker(2), 0.37)
                    if isWithinRange(mB, avgSticker(3), 0.37)
                        % Save the index
                        possibleIndexs = [possibleIndexs, i];
                    end
                end
            end
        end
    end

    n = length(possibleIndexs);
    if n > maxNumberOfStickers
       % TODO more in depth
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
    
    [filteredC, filteredR] = remove_overlaps(filteredC, filteredR, overlapfactor);
    
    centers = filteredC;
    radii = filteredR;
    
  

    
    
    return  
    
    bw = im; 
     
    maxMajorAxis = 40;
    minMajorAxis = 10;
    maxRatio = 1.85;
    minRatio = 0; %1.1;
  
    % Apply regionprops to detect ellipses
    s = regionprops(bw, {'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Orientation'});

    t = linspace(0, 2*pi, 50);
    
    hold on
    for k = 1:length(s)
        a = s(k).MajorAxisLength/2;
        b = s(k).MinorAxisLength/2;
               
        if a <= maxMajorAxis && a >= minMajorAxis 
            if a < b*maxRatio && a > b*minRatio
                Xc = s(k).Centroid(1);
                Yc = s(k).Centroid(2);
                phi = deg2rad(-s(k).Orientation);
                x = Xc + a*cos(t)*cos(phi) - b*sin(t)*sin(phi);
                y = Yc + a*cos(t)*sin(phi) + b*sin(t)*cos(phi);
                plot(x, y, 'r', 'Linewidth', 3)
                n = n + 1;
            end
        end
    end
    hold off
    disp(n);

end


function res = isWithinRange(value, target, range)
    res = false;
    if value > target-range && value < target+range
        res = true;
    end
end


