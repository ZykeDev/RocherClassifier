function srp = compute_srp(img, sc, box)
%COMPUTE_SRP 

    [r, c, ~] = size(img);
    srp = [];
    
    
    if box.type == "RECT"
        % For every row of the box
        [ns, coords] = size(sc);
        distances = [];
        targets = [];
        for i = 1 : ns
            sofar = size(distances);
            if sofar(1) > 5 || isempty(sc)
                continue
            end
            
            [targetc, distance] = find_closest(sc(i, :), sc, box.orientation);
            if targetc(1) == -1
                continue;
            end

            targets = [targets; targetc];
            distances = [distances; distance];
            %plot([sc(i, 1), targetc(1)], [sc(i, 2), targetc(2)], "LineWidth", 2);
        end

        thissrp = zeros([1, 5]);
        for d = 1 : size(distances)
            if distances(d) < box.majax/6 && distances(d) > 0
                thissrp(d) = 1;
            end
        end
        
        srp = [srp; thissrp(1:5)];
           
    elseif box.type == "SQUARE"
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
