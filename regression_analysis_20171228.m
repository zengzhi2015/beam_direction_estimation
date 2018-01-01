close all
clear
clc
%%
b_100 = [1.437046643607207,-0.000395417108643,-0.000918487752070];
b_170 = [1.400275869740209,-0.000340550533447,-0.000130799185998];
b_344 = [1.392287166125299,-0.000274894074929,-0.000013926823259];
b_398 = [1.352296734882919,-0.000244834764869,0.001025582611556];
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
figure('Name','b3 vs distances','NumberTitle','off')
plot(D,B(:,3),'-*');
xlabel('distance (cm)')
ylabel('b3')