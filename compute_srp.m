function srp = compute_srp(img, sc, box)
%COMPUTE_SRP 

    [r, c, ~] = size(img);
    srp = [];
    
    
    if box.type == "RECT"
        % For every row of the box
        [ns, coords] = size(sc);
        distances = [];
        targets = [];
        origins = [];
        
        for i = 1 : ns
            sofar = size(distances);
            if sofar(1) > 5 || isempty(sc)
                continue
            end
            
            [targetc, distance] = find_closest(sc(i, :), sc, box.orientation);
            if targetc(1) == -1
                continue;
            end
            
            origins = [origins; sc(i, :)];
            targets = [targets; targetc];
            distances = [distances; distance];
        end

        thissrp = zeros([1, 5]);
        for d = 1 : size(distances)
            if distances(d) > box.majax/6 && distances(d) > 0
                thissrp(d) = 1;

                % Display where there's an error on the box
                tc = targets(d, :);
                oc = origins(d, :);
                m = midpoint(tc, oc);
                plot(m(1), m(2), 'ro', 'MarkerSize', 30, "LineWidth", 5);
            elseif distances(d) > box.majax/3 && ditances(d) > 0
                thissrp(d) = 1;
                thissrp(d+1) = 1;

                % Display where there's an error on the box
                tc = targets(d, :);
                oc = origins(d, :);
                m = midpoint(tc, oc);
                m1 = midpoint(tc,m);
                m2 = midpoint(m, oc);
                plot(m1(1), m1(2), 'ro', 'MarkerSize', 30, "LineWidth", 5);
                plot(m2(1), m2(2), 'ro', 'MarkerSize', 30, "LineWidth", 5);
            end

        end
        % Only select the first 5 values
        srp = [srp; thissrp(1:5)];
           
    elseif box.type == "SQUARE"
        % Create a voronoi grid to overlay on top of the box
        voronoigrid = build_grid(box);
        %proj_grid(box, voronoigrid);
        
        % TODO
        % For every region, try to find a sticker with its center within it
        % If there are no valid centers, the slot is empty
        % If there are more than 1, select the one closest to the center
        % For every empty slot, mark its center with a dot on the plot
        
        
        srp = [srp; ones([4, 5])];
    end
    

end


%% Finds the center closest to the one in input
function [targetc, minDist] = find_closest(thisc, sc, theta)
    minDist = 100000; % Arbitrarily large number, prob better to set it to image diagonal + 1
    targetc = [-1, -1];
    
    [ns, coords] = size(sc);
    for i = 1 : ns
        candidatec = [sc(i, 1), sc(i, 2)];
            if candidatec(1) == thisc(1) && candidatec(2) == thisc(2)
                continue;
            end
            
        if theta == 0
            thisDist = dist(thisc, candidatec);
            if thisDist < minDist
                minDist = thisDist;
                targetc = sc(i, :);
            end
            
        elseif theta > 0 && thisc(2) > candidatec(2)
            thisDist = dist(thisc, candidatec);
            if thisDist < minDist
                minDist = thisDist;
                targetc = sc(i, :);
            end
            
        elseif theta < 0 && thisc(2) < candidatec(2)
            thisDist = dist(thisc, candidatec);
            if thisDist < minDist
                minDist = thisDist;
                targetc = sc(i, :);
            end
        end
    end
    
    if minDist == 100000
        minDist = -1;
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


%% Finds the midpoint between p1 and p2 
function m = midpoint(p1, p2)
    m = (p1(:) + p2(:)).'/2;
end


