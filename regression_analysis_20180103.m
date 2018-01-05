close all
clear
clc
%%
b_190 = [-0.010883865805137,0.000191680517445,-0.000083101127899];
b_315 = [-0.014493382647137,0.000189332824952,-0.000019419348314];
b_520 = [-0.012497701080655,0.000183590456489,-0.000042298973209];
b_713 = [-0.021796314797041,0.000182390830776,0.000126097111364];
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
figure('Name','b3 vs distances','NumberTitle','off')
plot(D,B(:,3),'-*');
xlabel('distance (cm)')
ylabel('b3')