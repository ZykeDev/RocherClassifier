function rsh = find_rocher_types(img, box)
%FIND_ROCHER_TYPES

    [r, c, ~] = size(im);
    rsh = [];
    
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
            
            % Compute the average color of each segment
            
            
            
            M = mean(mean(mean(RGB, 3)));
            
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
    end
    
    
    



end

