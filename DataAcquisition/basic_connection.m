clear 
close all 
clc

% connect with esp 
esp = serialport("COM8", 115200);
configureTerminator(esp, "CR/LF");

pause(2)
if esp.NumBytesAvailable > 0
    buffer = read(esp, esp.NumBytesAvailable, "string")
end
%% send ON command
writeline(esp, "LED ON");
response = readline(esp)
%% send OFF command 
writeline(esp, "LED OFF");
response = readline(esp)

%% send trigger
 writeline(esp, "TRIGGER");
response = readline(esp)

%% Servo commands
%% 
writeline(esp, "SERVO MOVE: 2, 110");
response = readline(esp)


%% 
response = readline(esp)

%%
while(1)
    pause(0.1)
    writeline(esp, "LED OFF");
    pause(0.1)
    writeline(esp, "LED ON");

end
%% 

k = 0;
while(k < 10)
    pause(0.1)
    writeline(esp, "LED OFF");
    pause(0.1)
    writeline(esp, "LED ON");
    k = k + 1;
end

if esp.NumBytesAvailable > 0
    buffer = read(esp, esp.NumBytesAvailable, "string")
end

%% clear buffer after connection
if esp.NumBytesAvailable > 0
    buffer = read(esp, esp.NumBytesAvailable, "string")
end


%% wait for response loop
buff = 0;

writeline(esp, "LED ON");
while (1)
    if buff > 0
        response = readline(esp)

        if response == "LED=1"
            writeline(esp, "LED OFF");
        end

        if response == "LED=0"
            writeline(esp, "LED ON");
        end
    end

    buff = esp.NumBytesAvailable;
    pause(0.1)
end