clear all
close all
clc

%% Load Configuration Information
PS2000Config;

% Load CSV
awg = [ones(1, round(10e-6 * 5e6)), zeros(1, 4096 - round(10e-6 * 5e6))];


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

fs = 1e6;       % 1MHz Frequency sampling

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

% Output an arbitrary wave and sweep up from start to stop frequency in 
% 50Hz steps.
%
% Increment   : 50 Hz
% Dwell time  : 100 milliseconds
% Waveform    : As defined in the PS2000Config file.
% Sweep type  : 0 (PS2000_UP)
% Num. sweeps : 1

set(sigGenGroupObj, 'offsetVoltage', 0);
set(sigGenGroupObj, 'peakToPeakVoltage', 2000);
set(sigGenGroupObj, 'startFrequency', 1000);

[status.sigGenArbitrary] = invoke(sigGenGroupObj, 'ps2000SetSigGenArbitrary', ...
    1, 0, awg, 0, 0);


%% Set simple trigger:

% Set the trigger delay to 50% (samples will be shown either side of the
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
