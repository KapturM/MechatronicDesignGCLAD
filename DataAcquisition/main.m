safeDisconnectPico();
clear all; close all; clc;


%% ================== User Parameters ==================
x_start = 0; x_end = 10; x_step = 2;     % X in mm
y_start = 0; y_end = 10; y_step = 2;     % Y in mm
measurementsPerPoint = 10;
measurementSize = 2048;                 % Number of samples per measurement
fs = 1e6;                               % 1MHz Frequency sampling



%% ================ Preallocate Storage ================
disp('Preallocating storage...')

% Used for loop lengths and position tracking
x_values = x_start:x_step:x_end;
y_values = y_start:y_step:y_end;

numX = length(x_values);
numY = length(y_values);

% Preallocate struct matrix for grid data
emptyMeasurement = struct('A', [], 'B', [], 'Time', []);
emptyPoint = struct('measurements', repmat(emptyMeasurement, 1, measurementsPerPoint), ...
                    'X_mm', 0, 'Y_mm', 0);

gridData = repmat(emptyPoint, numY, numX);

% ASCII UI stuff
uiMap = repmat('o', numY, numX);
measurementCount = 0;
totalPoints = numX*numY;

pause(1)
%% =========== Initialize and Connect Device ===========
disp('Device Initialization...')
PS2000Config;
ps2000DeviceObj = icdevice('picotech_ps2000_generic.mdd');
connect(ps2000DeviceObj);

pause(1)
%% ================ Device Configuration ===============
disp('Device Configuration...')

% Set channels:
% Channel     : 0 (ps2000Enuminfo.enPS2000Channel.PS2000_CHANNEL_A)
% Enabled     : 1 (PicoConstants.TRUE)
% DC          : 1 (DC Coupling)
% Range       : 6 (ps2000Enuminfo.enPS2000Range.PS2000_1V)
[status.setChA] = invoke(ps2000DeviceObj, 'ps2000SetChannel', 0, 1, 1, 7);    

% Channel     : 1 (ps2000Enuminfo.enPS2000Channel.PS2000_CHANNEL_B)
% Enabled     : 1 (PicoConstants.TRUE)
% DC          : 1 (DC Coupling)
% Range       : 7 (ps2000Enuminfo.enPS2000Range.PS2000_2V)
[status.setChB] = invoke(ps2000DeviceObj, 'ps2000SetChannel', 1, 1, 1, 7);  

blockGroupObj = get(ps2000DeviceObj, 'Block');
blockGroupObj = blockGroupObj(1);

triggerGroupObj = get(ps2000DeviceObj, 'Trigger');
triggerGroupObj = triggerGroupObj(1);

% timeIntervalUs : 100 (microseconds)
[samplingIntervalUs, maxBlockSamples] = invoke(blockGroupObj, 'setBlockIntervalUs', 1/(fs*10^-6));

% Confirm the timebase index selected.
timebaseIndex = get(blockGroupObj, 'timebase');

% Set the number of samples to collect.
set(ps2000DeviceObj, 'numberOfSamples', measurementSize);


