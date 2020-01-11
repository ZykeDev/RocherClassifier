function proj = proj_grid(box, grid)
%PROJ_GRID Projects a custom rocher grid on top of the box

    squareRatio = 0.33;
    rectRatio = 1;
    rochersPerSide = 6 + squareRatio;
    
    if box.type == "SQUARE"
        % Length of the side of the box
        side = mean([box.majax, box.minax]);
        squareLength = side / rochersPerSide;
    end

    layout = ones(box.originalSize);
    final.layout = layout;

    %[v, c] = voronoin([box.stickers.centers(:, 1)', box.stickers.centers(:, 2)']);
    %voronoi(box.stickers.centers(:, 1), box.stickers.centers(:, 2));
    
    
    % Rotate the grid to match the box
    theta = box.angle;
    rotmat = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    
    gridCenter = [box.minax/2, box.majax/2];
    
    proj = [];
    for i = 1 : length(grid)
        rotated = rotmat .* [grid(1)-gridCenter(1); grid(2)-gridCenter(2)];
        nx = grid(i, 1) + gridCenter(1) + rotated(1);
        ny = grid(i, 2) + gridCenter(2) + rotated(2);
        proj = [proj; [nx, ny]];
    end
    
    %voronoi(proj(:, 1), proj(:, 2));
    voronoi(proj(:, 1), proj(:, 2));



end

