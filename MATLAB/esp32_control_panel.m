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
    fig = uifigure("Name","ESP32 Control Panel","Position",[200 100 900 650]);
    fig.Color = [0.95 0.95 0.97];
    
    % Header
    pnlHeader = uipanel(fig,"Position",[0 600 900 50],"BackgroundColor",[0.2 0.3 0.5]);
    uilabel(pnlHeader,"Text","ESP32 Interactive Controller","Position",[20 10 860 30], ...
        "FontSize",20,"FontWeight","bold","FontColor",[1 1 1],"BackgroundColor",[0.2 0.3 0.5]);
    
    % ============ LEFT PANEL - CONTROLS ============
    pnlLeft = uipanel(fig,"Position",[20 20 550 560],"Title","Controls", ...
        "FontSize",14,"FontWeight","bold","BackgroundColor",[1 1 1]);
    
    % --- LED CONTROL ---
    pnlLED = uipanel(pnlLeft,"Position",[20 450 510 90],"Title","LED Control", ...
        "FontSize",12,"FontWeight","bold","BackgroundColor",[0.97 0.97 1]);
    
    btnLedOn = uibutton(pnlLED,"push","Text","🔆 LED ON", ...
        "Position",[30 20 200 40], ...
        "FontSize",13,"FontWeight","bold", ...
        "BackgroundColor",[0.2 0.8 0.3],"FontColor",[1 1 1], ...
        "ButtonPushedFcn", @(~,~) send("LED ON"));
    
    btnLedOff = uibutton(pnlLED,"push","Text","🔅 LED OFF", ...
        "Position",[280 20 200 40], ...
        "FontSize",13,"FontWeight","bold", ...
        "BackgroundColor",[0.8 0.2 0.2],"FontColor",[1 1 1], ...
        "ButtonPushedFcn", @(~,~) send("LED OFF"));
    
    % --- SERVO MOVE ---
    pnlServo = uipanel(pnlLeft,"Position",[20 310 510 120],"Title","Servo Movement", ...
        "FontSize",12,"FontWeight","bold","BackgroundColor",[0.97 1 0.97]);
    
    uilabel(pnlServo,"Text","Servo ID:","Position",[30 75 80 22],"FontSize",11);
    idMove = uispinner(pnlServo,"Position",[120 75 100 22],"Limits",[0 255],"Value",1);
    
    uilabel(pnlServo,"Text","Angle (°):","Position",[260 75 80 22],"FontSize",11);
    angleMove = uispinner(pnlServo,"Position",[350 75 100 22],"Limits",[0 180],"Value",90, ...
        "ValueChangedFcn",@(src,~) updateSlider(src.Value));
    
    % Angle slider
    uilabel(pnlServo,"Text","0°","Position",[30 40 30 20],"FontSize",10);
    angleSlider = uislider(pnlServo,"Position",[65 50 370 3], ...
        "Limits",[0 180],"Value",90, ...
        "ValueChangedFcn",@(src,~) moveServoFromSlider(src.Value));
    uilabel(pnlServo,"Text","180°","Position",[440 40 40 20],"FontSize",10);
    
    btnMove = uibutton(pnlServo,"push","Text","➤ MOVE SERVO", ...
        "Position",[150 5 200 30], ...
        "FontSize",12,"FontWeight","bold", ...
        "BackgroundColor",[0.3 0.5 0.9],"FontColor",[1 1 1], ...
        "ButtonPushedFcn", @(~,~) send(sprintf("SERVO MOVE: %d, %d", ...
            round(idMove.Value), round(angleMove.Value))));
    
    % --- SERVO SPEED ---
    pnlSpeed = uipanel(pnlLeft,"Position",[20 140 510 150],"Title","Servo Speed Configuration", ...
        "FontSize",12,"FontWeight","bold","BackgroundColor",[1 0.97 0.97]);
    
    uilabel(pnlSpeed,"Text","Servo ID:","Position",[30 90 80 22],"FontSize",11);
    idSpeed = uispinner(pnlSpeed,"Position",[120 90 100 22],"Limits",[0 255],"Value",1);
    
    uilabel(pnlSpeed,"Text","Step (°):","Position",[260 90 80 22],"FontSize",11);
    stepDeg = uispinner(pnlSpeed,"Position",[350 90 100 22],"Limits",[1 45],"Value",5);
    
    uilabel(pnlSpeed,"Text","Delay (ms):","Position",[30 50 90 22],"FontSize",11);
    delayMs = uispinner(pnlSpeed,"Position",[120 50 100 22],"Limits",[1 1000],"Value",20);
    
    btnSpeed = uibutton(pnlSpeed,"push","Text","⚙ SET SPEED", ...
        "Position",[150 10 200 35], ...
        "FontSize",12,"FontWeight","bold", ...
        "BackgroundColor",[0.9 0.5 0.2],"FontColor",[1 1 1], ...
        "ButtonPushedFcn", @(~,~) send(sprintf("SERVO SET SPEED: %d, %d, %d", ...
            round(idSpeed.Value), round(stepDeg.Value), round(delayMs.Value))));
    
    % --- RAW COMMAND ---
    pnlRaw = uipanel(pnlLeft,"Position",[20 20 510 100],"Title","Custom Command", ...
        "FontSize",12,"FontWeight","bold","BackgroundColor",[1 1 0.97]);
    
    uilabel(pnlRaw,"Text","Command:","Position",[20 45 80 22],"FontSize",11);
    rawCmd = uieditfield(pnlRaw,"text","Position",[100 45 300 25],"FontSize",11);
    
    btnSendRaw = uibutton(pnlRaw,"push","Text","📤 SEND", ...
        "Position",[410 43 80 28], ...
        "FontSize",11,"FontWeight","bold", ...
        "BackgroundColor",[0.5 0.3 0.7],"FontColor",[1 1 1], ...
        "ButtonPushedFcn", @(~,~) send(rawCmd.Value));
    
    % ============ RIGHT PANEL - LOG ============
    pnlRight = uipanel(fig,"Position",[590 20 290 560],"Title","Communication Log", ...
        "FontSize",14,"FontWeight","bold","BackgroundColor",[1 1 1]);
    
    logBox = uitextarea(pnlRight,"Position",[10 50 270 490], ...
        "Editable","off","FontSize",10,"FontName","Courier New", ...
        "BackgroundColor",[0.05 0.05 0.1],"FontColor",[0.2 1 0.3]);
    
    btnClearLog = uibutton(pnlRight,"push","Text","🗑 Clear Log", ...
        "Position",[80 10 130 30], ...
        "FontSize",10, ...
        "BackgroundColor",[0.7 0.7 0.7], ...
        "ButtonPushedFcn", @(~,~) clearLog());
    
    % Store elements for callback
    fig.UserData.esp = esp;
    fig.UserData.log = logBox;
    
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
    
    function moveServoFromSlider(angle)
        angleMove.Value = round(angle);
        send(sprintf("SERVO MOVE: %d, %d", round(idMove.Value), round(angle)));
    end
    
    function updateSlider(angle)
        angleSlider.Value = angle;
    end
    
    function append_log(msg)
        timestamp = string(datetime('now','Format','HH:mm:ss'));
        logBox.Value = [logBox.Value; "[" + timestamp + "] " + string(msg)];
        scroll(logBox,"bottom");
        drawnow;
    end
    
    function clearLog()
        logBox.Value = {""};
        append_log("=== Log Cleared ===");
    end
    
    function esp_callback(src)
        line = readline(src);
        append_log("<< " + line);
    end
end