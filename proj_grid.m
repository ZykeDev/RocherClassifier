function proj = proj_grid(box, grid)
%PROJ_GRID Projects a custom rocher grid on top of the box
   
    squareRatio = 0.33;
    rochersPerSide = 6 + squareRatio;
    
    if box.type == "SQUARE"
        % Length of the side of the box
        side = mean([box.majax, box.minax]);
        squareLength = side / rochersPerSide;
    end

    %[v, c] = voronoin([box.stickers.centers(:, 1)', box.stickers.centers(:, 2)']);
    %voronoi(box.stickers.centers(:, 1), box.stickers.centers(:, 2));
    
    
    % Rotate the grid to match the box
    theta = box.angle;
    rotmat = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    
    gridCenter = [box.minax/2, box.majax/2];
    movement = [box.center(1)-box.majax/2, box.center(2)-box.majax/2];
    
    proj = [];
    proj(:, 1) = grid(:, 1) + movement(1);
    proj(:, 2) = grid(:, 2) + movement(2);
    
    angle = box.angle;
    Xc = box.center(1);
    Yc = box.center(2);
    Xrot =  (proj(:, 1)-Xc)*cosd(angle) + (proj(:, 2)-Yc)*sind(angle) + Xc;
    Yrot = -(proj(:, 1)-Xc)*sind(angle) + (proj(:, 2)-Yc)*cosd(angle) + Yc;
    proj(:, 1) = Xrot;
    proj(:, 2) = Yrot;
        
    
    h = voronoi(proj(:, 1), proj(:, 2));
    for i = 1:length(h)
        h(i).LineWidth = 2;
    end



end

