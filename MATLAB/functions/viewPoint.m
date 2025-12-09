% Function to view any measurement
function viewPoint(gridData, xIndex, yIndex, measurementIndex)
    point = gridData(yIndex, xIndex);
    meas = point.measurements(measurementIndex);
    
    figure;
    plot(meas.Time, meas.A, meas.Time, meas.B);
    title(sprintf("XY Point (%.2fmm, %.2fmm) | Measurement #%d", ...
                  point.X_mm, point.Y_mm, measurementIndex));
    xlabel("Time");
    ylabel("Voltage");
    legend("Channel A","Channel B");
    grid on;
    
    fprintf("\n===== Point Details =====\n");
    fprintf("X: %.2f mm  | Y: %.2f mm\n", point.X_mm, point.Y_mm);
    fprintf("Mean A (first repeat): %.4f\n", mean(point.measurements(1).A));
    fprintf("Mean B (first repeat): %.4f\n", mean(point.measurements(1).B));
    fprintf("=========================\n");
end