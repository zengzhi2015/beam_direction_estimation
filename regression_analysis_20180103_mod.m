close all
clear
clc
%%
b_190 = [-0.015780690932481,0.000192345691167];
b_315 = [-0.015599216785148,0.000189475298617];
b_520 = [-0.014941954018373,0.000183630292845];
b_713 = [-0.014543745618932,0.000180288321668];
B = [b_190;b_315;b_520;b_713];
D = [190;315;520;713];
%%
figure('Name','b1 vs distances','NumberTitle','off')
plot(D,B(:,1),'-*');
xlabel('distance (cm)')
ylabel('b1')
figure('Name','b2 vs distances','NumberTitle','off')
plot(D,B(:,2),'-*');
xlabel('distance (cm)')
ylabel('b2')