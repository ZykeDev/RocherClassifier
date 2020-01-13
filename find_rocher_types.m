function rsh = find_rocher_types(img, box)
%FIND_ROCHER_TYPES

    [r, c, ~] = size(img);
    rsh = [];
    
    if box.type == "RECT"
        % For every row of the box
        for g = 0 : 4 : 15
            grid = box.grid(g+1 : g+4, :);
            xi = grid(:, 1);
            yi = grid(:, 2);
            
            % Segment every slot by divinging by 6 the row
            % TODO finish
            Ax = (xi(1)+xi(2))/6;
            Ay = (yi(1)+yi(2))/2;
            
            midAx = (xi(1)+xi(2))/2;
            midAy = (yi(1)+yi(2))/2;
            
            midBx = (xi(3)+xi(4))/2;
            midBy = (yi(3)+yi(4))/2;
            
            rowmask = poly2mask(xi, yi, r, c);
            maskedRow = maskRGB(img, rowmask);
            
            % Compute the average color of each segment (computes the row for now)
            M = mean(mean(mean(maskedRow, 3)));
            if M >= 0.04                     % White
                rsh = [rsh; [1, 1, 1, 1, 1, 1]];
            elseif M < 0.04 && M >= 0.025    % Classic
                rsh = [rsh; [0, 0, 0, 0, 0, 0]];
            else                             % Black
                rsh = [rsh; [2, 2, 2, 2, 2, 2]];
            end
        end
        
    elseif box.type == "SQUARE"
        % TODO actually impelemnt this
        % Voronoi?
        for g = 0 : 4 : 15
        	rsh = [rsh; [0, 0, 0, 0, 0, 0]];
        end
    end
    
   
end

