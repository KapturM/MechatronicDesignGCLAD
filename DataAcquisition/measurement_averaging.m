clear;close all;clc
addpath('functions\')
safeDisconnectPico();


%% connect with esp 
esp = serialport("COM8", 115200);
configureTerminator(esp, "CR/LF");

pause(2)
if esp.NumBytesAvailable > 0
    buffer = read(esp, esp.NumBytesAvailable, "string")
end

%% Set measurement parameters

measurementsPerPoint = 10;              % Number of readings to average
measurementSize = 2048;                 % Number of samples per measurement
fs = 1e6;                               % 1MHz Frequency sampling


%% Load Configuration Information
PS2000Config;

%% Device Connection
% Create a device object. 
ps2000DeviceObj = icdevice('picotech_ps2000_generic.mdd');

% Connect device object to hardware.
connect(ps2000DeviceObj);

%% Obtain Device Groups
blockGroupObj = get(ps2000DeviceObj, 'Block');
blockGroupObj = blockGroupObj(1);

triggerGroupObj = get(ps2000DeviceObj, 'Trigger');
triggerGroupObj = triggerGroupObj(1);

% Signal Generator group for AWG
signalGeneratorGroupObj = get(ps2000DeviceObj, 'Signalgenerator');
signalGeneratorGroupObj = signalGeneratorGroupObj(1);

%% Configure the Device
% Enable both Channel A and Channel B

% Set Channel A:
% Channel     : 0 (PS2000_CHANNEL_A)
% Enabled     : 1 (TRUE)
% DC Coupling : 1
% Range       : 7 (PS2000_2V) - Set to ±5V range
[status.setChA] = invoke(ps2000DeviceObj, 'ps2000SetChannel', 0, 1, 1, 7);    % 5V range

% Set Channel B:
% Channel     : 1 (PS2000_CHANNEL_B)
% Enabled     : 1 (TRUE) - NOW ENABLED
% DC Coupling : 1
% Range       : 8 (PS2000_2V) - Set to ±2V range
[status.setChB] = invoke(ps2000DeviceObj, 'ps2000SetChannel', 1, 1, 1, 8);    % 2V range

%% Set sampling interval and number of samples
[samplingIntervalUs, maxBlockSamples] = invoke(blockGroupObj, 'setBlockIntervalUs', 1/(fs*10^-6));

% Confirm the timebase index selected.
timebaseIndex = get(blockGroupObj, 'timebase');

% Set the number of samples to collect.
set(ps2000DeviceObj, 'numberOfSamples', measurementSize);

%% Set trigger on Channel A, rising edge at 1.5V (1500 mV)
set(triggerGroupObj, 'autoTriggerMs', 0);

% Trigger parameters:
% source    : 0 (Channel A)
% threshold : 1500 (mV) - 1.5V
% direction : 0 (Rising edge)
[simpleTriggerStatus] = invoke(triggerGroupObj, 'setSimpleTrigger', 0, 1500, 0);

disp('Trigger set to Channel A, Rising Edge at 1.5V');

%% Data Collection - Multiple Readings
disp(['Collecting ', num2str(measurementsPerPoint), ' readings for averaging...']);

% Initialize arrays to store all measurements
allBufferChA = zeros(measurementSize, measurementsPerPoint);
allBufferChB = zeros(measurementSize, measurementsPerPoint);

% Collect multiple measurements
for i = 1:measurementsPerPoint
    fprintf('Reading %d/%d...\n', i, measurementsPerPoint);
    
    % Send trigger
    writeline(esp, "TRIGGER ON");
    response = readline(esp);
    
    % Get block data
    [bufferTimes, bufferChA, bufferChB, numDataValues, timeIndisposedMs] = invoke(blockGroupObj, 'getBlockData');
    
    % Store the data
    allBufferChA(:, i) = bufferChA;
    allBufferChB(:, i) = bufferChB;
    
    % Turn off trigger
    writeline(esp, "TRIGGER OFF");
    response = readline(esp);
    
    % Pause between measurements
    pause(1);
end

disp('All data collection complete.');

% Calculate Averages
avgBufferChA = mean(allBufferChA, 2);
avgBufferChB = mean(allBufferChB, 2);

% Calculate standard deviation for error analysis
stdBufferChA = std(allBufferChA, 0, 2);
stdBufferChB = std(allBufferChB, 0, 2);

% Stop the Device
stopStatus = invoke(ps2000DeviceObj, 'ps2000Stop');

%% Process and Display Data with Dual Y-Axes
disp('Processing averaged data for plot...')

% Find the time units used by the driver
timesUnits = timeunits(get(blockGroupObj, 'timeUnits'));
timeLabel = strcat('Time (', timesUnits, ')');

% Create figure with dual y-axes - Averaged Data
figure1 = figure('Name','PicoScope 2000 Series - Averaged Dual Channel Acquisition', ...
    'NumberTitle', 'off');

% Create dual y-axis plot
yyaxis left
plot(bufferTimes, avgBufferChA, 'b-', 'LineWidth', 1.5);
ylabel('Channel A Voltage (mV)', 'Color', 'b');
ylim('auto');
ax = gca;
ax.YColor = 'b';

yyaxis right
plot(bufferTimes, avgBufferChB, 'r-', 'LineWidth', 1.5);
ylabel('Channel B Voltage (mV)', 'Color', 'r');
ylim([-2000 2000]);
ax.YColor = 'r';

% Common properties
xlabel(timeLabel);
title(['Averaged Dual Channel Data (n=', num2str(measurementsPerPoint), ')']);
grid on;
legend('Channel A (±5V) - Avg', 'Channel B (±2V) - Avg', 'Location', 'best');

% Add trigger level line on left axis
yyaxis left
hold on;
plot([bufferTimes(1), bufferTimes(end)], [1500, 1500], 'b--', 'LineWidth', 1);
hold off;

xlim([0 1310310000])

% Optional: Plot all individual traces with average
figure2 = figure('Name','All Measurements with Average', 'NumberTitle', 'off');

subplot(2,1,1)
hold on
for i = 1:measurementsPerPoint
    plot(bufferTimes, allBufferChA(:,i), 'Color', [0.7 0.7 1], 'LineWidth', 0.5);
end
plot(bufferTimes, avgBufferChA, 'b-', 'LineWidth', 2);
plot([bufferTimes(1), bufferTimes(end)], [1500, 1500], 'b--', 'LineWidth', 1);
hold off
ylabel('Channel A Voltage (mV)');
title(['Channel A: All Measurements (light) and Average (bold), n=', num2str(measurementsPerPoint)]);
grid on;
xlim([0 1310310000])

subplot(2,1,2)
hold on
for i = 1:measurementsPerPoint
    plot(bufferTimes, allBufferChB(:,i), 'Color', [1 0.7 0.7], 'LineWidth', 0.5);
end
plot(bufferTimes, avgBufferChB, 'r-', 'LineWidth', 2);
hold off
xlabel(timeLabel);
ylabel('Channel B Voltage (mV)');
title(['Channel B: All Measurements (light) and Average (bold), n=', num2str(measurementsPerPoint)]);
grid on;
ylim([-2000 2000]);
xlim([0 1310310000])

% Display Statistics
fprintf('\n=== Acquisition Statistics ===\n');
fprintf('Number of measurements averaged: %d\n', measurementsPerPoint);
fprintf('Samples per measurement: %d\n', numDataValues);
fprintf('Sampling interval: %.2f µs\n', samplingIntervalUs);
fprintf('Total acquisition time per trace: %.2f ms\n', bufferTimes(end)/1000);

fprintf('\nChannel A (Averaged):\n');
fprintf('  Range: ±5V\n');
fprintf('  Min: %.2f mV\n', min(avgBufferChA));
fprintf('  Max: %.2f mV\n', max(avgBufferChA));
fprintf('  Mean: %.2f mV\n', mean(avgBufferChA));
fprintf('  Avg Std Dev: %.2f mV\n', mean(stdBufferChA));

fprintf('\nChannel B (Averaged):\n');
fprintf('  Range: ±2V\n');
fprintf('  Min: %.2f mV\n', min(avgBufferChB));
fprintf('  Max: %.2f mV\n', max(avgBufferChB));
fprintf('  Mean: %.2f mV\n', mean(avgBufferChB));
fprintf('  Avg Std Dev: %.2f mV\n', mean(stdBufferChB));

%% Disconnect
% Disconnect device object from hardware.
disconnect(ps2000DeviceObj);
delete(ps2000DeviceObj);