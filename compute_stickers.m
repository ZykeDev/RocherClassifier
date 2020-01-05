function [n, pos] = compute_stickers(im)
%COMPUTE_STICKERS
    % Find areas that correspond to the white stickers
    % Count them and save their positions?
    
    [r, c] = size(im);
    bw = im; 
    
    n = 0;          % Stickers counter
    pos = [];       % List of their positions
    
    maxMajorAxis = 40;
    minMajorAxis = 10;
    maxRatio = 2; %1.85;
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

