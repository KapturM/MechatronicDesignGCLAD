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

measurementsPerPoint = 10;
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

%% 

% %% Configure AWG - Rectangular Wave Output
% % Set up signal generator to output a rectangular (square) wave
% disp('Configuring AWG for rectangular wave output...');
% 
% % Parameters for setSigGenBuiltInSimple:
% % offsetVoltage         : awgOffset (mV)
% % pkToPk                : awgAmplitude (mV peak-to-peak)
% % waveType              : 1 (Square wave)
% % startFrequency        : awgFrequency (Hz)
% % stopFrequency         : awgFrequency (Hz) - same as start for single frequency
% % increment             : 0 (no frequency sweep)
% % dwellTime             : 1 (seconds) - not used for single frequency
% % sweepType             : 0 (Up sweep) - not used for single frequency
% % shots                 : 0 (continuous output)
% 
% [status.awg] = invoke(signalGeneratorGroupObj, 'setSigGenBuiltInSimple', ...
%     awgOffset, awgAmplitude, 1, awgFrequency, awgFrequency, 0, 1, 0, 0);
% 
% if status.awg == 0
%     fprintf('AWG configured: %d Hz rectangular wave, %d mV p-p, %d mV offset\n', ...
%         awgFrequency, awgAmplitude, awgOffset);
% else
%     warning('AWG configuration may have failed. Status: %d', status.awg);
% end

%% Configure the Device
% Enable both Channel A and Channel B

%%
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

%%
% Set sampling interval and number of samples to collect:
[samplingIntervalUs, maxBlockSamples] = invoke(blockGroupObj, 'setBlockIntervalUs', 1/(fs*10^-6));

% Confirm the timebase index selected.
timebaseIndex = get(blockGroupObj, 'timebase');

% Set the number of samples to collect.
set(ps2000DeviceObj, 'numberOfSamples', measurementSize);

%%
% Set trigger on Channel A, rising edge at 1.5V (1500 mV):
% autoTriggerMs : 0 (wait indefinitely)
set(triggerGroupObj, 'autoTriggerMs', 0);

% Trigger parameters:
% source    : 0 (Channel A)
% threshold : 1500 (mV) - 1.5V
% direction : 0 (Rising edge)
[simpleTriggerStatus] = invoke(triggerGroupObj, 'setSimpleTrigger', 0, 1500, 0);

disp('Trigger set to Channel A, Rising Edge at 1.5V');

%% Data Collection
% Capture a block of data on both channels
disp('Collecting block of data from both channels...');

%% send trigger
writeline(esp, "TRIGGER ON");
response = readline(esp)

[bufferTimes, bufferChA, bufferChB, numDataValues, timeIndisposedMs] = invoke(blockGroupObj, 'getBlockData');

disp('Data collection complete.');
writeline(esp, "TRIGGER OFF");
response = readline(esp)
%% Stop the Device
stopStatus = invoke(ps2000DeviceObj, 'ps2000Stop');

% % Stop the AWG signal generator
% disp('Stopping AWG output...');
% invoke(signalGeneratorGroupObj, 'setSigGenOff');

%% Process and Display Data with Dual Y-Axes
disp('Processing data for plot...')

% Find the time units used by the driver
timesUnits = timeunits(get(blockGroupObj, 'timeUnits'));
timeLabel = strcat('Time (', timesUnits, ')');

% Create figure with dual y-axes
figure1 = figure('Name','PicoScope 2000 Series - Dual Channel Acquisition', ...
    'NumberTitle', 'off');

% Create dual y-axis plot
yyaxis left
plot(bufferTimes, bufferChA, 'b-', 'LineWidth', 1.5);
ylabel('Channel A Voltage (mV)', 'Color', 'b');
ylim('auto');
ax = gca;
ax.YColor = 'b';

yyaxis right
plot(bufferTimes, bufferChB, 'r-', 'LineWidth', 1.5);
ylabel('Channel B Voltage (mV)', 'Color', 'r');
ylim([-2000 2000]);
ax.YColor = 'r';

% Common properties
xlabel(timeLabel);
title('Dual Channel Block Data Acquisition');
grid on;
legend('Channel A (±5V)', 'Channel B (±2V)', 'Location', 'best');

% Add trigger level line on left axis
yyaxis left
hold on;
plot([bufferTimes(1), bufferTimes(end)], [1500, 1500], 'b--', 'LineWidth', 1);
hold off;


xlim([0 1310310000])

% %% Display Statistics
% fprintf('\n=== AWG Configuration ===\n');
% fprintf('Waveform: Rectangular (Square) Wave\n');
% fprintf('Frequency: %d Hz\n', awgFrequency);idf
% fprintf('Amplitude: %d mV peak-to-peak\n', awgAmplitude);
% fprintf('Offset: %d mV\n', awgOffset);
% 
% fprintf('\n=== Acquisition Statistics ===\n');
% fprintf('Number of samples collected: %d\n', numDataValues);
% fprintf('Sampling interval: %.2f µs\n', samplingIntervalUs);
% fprintf('Total acquisition time: %.2f ms\n', bufferTimes(end)/1000);
% fprintf('\nChannel A:\n');
% fprintf('  Range: ±5V\n');
% fprintf('  Min: %.2f mV\n', min(bufferChA));
% fprintf('  Max: %.2f mV\n', max(bufferChA));
% fprintf('  Mean: %.2f mV\n', mean(bufferChA));
% fprintf('\nChannel B:\n');
% fprintf('  Range: ±2V\n');
% fprintf('  Min: %.2f mV\n', min(bufferChB));
% fprintf('  Max: %.2f mV\n', max(bufferChB));
% fprintf('  Mean: %.2f mV\n', mean(bufferChB));

%% Disconnect
% Disconnect device object from hardware.
disconnect(ps2000DeviceObj);
delete(ps2000DeviceObj);