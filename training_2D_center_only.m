clc;
clear;
close all
%% Read images and extract features

basePath = '/home/zhi/Datasets/beam_direction/img_theta_x/';
background = imread([basePath 'background.png']);
% background = imread([basePath 'img_50_50.png']);
background = double(background);

THETA = 60:99;
XPOS = 60:99;
[GRID_THETA,GRID_XPOS] = meshgrid(XPOS, THETA);
MU_X = zeros(length(THETA),length(XPOS)); 
MU_Y = zeros(length(THETA),length(XPOS)); 
Y_THETA = zeros(length(THETA),length(XPOS)); 

for i = 1:length(THETA)
    for j = 1:length(XPOS)
        theta = THETA(i);
        xpos = XPOS(j);
        % read image
        imgPath = [basePath sprintf('img_%d_%d.png',theta,xpos)];
        % imgPath = [basePath sprintf('img_%d_%d.png',xpos,theta)];
        img = imread(imgPath);
        img = double(img);
        % background subtraction
        img = img - background;
        % cropping
        img = img(80:180,100:250);
        % threshold
        img(img<0) = 0;
        %img(img<100) = 0;
        % convert
        img = img/65535;
        % filter
        % img = medfilt2(img,[13,13]);
        % img = imgaussfilt(img,[13,13]);
        % img = bfilter2(img,25,[25 25/2]);
        % feature extraction
        [m,n]=size(img);
        s = sum(sum(img));
        x = linspace(0,n-1,n);
        y = linspace(0,m-1,m);
        mu_x = sum(img*x')/s;
        mu_y = sum(y*img)/s;
        MU_X(i,j) = mu_x;
        MU_Y(i,j) = mu_y;
        Y_THETA(i,j) = theta;
    end
end

%% save data
save center_only

%% load data
load center_only

%% plot
figure(1)
surf(GRID_THETA,GRID_XPOS,MU_X);
xlabel('theta')
ylabel('xpos')
zlabel('\mu_x')
figure(2)
surf(GRID_THETA,GRID_XPOS,MU_Y);
xlabel('theta')
ylabel('xpos')
zlabel('\mu_y')

%% regression
B_THETA = zeros(5,length(XPOS));

for i = 1:length(XPOS)
    X_theta = [ones(length(Y_THETA(:,i)),1), ...
               MU_X(:,i), ...
               MU_Y(:,i), ...
               MU_X(:,i).^2, ...
               MU_Y(:,i).^2];
    Y_theta = THETA';
    B_THETA(:,i) = regress(Y_theta,X_theta);
end

%% Plot regression
Y_THETA_reg = zeros(size(Y_THETA));

for i = 1:length(XPOS)
    X_theta = [ones(length(Y_THETA(:,i)),1), ...
               MU_X(:,i), ...
               MU_Y(:,i), ...
               MU_X(:,i).^2, ...
               MU_Y(:,i).^2];
    Y_THETA_reg(:,i) = X_theta*B_THETA(:,25);
end

figure(9)
subplot(1,3,1)
surf(GRID_THETA,GRID_XPOS,Y_THETA_reg);
xlabel('theta')
ylabel('xpos')
zlabel('theta_r_e_g')
subplot(1,3,2)
surf(GRID_THETA,GRID_XPOS,Y_THETA);
xlabel('theta')
ylabel('xpos')
zlabel('theta')
subplot(1,3,3)
surf(GRID_THETA,GRID_XPOS,Y_THETA_reg-Y_THETA);
xlabel('theta')
ylabel('xpos')
zlabel('theta_r_e_g - theta')