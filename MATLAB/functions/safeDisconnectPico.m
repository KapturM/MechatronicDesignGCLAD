% Safely disconnects PicoScope device

function safeDisconnectPico()
    % Check if object exists in base workspace
    if evalin('base','exist(''ps2000DeviceObj'',''var'')')
        ps2000DeviceObj = evalin('base','ps2000DeviceObj');

        try
            % Some drivers may use 'status' property
            if isprop(ps2000DeviceObj,'status')
                deviceStatus = strtrim(ps2000DeviceObj.status);
                if strcmpi(deviceStatus,'open') || strcmpi(deviceStatus,'connected')
                    disconnect(ps2000DeviceObj);
                end
            else
                % Fallback: try disconnect anyway
                disconnect(ps2000DeviceObj);
            end

            delete(ps2000DeviceObj);
            evalin('base','clear ps2000DeviceObj');

            disp("PicoScope device disconnected and cleared...");
            
        catch ME
            warning("Error disconnecting PicoScope: %s", ME.message);
        end

    else
        disp("PicoScope object does not exist.");
    end
    disp("PicoScope disconnect finished...");
    pause(5)
end
