clc;
clear;
close all
%% Read images and extract features

basePath = '/home/zhi/Datasets/beam_direction/img_theta_x/';
background = imread([basePath 'background.png']);
background = double(background);

THETA = 1:99;
XPOS = 1:99;
MU_X = zeros(1,length(THETA)*length(XPOS)); 
MU_Y = zeros(1,length(THETA)*length(XPOS)); 
SIGMA_XX = zeros(1,length(THETA)*length(XPOS)); 
SIGMA_YY = zeros(1,length(THETA)*length(XPOS)); 
SIGMA_XY = zeros(1,length(THETA)*length(XPOS));
Y_THETA = zeros(1,length(THETA)*length(XPOS)); 
Y_XPOS = zeros(1,length(THETA)*length(XPOS));

counter = 1;
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
        %img(img<0) = 0;
        img(img<100) = 0;
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
        sigma_xx = sum(img*((x-mu_x).^2)')/s;
        sigma_yy = sum((y-mu_y).^2*img)/s;
        sigma_xy = (y-mu_y)*img*(x-mu_x)'/s;
        MU_X(counter) = mu_x;
        MU_Y(counter) = mu_y;
        SIGMA_XX(counter) = sqrt(sigma_xx);
        SIGMA_YY(counter) = sqrt(sigma_yy);
        SIGMA_XY(counter) = real(sqrt(sigma_xy));
        Y_THETA(counter) = theta;
        Y_XPOS(counter) = xpos;
        counter = counter+1;
    end
end

%% save data
save workspace

%% load data
load workspace

%% DNN
X = [ones(length(Y_THETA),1), MU_X',MU_Y',SIGMA_XX',SIGMA_XY',SIGMA_YY'];

layers = [InputLayer([6 1])
          fullyConnectedLayer(10)
          reluLayer
          fullyConnectedLayer(10)
          reluLayer
          fullyConnectedLayer(1)
          regressionLayer()];








[b_theta,bint_theta,r_theta,rint_theta,stats_theta] = regress(Y_THETA',X);
[b_xpos,bint_xpos,r_xpos,rint_xpos,stats_xpos] = regress(Y_XPOS',X);

%%
Y_THETA_reg = X*b_theta;
Y_XPOS_reg = X*b_xpos;
figure(1)
scatter3(Y_THETA,Y_XPOS,Y_THETA_reg);
xlabel('theta')
ylabel('xpos')
zlabel('theta_reg')
hold on
scatter3(Y_THETA,Y_XPOS,Y_THETA);
hold off
figure(2)
scatter3(Y_THETA,Y_XPOS,Y_XPOS_reg);
xlabel('theta')
ylabel('xpos')
zlabel('xpos_reg')
hold on
scatter3(Y_THETA,Y_XPOS,Y_XPOS);
hold off