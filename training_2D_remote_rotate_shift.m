clc;
clear;
close all
%% Read images and extract features

basePath = '/home/zhi/Datasets/beam_direction/img_y_alpha/';
background = imread([basePath 'background.png']);
% background = imread([basePath 'img_50_50.png']);
background = double(background);

ALPHA = 15:35;
YPOS = 1:49;
[GRID_ALPHA,GRID_YPOS] = meshgrid(ALPHA,YPOS);
MU_X = zeros(length(YPOS),length(ALPHA)); 
MU_Y = zeros(length(YPOS),length(ALPHA)); 
Y_ALPHA = zeros(length(YPOS),length(ALPHA)); 
Y_XPOS = zeros(length(YPOS),length(ALPHA));

for i = 1:length(YPOS)
    for j = 1:length(ALPHA)
        ypos = YPOS(i);
        alpha = ALPHA(j);
        % read image
        imgPath = [basePath sprintf('img_%d_%d.png',ypos,alpha)];
        img = imread(imgPath);
        img = double(img);
        % background subtraction
        img = abs(img - background);
        % cropping
        img = img(80:180,50:250);
        % threshold
        img(img<100) = 0;
        % convert
        img = img/65535;
        % feature extraction
        [m,n]=size(img);
        s = sum(sum(img));
        x = linspace(0,n-1,n);
        y = linspace(0,m-1,m);
        mu_x = sum(img*x')/s;
        mu_y = sum(y*img)/s;
        MU_X(i,j) = mu_x;
        MU_Y(i,j) = mu_y;
        Y_ALPHA(i,j) = alpha;
        Y_XPOS(i,j) = ypos;
    end
end

%% save data
% save remote

%% load data
% load remote

%% plot
figure('Name','Distribution of \mu_x','NumberTitle','off')
surf(GRID_ALPHA,GRID_YPOS,MU_X);
xlabel('\alpha')
ylabel('y')
zlabel('\mu_x')
figure('Name','Distribution of \mu_y','NumberTitle','off')
surf(GRID_ALPHA,GRID_YPOS,MU_Y);
xlabel('\alpha')
ylabel('y')
zlabel('\mu_y')

%% regression

X_alpha = zeros(length(ALPHA)*length(YPOS),3);
Y_alpha = zeros(length(ALPHA)*length(YPOS),1);

for i = 1:length(YPOS)
    X_alpha((i-1)*length(ALPHA)+1:i*length(ALPHA),:) = ...
              [ones(length(Y_ALPHA(i,:)),1), ...
               MU_X(i,:)', ...
               MU_Y(i,:)'];
    Y_alpha((i-1)*length(ALPHA)+1:i*length(ALPHA),1) = Y_ALPHA(i,:)';
end

[b,bint,r,rint,stats] = regress(Y_alpha,X_alpha);

        
%% regression evaluation
Y_ALPHA_reg = zeros(size(Y_ALPHA));

for i = 1:length(YPOS)
    for j = 1:length(ALPHA)
        mu_x = MU_X(i,j);
        mu_y = MU_Y(i,j);
        Y_ALPHA_reg(i,j) = [1,mu_x,mu_y]*b;
    end
end
figure('Name','Box plot of regression residuals','NumberTitle','off')
boxplot(r)
%% Plot regression
figure('Name','Distribution of \alpha_r_e_g','NumberTitle','off')
surf(GRID_ALPHA,GRID_YPOS,Y_ALPHA_reg);
xlabel('\alpha')
ylabel('y')
zlabel('\alpha_r_e_g')
figure('Name','Distribution of \alpha','NumberTitle','off')
surf(GRID_ALPHA,GRID_YPOS,Y_ALPHA);
xlabel('\alpha')
ylabel('y')
zlabel('\alpha')
figure('Name','Distribution of \alpha_r_e_g - \alpha','NumberTitle','off')
surf(GRID_ALPHA,GRID_YPOS,Y_ALPHA_reg-Y_ALPHA);
xlabel('\alpha')
ylabel('y')
zlabel('\alpha_r_e_g - \alpha')
%% Error evaluation
figure('Name','Distribution of errors','NumberTitle','off')
temp_diff = Y_ALPHA_reg(:,2:length(ALPHA))-Y_ALPHA_reg(:,1:length(ALPHA)-1)-1;
surf(GRID_ALPHA(:,1:length(ALPHA)-1),GRID_YPOS(:,1:length(ALPHA)-1),temp_diff*800);
xlabel('\alpha')
ylabel('y')
zlabel('error urad/800urad')
disp(mean(mean(abs(temp_diff*800))))