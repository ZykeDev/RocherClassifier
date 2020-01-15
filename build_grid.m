function grid = build_grid(box)
%BUILD_GRID Builds a custom grid for square boxes using voronoi

    scale = box.majax;
    
    edgeA = 0.16 * scale; 
    baseA = edgeA;
    distA = 0.233 * scale;
    edgeB = 0.28 * scale;
    baseB = edgeB;
    distB = 0.22 * scale;
    
    % List of points (x, y)
    grid = [];

    %% First half
    for i = 0 : 1
        point = [baseA + (distA*i), edgeA];
        grid = [grid; point];

        for j = 1 : 3
            point = [baseA + (distA*i), edgeA + distA*j];
            grid = [grid; point];
        end
    end

    point = [baseB, edgeB];
    grid = [grid; point];

    for j = 1 : 2
        point = [baseB, edgeB + distB*j];
        grid = [grid; point];
    end



    %% Second half
    baseA = (edgeA*2 + distA + distA/2);
    baseB = (edgeB*2 + distB);

    for i = 0 : 1
        point = [baseA + (distA*i), edgeA];
        grid = [grid; point];

        for j = 1 : 3
            point = [baseA + (distA*i), edgeA + distA*j];
            grid = [grid; point];
        end
    end

    point = [baseB, edgeB];
    grid = [grid; point];

    for j = 1 : 2
        point = [baseB, edgeB + distB*j];
        grid = [grid; point];
    end

    % Add missing midpoints
    mid1 = [edgeB + distB, edgeB];
    mid2 = [edgeB + distB, edgeB + distB*2];

    grid = [grid; mid1; mid2];


end