% Set simple trigger:
% Set the trigger delay to 30% (samples will be shown either side of the
% trigger point.
set(triggerGroupObj, 'delay', -30.0);

% Set the autoTriggerMs property in order to automatically trigger the
% oscilloscope after 1 second if a trigger event has not occurred. Set to 0
% to wait indefinitely for a trigger event.
set(triggerGroupObj, 'autoTriggerMs', 1000);

% Parameters taken from config file loaded into workspace.
[simpleTriggerStatus] = invoke(triggerGroupObj, 'setSimpleTrigger', ...
    ps2000ConfigInfo.simpleTrigger.source, ps2000ConfigInfo.simpleTrigger.threshold, ...
    ps2000ConfigInfo.simpleTrigger.direction);

pause(1)
%% ==================== Define AWG =====================
disp('Generating AWG...')

sigGenGroupObj = get(ps2000DeviceObj, 'Signalgenerator');
sigGenGroupObj = sigGenGroupObj(1);

% Offset voltage        : 0 mV
% Peak to peak voltage  : 2000 mV (+/- 1000 mV)
% Frequency             : 1000 Hz
set(sigGenGroupObj, 'offsetVoltage', 0);
set(sigGenGroupObj, 'peakToPeakVoltage', 2000);
set(sigGenGroupObj, 'startFrequency', 1000);

% Custom one peak signal. If to be modifed, make sure for the peak to be
% 10microseconds.
awg = [ones(1, round(10e-6 * 5e6)), zeros(1, 4096 - round(10e-6 * 5e6))];

pause(1)
%% ===================== Start AWG =====================
disp('AWG Start...')

% Increment   : 1 Hz
% Dwell time  : 0 milliseconds
% Waveform    : awg
% Sweep type  : 0 (PS2000_UP)
% Num. sweeps : 0
[status.sigGenArbitrary] = invoke(sigGenGroupObj,'ps2000SetSigGenArbitrary',1,0,awg,0,0);

pause(1)
clc;


%% ===================== Scan Loop =====================
disp('Starting data gathering...')

for yi = 1:numY
    
    % Determine scan direction (raster)
    if mod(yi,2) == 1
        scanOrder = 1:numX;      % -> direction
    else
        scanOrder = numX:-1:1;   % <- direction
    end
    
    for xi = scanOrder
        
        x_pos = x_values(xi);
        y_pos = y_values(yi);
        measurementCount = measurementCount + 1;
        progressPercent = measurementCount / totalPoints * 100;
        
        %% ================= Move Servo =================
        if moveServoXY(x_pos, y_pos)
            waitForServo();
        else
            warning("Servo failed — skipping point (%d,%d)", xi, yi);
            continue;
        end
        
        %% ================= Collect Measurements =================
        allA = zeros(measurementsPerPoint, measurementSize);
        allB = zeros(measurementsPerPoint, measurementSize);
        allT = zeros(measurementsPerPoint, measurementSize);
        
        fprintf("Collecting 10 measurements at X=%.2fmm Y=%.2fmm\n", x_pos, y_pos);
        
        for rpt = 1:measurementsPerPoint
            [bufferTimes, bufferChA, bufferChB, ~, ~] = invoke(blockGroupObj,'getBlockData');
            invoke(ps2000DeviceObj,'ps2000Stop');
            
            allA(rpt,:) = bufferChA;
            allB(rpt,:) = bufferChB;
            allT(rpt,:) = bufferTimes;
            
            fprintf("   Repeat %d/%d complete\n", rpt, measurementsPerPoint);
            pause(0.1)
        end
        
        %% ================= Save Into Struct =================
        gridData(yi, xi).X_mm = x_pos;
        gridData(yi, xi).Y_mm = y_pos;
        for rpt = 1:measurementsPerPoint
            gridData(yi, xi).measurements(rpt).A = allA(rpt,:);
            gridData(yi, xi).measurements(rpt).B = allB(rpt,:);
            gridData(yi, xi).measurements(rpt).Time = allT(rpt,:);
        end
        
        %% ================= Command Window UI =================
        % Update map for measured point
        uiMap(yi, xi) = 'x';

        % Call the UI function
        updateRasterUI(uiMap, xi, yi, x_pos, y_pos, yi, numY, measurementCount, totalPoints);
        
    end
end


%% ===================== Stop AWG ======================
disp('AWG Stop...')
set(sigGenGroupObj,'offsetVoltage',0);
set(sigGenGroupObj,'peakToPeakVoltage',0);
[sigGenOffStatus] = invoke(sigGenGroupObj,'setSigGenOff');


%% ==================== Disconnect =====================
disp('Disconnecting PicoScope...')
disconnect(ps2000DeviceObj);
delete(ps2000DeviceObj);


%% ===================== Save Data =====================
disp('Saving data...')
timestamp = datestr(now,'yyyy-mm-dd_HHMMSS');
filename = sprintf("FullScanGrid_%s.mat", timestamp);

save(filename, 'gridData', '-v7.3');
disp(['Data saved to file: ', filename]);
disp('Done...')


