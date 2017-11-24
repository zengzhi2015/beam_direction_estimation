clc;
clear;
close all
%% Read images and extract features

basePath = '/home/zhi/Datasets/beam_direction/img_theta_x/';
% background = imread([basePath 'background.png']);
background = imread([basePath 'img_50_50.png']);
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
        img = abs(img - background);
        % cropping
        img = img(80:180,100:250);
        % threshold
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

%% DIRECT test
i = 70;
j = 70;
x_test = [MU_X(i,j),MU_Y(i,j),SIGMA_XX(i,j),SIGMA_XY(i,j),SIGMA_YY(i,j)];

i_star = -1;
j_star = -1;
diff_star = Inf;
for i = 1:length(THETA)
    for j = 1:length(XPOS)
        mu_x = MU_X(i,j);
        mu_y = MU_Y(i,j);
        sigma_xx = SIGMA_XX(i,j);
        sigma_xy = SIGMA_XY(i,j);
        sigma_yy = SIGMA_YY(i,j);
        diff = norm(x_test - [mu_x mu_y sigma_xx sigma_xy sigma_yy]);
        if diff < diff_star
            i_star = i;
            j_star = j;
            diff_star = diff;
        end
    end
end
        
%% Full test
Y_THETA_reg = zeros(size(Y_THETA));
Y_XPOS_reg = zeros(size(Y_XPOS));

for i = 1:length(THETA)
    disp(i)
    for j = 1:length(XPOS)
        if i==50 && j == 50
            Y_XPOS_reg(i,j) = 50;
            Y_THETA_reg(i,j) = 50;
            continue
        end
        [Y_THETA_reg(i,j),Y_XPOS_reg(i,j)] = find_match([MU_X(i,j),MU_Y(i,j), ...
            SIGMA_XX(i,j),SIGMA_XY(i,j),SIGMA_YY(i,j)], ...
            MU_X,MU_Y,SIGMA_XX,SIGMA_XY,SIGMA_YY);
    end
end

%% Plot

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