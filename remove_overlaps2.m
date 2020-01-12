function [centers, radii] = remove_overlaps2(probs, maxoverlap)
%REMOVE_OVERLAPS If 2 or more circles overlap, remove all but one of them

    % Do nothing if there is no significant number of radii
    if length(probs) <= 1
        return
    end
    
    centers = [probs(:, 1), probs(:, 2)];
    radii = probs(:, 3);
    vars = probs(:, 4);
    
    for i = 1 : length(radii) - 1
        for j = i + 1 : length(radii)
            tolerance = (radii(i) + radii(j)) * maxoverlap;
            cdist = sqrt((centers(i,1) - centers(j,1)) .^2 + (centers(i,2) - centers(j,2)) .^2);
            rdist = radii(i) + radii(j) - tolerance;

            if cdist < rdist && radii(j) > 0 
                if vars(i) == vars(j)
                    if radii(i) > radii(j)
                        centers(j, 1) = 0;
                        centers(j, 2) = 0;
                        radii(j) = 0;
                    else
                        centers(i, 1) = 0;
                        centers(i, 2) = 0;
                        radii(i) = 0;
                        break;
                    end
                else
                    if vars(i) < vars(j)
                        centers(j, 1) = 0;
                        centers(j, 2) = 0;
                        radii(j) = 0;
                    else
                        centers(i, 1) = 0;
                        centers(i, 2) = 0;
                        radii(i) = 0;
                        break;
                    end
                        
                end
            end
        end
    end    

    cx = centers(:, 1);
    cy = centers(:, 2);

    cx(cx == 0) = [];
    cy(cy == 0) = [];
    centers = [cx, cy];
    radii(radii == 0) = [];
end


%% Returns true if there is 1 and only 1 sticker within a circle
function res = hasSticker(center, radius, stickers)
    res = false;
    foundNumber = 0;
    
    if stickers.number == 0
        return
    end
       
    for i = 1 : length(stickers.radii)
        sc = stickers.centers(i, :);
        if dist(center, sc) < radius
            foundNumber = foundNumber + 1;
            res = true;
        end
    end

    % TODO Needed? 
    if foundNumber > 1
        res = false;
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

%% Compute the variance of a set of values
function v = variance()

end


