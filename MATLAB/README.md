# MATLAB

## Tips for API

1. Before running ANY API related function, make sure that `PS2000Config;` was initialized. Otherwise nothing will work.
2. If you mess up and get an error using the code, **DO NOT RUN ANYTHING!**, disconnect the pico using command window: `disconnect(ps2000DeviceObj);`. Make sure that DeviceObj wasn't cleared. It should work, if not restart your computer.

## PicoScope Matlab Configuration
This configuration is for Windows only. <br>

1. Download and Install SDK
    https://www.picotech.com/downloads <br>

    PicoScope2000 -> 2205A -> PicoSDK <br>
    Install the SDK. Might require a restart. <br>

2. Download and export PicoSDK C Wrappers
    https://github.com/picotech/picosdk-c-wrappers-binaries <br>

    Download appropriate wrapper version. <br>
    Go to `C:\Program Files\Pico Technology\SDK\lib` <br>
    Export Wrappers here (Or wherever your SDK is installed) <br>

3. Install Required MATLAB Add-ons
    To install add-ons: <br>
    MATLAB -> APPS -> Get More Apps <br>

    In search, clear all filters. <br>
    Search and install:
    * *PicoScope Support Toolbox* https://uk.mathworks.com/matlabcentral/fileexchange/53681-picoscope-support-toolbox
    * *PicoScope 2000 Series MATLAB Generic Instrument Driver* https://www.mathworks.com/matlabcentral/fileexchange/40134-picoscope-2000-series-matlab-generic-instrument-driver <br>

    !Important! Make sure that 2000 Series is installed and NOT the 2000A API. 2000A API does NOT support PicoScope 2205A!

## Other Required Libraries 

1. cprintf - display formatted colored text in Command Window
    https://www.mathworks.com/matlabcentral/fileexchange/24093-cprintf-display-formatted-colored-text-in-command-window <br>

    How to install: <br>
    MATLAB -> APPS -> Get More Apps <br>

    In search, clear all filters. <br>
    Search and install:
     * *cprintf*



