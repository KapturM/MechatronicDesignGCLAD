clear 
close all 


% connect with esp 
esp = serialport("COM9", 115200);
configureTerminator(esp, "CR/LF");
%% send ON command
writeline(esp, "LED ON");
response = readline(esp)
%% send OFF command 
writeline(esp, "LED OFF");
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


%% clear buffer after connection
buffer = read(esp, esp.NumBytesAvailable, "string")


%% wait for response loop
buff = 0;

writeline(esp, "LED ON");
while (1)
    if buff > 0
        response = readline(esp)

        if response == "LED TURNED ON"
            writeline(esp, "LED OFF");
        end

        if response == "LED TURNED OFF"
            writeline(esp, "LED ON");
        end
    end

    buff = esp.NumBytesAvailable;
    pause(0.1)
end