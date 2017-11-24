clc;
clear;
close all
%% Read images and extract features

basePath = '/home/zhi/Datasets/beam_direction/img_theta_x/';
background = imread([basePath 'background.png']);
background = double(background);

THETA = 1:99;
XPOS = 1:99;
[GRID_THETA,GRID_XPOS] = meshgrid(THETA,XPOS);
MU_X = zeros(length(THETA),length(XPOS)); 
MU_Y = zeros(length(THETA),length(XPOS)); 
SIGMA_XX = zeros(length(THETA),length(XPOS)); 
SIGMA_YY = zeros(length(THETA),length(XPOS)); 
SIGMA_XY = zeros(length(THETA),length(XPOS));
Y_THETA = zeros(length(THETA),length(XPOS)); 
Y_XPOS = zeros(length(THETA),length(XPOS));

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
        MU_X(i,j) = mu_x;
        MU_Y(i,j) = mu_y;
        SIGMA_XX(i,j) = sqrt(sigma_xx);
        SIGMA_YY(i,j) = sqrt(sigma_yy);
        SIGMA_XY(i,j) = real(sqrt(sigma_xy));
        Y_THETA(i,j) = theta;
        Y_XPOS(i,j) = xpos;
    end
end

%% save data
save recursive

%% load data
load recursive

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
figure(3)
surf(GRID_THETA,GRID_XPOS,SIGMA_XX);
xlabel('theta')
ylabel('xpos')
zlabel('\sigma_x_x')
figure(4)
surf(GRID_THETA,GRID_XPOS,SIGMA_XY);
xlabel('theta')
ylabel('xpos')
zlabel('\sigma_x_y')
figure(5)
surf(GRID_THETA,GRID_XPOS,SIGMA_YY);
xlabel('theta')
ylabel('xpos')
zlabel('\sigma_y_y')

%% regression
B_THETA = zeros(11,length(THETA));
B_XPOS = zeros(11,length(XPOS));

