function srp = compute_srp(img, sc, box)
%COMPUTE_SRP 

    [r, c, ~] = size(img);
    srp = [];
    
    
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
            maskedRow = maskRGB(img, rowmask);
                      
            % Only work with the middle 2 rows (?) TODO for now
            if g ~= 4 && g ~= 8
                continue;
            end
            
            [ns, coords] = size(sc);
            for i = 1 : ns
                [targetc, distance] = find_closest(sc(i, :), sc);
                
                disp(distance);
            end
           
            
        end
    elseif box.type == "SQUARE"
        % TODO
        return
    end
    



end


%% Finds the center closest to the one in input
function [targetc, minDist] = find_closest(thisc, sc)
    minDist = 100000; % TODO fix
    %targetc = [0, 0];
    [ns, coords] = size(sc);
    for i = 1 : ns
        candidatec = [sc(i, 1), sc(i, 2)];
        if candidatec(1) == thisc(1) && candidatec(2) == thisc(2)
            continue;
        end

        thisDist = dist(thisc, candidatec);
        if thisDist < minDist
            minDist = thisDist;
            targetc = sc(i);
        end
    end
end


%% Computes the euclidian disntace between 2 points a and b
function d = dist(p1, p2)
    a = round(p1(1));
    b = round(p2(1));
    c = round(p1(2));
    d = round(p2(2));

    d = round(sqrt((a-b)^2 + (c-d)^2));
end