function updateRasterUI(uiMap, xi, yi, x_pos, y_pos, rowNum, numRows, measurementCount, totalPoints)
    % updateRasterUI - prints a colored ASCII map using cprintf
    %
    % uiMap           -> current map of 'o' (pending) and 'x' (measured)
    % xi, yi          -> current column/row being measured
    % x_pos, y_pos    -> coordinates in mm
    % rowNum, numRows -> current row and total rows
    % measurementCount, totalPoints -> progress info

    % Clear command window
    clc;
    
    % Progress
    progressPercent = measurementCount / totalPoints * 100;
    
    % Header
    fprintf("=============================\n");
    fprintf("      XY Raster Scan         \n");
    fprintf("=============================\n");
    fprintf("Measuring Point: %d/%d\n", measurementCount, totalPoints);
    fprintf("Progress: %.1f %%\n", progressPercent);
    fprintf("Current XY: X=%.2f mm, Y=%.2f mm\n", x_pos, y_pos);
    fprintf("Row %d/%d\n", rowNum, numRows);
    fprintf("=============================\n\n");
    
    % Print the grid with colored boxes
    [numY,numX] = size(uiMap);
    fprintf("Measurement Grid:\n\n");
    for r = 1:numY
        for c = 1:numX
            if uiMap(r,c) == 'x'
                % Measured: brackets white, box green
                cprintf('White','[');        % left bracket white
                cprintf('Green','■');        % green box
                cprintf('White','] ');       % right bracket white
            else
                % Pending: all white
                fprintf('[ ] ');
            end
        end
        fprintf('\n');
    end
    fprintf("\n=====================================================\n");
end