for i = 1:length(THETA)
    X_theta = [ones(length(Y_THETA(i,:)),1), ...
               MU_X(i,:)', ...
               MU_Y(i,:)', ...
               SIGMA_XX(i,:)', ...
               SIGMA_XY(i,:)', ...
               SIGMA_YY(i,:)', ...
               MU_X(i,:)'.^2, ...
               MU_Y(i,:)'.^2, ... 
               SIGMA_XX(i,:)'.^2, ...
               SIGMA_XY(i,:)'.^2, ...
               SIGMA_YY(i,:)'.^2];
    Y_theta = THETA';
    B_THETA(:,i) = regress(Y_theta,X_theta);
end

for j = 1:length(XPOS)
    X_xpos = [ones(length(Y_XPOS(:,j)),1), ...
              MU_X(:,j), ...
              MU_Y(:,j), ...
              SIGMA_XX(:,j), ...
              SIGMA_XY(:,j), ...
              SIGMA_YY(:,j), ...
              MU_X(:,j).^2, ...
              MU_Y(:,j).^2, ... 
              SIGMA_XX(:,j).^2, ...
              SIGMA_XY(:,j).^2, ...
              SIGMA_YY(:,j).^2];
    Y_xpos = XPOS';
    B_XPOS(:,j) = regress(Y_xpos,X_xpos);
end
%% Plot B
figure(6)
for i = 1:length(B_THETA(:,1))
    subplot(3,4,i);
    plot(THETA,B_THETA(i,:),'-o');
end

figure(7)
for i = 1:length(B_XPOS(:,1))
    subplot(3,4,i);
    plot(XPOS,B_XPOS(i,:),'-o');
end

%% Plot regression
Y_THETA_reg = zeros(size(Y_THETA));
Y_XPOS_reg = zeros(size(Y_XPOS));

for i = 1:length(THETA)
    X_theta = [ones(length(Y_THETA(i,:)),1), ...
               MU_X(i,:)', ...
               MU_Y(i,:)', ...
               SIGMA_XX(i,:)', ...
               SIGMA_XY(i,:)', ...
               SIGMA_YY(i,:)', ...
               MU_X(i,:)'.^2, ...
               MU_Y(i,:)'.^2, ... 
               SIGMA_XX(i,:)'.^2, ...
               SIGMA_XY(i,:)'.^2, ...
               SIGMA_YY(i,:)'.^2];
    Y_XPOS_reg(i,:) = (X_theta*B_THETA(:,i))';
end

figure(8)
subplot(1,3,1)
surf(GRID_THETA,GRID_XPOS,Y_XPOS_reg);
xlabel('theta')
ylabel('xpos')
zlabel('XPOS_r_e_g')
subplot(1,3,2)
surf(GRID_THETA,GRID_XPOS,Y_XPOS);
xlabel('theta')
ylabel('xpos')
zlabel('XPOS')
subplot(1,3,3)
surf(GRID_THETA,GRID_XPOS,Y_XPOS_reg-Y_XPOS);
xlabel('theta')
ylabel('xpos')
zlabel('XPOS_r_e_g - XPOS')

for j = 1:length(XPOS)
    X_xpos = [ones(length(Y_XPOS(:,j)),1), ...
              MU_X(:,j), ...
              MU_Y(:,j), ...
              SIGMA_XX(:,j), ...
              SIGMA_XY(:,j), ...
              SIGMA_YY(:,j), ...
              MU_X(:,j).^2, ...
              MU_Y(:,j).^2, ... 
              SIGMA_XX(:,j).^2, ...
              SIGMA_XY(:,j).^2, ...
              SIGMA_YY(:,j).^2];
    Y_THETA_reg(:,j) = X_xpos*B_XPOS(:,j);
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


%% recursive regression
i = 60;
j = 30;
x_test = [1, ...
          MU_X(i,j), ...
          MU_Y(i,j), ...
          SIGMA_XX(i,j), ...
          SIGMA_XY(i,j), ...
          SIGMA_YY(i,j), ...
          MU_X(i,j).^2, ...
          MU_Y(i,j).^2, ... 
          SIGMA_XX(i,j).^2, ...
          SIGMA_XY(i,j).^2, ...
          SIGMA_YY(i,j).^2];


theta_0 = 50;
xpos_0 = x_test*B_THETA(:,max(1,min(99,round(theta_0))));

theta_1 = x_test*B_XPOS(:,max(1,min(99,round(xpos_0))));
xpos_1 = x_test*B_THETA(:,max(1,min(99,round(theta_1))));

theta_2 = x_test*B_XPOS(:,max(1,min(99,round(xpos_1))));
xpos_2 = x_test*B_THETA(:,max(1,min(99,round(theta_2))));

theta_3 = x_test*B_XPOS(:,max(1,min(99,round(xpos_2))));
xpos_3 = x_test*B_THETA(:,max(1,min(99,round(theta_3))));

theta_4 = x_test*B_XPOS(:,max(1,min(99,round(xpos_3))));
xpos_4 = x_test*B_THETA(:,max(1,min(99,round(theta_4))));

theta_5 = x_test*B_XPOS(:,max(1,min(99,round(xpos_4))));
xpos_5 = x_test*B_THETA(:,max(1,min(99,round(theta_5))));

theta_6 = x_test*B_XPOS(:,max(1,min(99,round(xpos_5))));
xpos_6 = x_test*B_THETA(:,max(1,min(99,round(theta_6))));

theta_7 = x_test*B_XPOS(:,max(1,min(99,round(xpos_6))));
xpos_7 = x_test*B_THETA(:,max(1,min(99,round(theta_7))));

theta_8 = x_test*B_XPOS(:,max(1,min(99,round(xpos_7))));
xpos_8 = x_test*B_THETA(:,max(1,min(99,round(theta_8))));

theta_9 = x_test*B_XPOS(:,max(1,min(99,round(xpos_8))));
xpos_9 = x_test*B_THETA(:,max(1,min(99,round(theta_9))));

theta_10 = x_test*B_XPOS(:,max(1,min(99,round(xpos_9))));
xpos_10 = x_test*B_THETA(:,max(1,min(99,round(theta_10))));

theta_11 = x_test*B_XPOS(:,max(1,min(99,round(xpos_10))));
xpos_11 = x_test*B_THETA(:,max(1,min(99,round(theta_11))));

theta_12 = x_test*B_XPOS(:,max(1,min(99,round(xpos_11))));
xpos_12 = x_test*B_THETA(:,max(1,min(99,round(theta_12))));

theta_13 = x_test*B_XPOS(:,max(1,min(99,round(xpos_12))));
xpos_13 = x_test*B_THETA(:,max(1,min(99,round(theta_13))));

theta_14 = x_test*B_XPOS(:,max(1,min(99,round(xpos_13))));
xpos_14 = x_test*B_THETA(:,max(1,min(99,round(theta_14))));

theta_15 = x_test*B_XPOS(:,max(1,min(99,round(xpos_14))));
xpos_15 = x_test*B_THETA(:,max(1,min(99,round(theta_15))));

theta_16 = x_test*B_XPOS(:,max(1,min(99,round(xpos_15))));
xpos_16 = x_test*B_THETA(:,max(1,min(99,round(theta_16))));
%%
figure(1)
scatter3(Y_THETA,Y_XPOS,Y_THETA_reg,'.');
xlabel('theta')
ylabel('xpos')
zlabel('theta_reg')
hold on
scatter3(Y_THETA,Y_XPOS,Y_THETA,'.');
hold off
figure(2)
scatter3(Y_THETA,Y_XPOS,Y_XPOS_reg,'.');
xlabel('theta')
ylabel('xpos')
zlabel('xpos_reg')
hold on
scatter3(Y_THETA,Y_XPOS,Y_XPOS,'.');
hold off