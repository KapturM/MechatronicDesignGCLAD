% Servo move a given position
function status = moveServoXY(x_mm, y_mm)
    disp([' Moving servo to X: ', num2str(x_mm), ' mm, Y: ', num2str(y_mm), ' mm']);
    pause(0.5);  % simulate move
    status = true;
end