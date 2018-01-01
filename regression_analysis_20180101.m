% COnsidering the rotation problem
%%
close all
clear
clc
%%
b_100 = [1.389977593139575,-0.000381941225009];
b_170 = [1.394545220213261,-0.000338534255579];
b_344 = [1.391734908902134,-0.000274493270528];
b_398 = [1.391523605904583,-0.000264278111441];
% K = [-0.0895;-0.0946;-0.0945;-0.0916]; %PSD
K = [-0.01467;-0.01542;-0.02878;-0.01896]; % CCD
B = [b_100;b_170;b_344;b_398];
b2_mod = B(:,2)./cos(atan(K));
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
figure('Name','b2_mod vs distances','NumberTitle','off')
plot(D,b2_mod,'-*');
xlabel('distance (cm)')
ylabel('b2_mod')