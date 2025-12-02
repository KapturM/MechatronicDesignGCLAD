clear all
close all
clc

% Get Mor Apps -> PicoScope 2000 Series A API MATLAB Generic Instrument Driver


%% Load Configuration Information
PS2000Config;

%% Device Connection
ps2000DeviceObj = icdevice('picotech_ps2000_generic.mdd');
connect(ps2000DeviceObj);

%% Device Configuration
disp('Device Configuration...')
% Set channels:

% Channel     : 0 (ps2000Enuminfo.enPS2000Channel.PS2000_CHANNEL_A)
% Enabled     : 1 (PicoConstants.TRUE)
% DC          : 1 (DC Coupling)
% Range       : 6 (ps2000Enuminfo.enPS2000Range.PS2000_1V)
[status.setChA] = invoke(ps2000DeviceObj, 'ps2000SetChannel', 0, 1, 1, 6);    

% Channel     : 1 (ps2000Enuminfo.enPS2000Channel.PS2000_CHANNEL_B)
% Enabled     : 1 (PicoConstants.TRUE)
% DC          : 1 (DC Coupling)
% Range       : 7 (ps2000Enuminfo.enPS2000Range.PS2000_2V)
[status.setChB] = invoke(ps2000DeviceObj, 'ps2000SetChannel', 1, 1, 1, 7);  

blockGroupObj = get(ps2000DeviceObj, 'Block');
blockGroupObj = blockGroupObj(1);

fs = 10e3;

% timeIntervalUs : 100 (microseconds)
[samplingIntervalUs, maxBlockSamples] = invoke(blockGroupObj, 'setBlockIntervalUs', 1/(fs*10^-6));

% Confirm the timebase index selected.
timebaseIndex = get(blockGroupObj, 'timebase');

% Set the number of samples to collect.
set(ps2000DeviceObj, 'numberOfSamples', 2048);

%% AWG
disp('Generating Signal...')
sigGenGroupObj = get(ps2000DeviceObj, 'Signalgenerator');
sigGenGroupObj = sigGenGroupObj(1);

set(sigGenGroupObj, 'startFrequency', 100);

% Wave type : ps2000Enuminfo.enPS2000WaveType.PS2000_SINE

[status.sigGenSimple] = invoke(sigGenGroupObj, 'setSigGenBuiltInSimple', ...
    ps2000Enuminfo.enPS2000WaveType.PS2000_SINE);

% % Output a square wave.
% % 
% % Change the peak to peak voltage to 1000mV (+/- 500mV) and set the output
% % frequency to 1000Hz.
% 
% set(sigGenGroupObj, 'peakToPeakVoltage', 1000);
% set(sigGenGroupObj, 'startFrequency', 10);
% 
% % Wave type : 1 (ps2000Enuminfo.enPS2000WaveType.PS2000_SQUARE)
% 
% [status.sigGenSimple] = invoke(sigGenGroupObj, 'setSigGenBuiltInSimple', 1);



%% Data Collection
disp('Collecting block of data...');

% Execute device object function(s).
[bufferTimes, bufferChA, bufferChB, numDataValues, timeIndisposedMs] = invoke(blockGroupObj, 'getBlockData');

disp('Data collection complete.');

stopStatus = invoke(ps2000DeviceObj, 'ps2000Stop');

%% Turn off AWG

set(sigGenGroupObj, 'offsetVoltage', 0);
set(sigGenGroupObj, 'peakToPeakVoltage', 0);

[sigGenOffStatus] = invoke(sigGenGroupObj, 'setSigGenOff');


%% Process Data

disp('Plotting data...')

% Find the time units used by the driver.
timesUnits = timeunits(get(blockGroupObj, 'timeUnits'));

% Append to string.
timeLabel = strcat('Time (', timesUnits, ')');

% Plot the data.

figure1 = figure('Name','PicoScope 2000 Series Example - Block Mode Capture', ...
    'NumberTitle', 'off');

plot(bufferTimes, bufferChA, bufferTimes, bufferChB);
title('Block Data Acquisition');
xlabel(timeLabel);
ylabel('Voltage (mv)');
legend('Channel A', 'Channel B');
grid on;

%% Disconnect
disconnect(ps2000DeviceObj);
delete(ps2000DeviceObj);
