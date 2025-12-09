function esp32_control_panel()
    % ================================
    % CONNECT TO ESP32
    % ================================
    port = "COM8";   % <- change if needed
    baud = 115200;
    esp = serialport(port, baud);
    configureTerminator(esp,"CR/LF");
    configureCallback(esp,"terminator",@(src,evt)esp_callback(src));
    
    % ================================
    % BUILD GUI
    % ================================
    fig = uifigure("Name","ESP32 Control Panel","Position",[100 50 1100 700]);
    fig.Color = [0.95 0.95 0.97];
    
    % Header
    pnlHeader = uipanel(fig,"Position",[0 650 1100 50],"BackgroundColor",[0.2 0.3 0.5]);
    uilabel(pnlHeader,"Text","ESP32 Dual Servo Controller","Position",[20 10 1060 30], ...
        "FontSize",20,"FontWeight","bold","FontColor",[1 1 1],"BackgroundColor",[0.2 0.3 0.5]);
    
    % ============ TOP LEFT - SERVO 1 ============
    pnlServo1 = uipanel(fig,"Position",[20 450 340 180],"Title","Servo 1", ...
        "FontSize",14,"FontWeight","bold","BackgroundColor",[0.97 1 0.97]);
    
    uilabel(pnlServo1,"Text","Angle (°):","Position",[20 130 80 22],"FontSize",11);
    angle1Spinner = uispinner(pnlServo1,"Position",[110 130 100 22],"Limits",[0 180],"Value",90, ...
        "ValueChangedFcn",@(src,~) updateSlider1(src.Value));
    
    lblAngle1 = uilabel(pnlServo1,"Text","90°","Position",[230 130 80 22], ...
        "FontSize",14,"FontWeight","bold","HorizontalAlignment","center");
    
    uilabel(pnlServo1,"Text","0°","Position",[20 90 30 20],"FontSize",10);
    slider1 = uislider(pnlServo1,"Position",[55 100 240 3], ...
        "Limits",[0 180],"Value",90, ...
        "ValueChangedFcn",@(src,~) moveServo1(src.Value));
    uilabel(pnlServo1,"Text","180°","Position",[295 90 40 20],"FontSize",10);
    
    btnMove1 = uibutton(pnlServo1,"push","Text","➤ MOVE TO POSITION", ...
        "Position",[70 45 200 35], ...
        "FontSize",11,"FontWeight","bold", ...
        "BackgroundColor",[0.3 0.5 0.9],"FontColor",[1 1 1], ...
        "ButtonPushedFcn", @(~,~) moveServo1(angle1Spinner.Value));
    
    btnHome1 = uibutton(pnlServo1,"push","Text","🏠 90°", ...
        "Position",[70 5 80 30], ...
        "FontSize",10, ...
        "ButtonPushedFcn", @(~,~) setServo1(90));
    
    btnMin1 = uibutton(pnlServo1,"push","Text","◀ 0°", ...
        "Position",[160 5 50 30], ...
        "FontSize",10, ...
        "ButtonPushedFcn", @(~,~) setServo1(0));
    
    btnMax1 = uibutton(pnlServo1,"push","Text","180° ▶", ...
        "Position",[220 5 50 30], ...
        "FontSize",10, ...
        "ButtonPushedFcn", @(~,~) setServo1(180));
    
    % ============ TOP CENTER - SERVO 2 ============
    pnlServo2 = uipanel(fig,"Position",[380 450 340 180],"Title","Servo 2", ...
        "FontSize",14,"FontWeight","bold","BackgroundColor",[1 0.97 1]);
    
    uilabel(pnlServo2,"Text","Angle (°):","Position",[20 130 80 22],"FontSize",11);
    angle2Spinner = uispinner(pnlServo2,"Position",[110 130 100 22],"Limits",[0 180],"Value",90, ...
        "ValueChangedFcn",@(src,~) updateSlider2(src.Value));
    
    lblAngle2 = uilabel(pnlServo2,"Text","90°","Position",[230 130 80 22], ...
        "FontSize",14,"FontWeight","bold","HorizontalAlignment","center");
    
    uilabel(pnlServo2,"Text","0°","Position",[20 90 30 20],"FontSize",10);
    slider2 = uislider(pnlServo2,"Position",[55 100 240 3], ...
        "Limits",[0 180],"Value",90, ...
        "ValueChangedFcn",@(src,~) moveServo2(src.Value));
    uilabel(pnlServo2,"Text","180°","Position",[295 90 40 20],"FontSize",10);
    
    btnMove2 = uibutton(pnlServo2,"push","Text","➤ MOVE TO POSITION", ...
        "Position",[70 45 200 35], ...
        "FontSize",11,"FontWeight","bold", ...
        "BackgroundColor",[0.6 0.3 0.9],"FontColor",[1 1 1], ...
        "ButtonPushedFcn", @(~,~) moveServo2(angle2Spinner.Value));
    
    btnHome2 = uibutton(pnlServo2,"push","Text","🏠 90°", ...
        "Position",[70 5 80 30], ...
        "FontSize",10, ...
        "ButtonPushedFcn", @(~,~) setServo2(90));
    
    btnMin2 = uibutton(pnlServo2,"push","Text","◀ 0°", ...
        "Position",[160 5 50 30], ...
        "FontSize",10, ...
        "ButtonPushedFcn", @(~,~) setServo2(0));
    
    btnMax2 = uibutton(pnlServo2,"push","Text","180° ▶", ...
        "Position",[220 5 50 30], ...
        "FontSize",10, ...
        "ButtonPushedFcn", @(~,~) setServo2(180));
    
    % ============ TOP RIGHT - LED CONTROL ============
    pnlLED = uipanel(fig,"Position",[740 450 340 180],"Title","LED Control", ...
        "FontSize",14,"FontWeight","bold","BackgroundColor",[0.97 0.97 1]);
    
    btnLedOn = uibutton(pnlLED,"push","Text","🔆 LED ON", ...
        "Position",[70 90 200 50], ...
        "FontSize",14,"FontWeight","bold", ...
        "BackgroundColor",[0.2 0.8 0.3],"FontColor",[1 1 1], ...
        "ButtonPushedFcn", @(~,~) send("LED ON"));
    
    btnLedOff = uibutton(pnlLED,"push","Text","🔅 LED OFF", ...
        "Position",[70 30 200 50], ...
        "FontSize",14,"FontWeight","bold", ...
        "BackgroundColor",[0.8 0.2 0.2],"FontColor",[1 1 1], ...
        "ButtonPushedFcn", @(~,~) send("LED OFF"));
    
    % ============ MIDDLE LEFT - 2D POSITION GRID ============
    pnlGrid = uipanel(fig,"Position",[20 20 540 410],"Title","2D Position Control (Servo 1 → Servo 2)", ...
        "FontSize",14,"FontWeight","bold","BackgroundColor",[1 1 1]);
    
    ax = uiaxes(pnlGrid,"Position",[30 30 480 340]);
    ax.XLim = [0 180];
    ax.YLim = [0 180];
    ax.XLabel.String = 'Servo 1 Angle (°)';
    ax.YLabel.String = 'Servo 2 Angle (°)';
    ax.Title.String = 'Click to set position';
    ax.GridColor = [0.5 0.5 0.5];
    ax.GridAlpha = 0.3;
    grid(ax, 'on');
    ax.XTick = 0:30:180;
    ax.YTick = 0:30:180;
    ax.ButtonDownFcn = @gridClick;
    
    % Current position marker
    hold(ax, 'on');
    posMarker = plot(ax, 90, 90, 'ro', 'MarkerSize', 15, 'LineWidth', 3, 'MarkerFaceColor', 'r');
    hold(ax, 'off');
    
    % ============ MIDDLE RIGHT - LOG ============
    pnlLog = uipanel(fig,"Position",[580 20 500 410],"Title","Communication Log", ...
        "FontSize",14,"FontWeight","bold","BackgroundColor",[1 1 1]);
    
    logBox = uitextarea(pnlLog,"Position",[10 50 480 340], ...
        "Editable","off","FontSize",9,"FontName","Courier New", ...
        "BackgroundColor",[0.05 0.05 0.1],"FontColor",[0.2 1 0.3]);
    
    btnClearLog = uibutton(pnlLog,"push","Text","🗑 Clear Log", ...
        "Position",[185 10 130 30], ...
        "FontSize",10, ...
        "BackgroundColor",[0.7 0.7 0.7], ...
        "ButtonPushedFcn", @(~,~) clearLog());
    
    % Store elements for callbacks
    fig.UserData.esp = esp;
    fig.UserData.log = logBox;
    fig.UserData.marker = posMarker;
    
    % Initial log message
    append_log("=== ESP32 Connected ===");
    append_log(sprintf("Port: %s | Baud: %d", port, baud));
    append_log("=======================");
    
    % ================================
    % Nested functions
    % ================================
    function send(cmd)
        if strlength(cmd) > 0
            writeline(esp, cmd);
            append_log(">> " + cmd);
        end
    end
    
    function moveServo1(angle)
        angle = round(angle);
        angle1Spinner.Value = angle;
        slider1.Value = angle;
        lblAngle1.Text = sprintf('%d°', angle);
        send(sprintf("SERVO MOVE: 1, %d", angle));
        updateMarker();
    end
    
    function moveServo2(angle)
        angle = round(angle);
        angle2Spinner.Value = angle;
        slider2.Value = angle;
        lblAngle2.Text = sprintf('%d°', angle);
        send(sprintf("SERVO MOVE: 2, %d", angle));
        updateMarker();
    end
    
    function setServo1(angle)
        moveServo1(angle);
    end
    
    function setServo2(angle)
        moveServo2(angle);
    end
    
    function updateSlider1(angle)
        slider1.Value = angle;
        lblAngle1.Text = sprintf('%d°', round(angle));
    end
    
    function updateSlider2(angle)
        slider2.Value = angle;
        lblAngle2.Text = sprintf('%d°', round(angle));
    end
    
    function gridClick(src, event)
        pt = event.IntersectionPoint;
        angle1 = round(pt(1));
        angle2 = round(pt(2));
        
        % Clamp values
        angle1 = max(0, min(180, angle1));
        angle2 = max(0, min(180, angle2));
        
        % Move servo 1 first, then servo 2
        moveServo1(angle1);
        pause(0.1);
        moveServo2(angle2);
    end
    
    function updateMarker()
        posMarker.XData = angle1Spinner.Value;
        posMarker.YData = angle2Spinner.Value;
    end
    
    function append_log(msg)
        timestamp = string(datetime('now','Format','HH:mm:ss'));
        logBox.Value = [logBox.Value; "[" + timestamp + "] " + string(msg)];
        scroll(logBox,"bottom");
        drawnow;
    end
    
    function clearLog()
        logBox.Value = {' '};
        drawnow;
        append_log("=== Log Cleared ===");
    end
    
    function esp_callback(src)
        line = readline(src);
        append_log("<< " + line);
    end
end