close all
clear
clc
%%
b_100 = [1.389977593139575,-0.000381941225009];
b_170 = [1.394545220213261,-0.000338534255579];
b_344 = [1.391734908902134,-0.000274493270528];
b_398 = [1.391523605904583,-0.000264278111441];
B = [b_100;b_170;b_344;b_398];
D = [100;170;344;398];
%%
figure('Name','b1 vs distances','NumberTitle','off')
plot(D,B(:,1),'-*');
xlabel('distance (cm)')
ylabel('b1')
figure('Name','b2 vs distances','NumberTitle','off')
plot(D,B(:,2),'-*');
xlabel('distance (cm)')
ylabel('b2')