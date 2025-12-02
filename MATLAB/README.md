# MATLAB

## Tips for API

1. Before running ANY API related function, make sure that `PS2000Config;` was initialized. Otherwise nothing will work.
2. If you mess up and Pico is not detected, disconnect the pico `disconnect(ps2000DeviceObj);`. It should work, if not restart your computer.

## PicoScope Matlab Configuration

This configuration is for Windows only.

1. Download and Install SDK
https://www.picotech.com/downloads

PicoScope2000 -> 2205A -> PicoSDK
Install the SDK. Might require a restart.

2. Download and export PicoSDK C Wrappers
https://github.com/picotech/picosdk-c-wrappers-binaries

Download appropriate wrapper version.
Go to `C:\Program Files\Pico Technology\SDK\lib`
Export Wrappers here (Or whenever your SDK is installed)

3. Install Required MATLAB Add-ons
To install add-ons:
MATLAB -> APPS -> Get More Apps

In search, clear all filters.
And search and install:
* *PicoScope Support Toolbox* https://uk.mathworks.com/matlabcentral/fileexchange/53681-picoscope-support-toolbox
* *PicoScope 2000 Series MATLAB Generic Instrument Driver* https://www.mathworks.com/matlabcentral/fileexchange/40134-picoscope-2000-series-matlab-generic-instrument-driver
    Important! Make sure that 2000 Series is installed and NOT the 2000A API. 2000A API does NOT support PicoScope 2205A!



