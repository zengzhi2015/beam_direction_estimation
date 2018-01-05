close all
clear
clc
%%
b_190 = [-0.025907008264623,-0.192339698251549];
b_315 = [-0.017910504261803,-0.189470015405927];
b_520 = [-0.027543133488605,-0.183627860477250];
b_713 = [-0.034134495026301,-0.180265408504355];
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