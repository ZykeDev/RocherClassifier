function [centers, radii] = remove_overlaps(centers, radii, overlapfactor)
%REMOVE_OVERLAPS Summary of this function goes here
    for i = 1 : length(centers) - 1
        s = i + 1;
        for j = s : length(centers)
            tolerance = (radii(i) + radii(j)) * overlapfactor;
            cdist = sqrt((centers(i,1) - centers(j,1)) .^2 + (centers(i,2) - centers(j,2)) .^2);
            rdist = radii(i) + radii(j) - tolerance;

            if cdist < rdist && radii(j) > 0
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

