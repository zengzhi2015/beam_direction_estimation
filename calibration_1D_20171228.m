% Yesterday, we recorded the measurements with the device been at different
% distances from the source.
%%
clc;
clear;
close all
%% Read images and extract features

basePath = '/home/zhi/Datasets/beam_direction/Experiment_20171226/398cm/';
table = xlsread([basePath 'ALPHA.xlsx'])';
background = imread([basePath 'background.png']);
background = double(background);

ALPHA = (table(1,:)+table(2,:)/60+table(2,:)/3600)*pi/180;
MU_X = zeros(1,length(ALPHA)); 
MU_Y = zeros(1,length(ALPHA)); 
Y_ALPHA = ALPHA;

for j = 1:length(ALPHA)
    alpha = ALPHA(j);
    % read image
    imgPath = [basePath sprintf('%03d.png',j)];
    img = imread(imgPath);
    img = double(img);
    % background subtraction
    img = abs(img - background);
    % cropping
    img = img(50:150,100:220);
    % threshold
    img(img<2000) = 0;
    % convert
    img = img/65535;
    imshow(img)
    % feature extraction
    [m,n]=size(img);
    s = sum(sum(img));
    x = linspace(0,n-1,n);
    y = linspace(0,m-1,m);
    mu_x = sum(img*x')/s;
    mu_y = sum(y*img)/s;
    MU_X(j) = mu_x;
    MU_Y(j) = mu_y;
end


%% save data
% save remote

%% load data
% load remote

%% plot
figure('Name','Distribution of \mu_x','NumberTitle','off')
scatter(ALPHA,MU_X);
xlabel('\alpha (rad)')
ylabel('\mu_x (pixels)')
%% regression
X_alpha = [ones(length(Y_ALPHA),1), ...
           MU_X', ...
           MU_Y'];
% X_alpha = [ones(length(Y_ALPHA),1), ...
%            MU_X', ...
%            MU_Y',...
%            MU_X'.^2,...
%            MU_Y'.^2,...
%            MU_X'.*MU_Y'];
Y_alpha = Y_ALPHA';

[b,bint,r,rint,stats] = regress(Y_alpha,X_alpha);

%% regression evaluation
Y_ALPHA_reg = zeros(size(Y_ALPHA));

for j = 1:length(ALPHA)
    mu_x = MU_X(j);
    mu_y = MU_Y(j);
    Y_ALPHA_reg(j) = [1,mu_x,mu_y]*b;
%     Y_ALPHA_reg(j) = [1,mu_x,mu_y,mu_x^2,mu_y^2,mu_x*mu_y]*b;
end

figure('Name','Box plot of regression residuals','NumberTitle','off')
boxplot(abs(r))
%% Plot regression
figure('Name','Distribution of \alpha_r_e_g','NumberTitle','off')
scatter(ALPHA,Y_ALPHA_reg);
xlabel('\alpha (rad)')
ylabel('\alpha_r_e_g (rad)')
%figure('Name','Distribution of \alpha','NumberTitle','off')
hold on
plot(ALPHA,Y_ALPHA);
% xlabel('\alpha')
% ylabel('\alpha')
hold off
figure('Name','Distribution of \alpha_r_e_g - \alpha','NumberTitle','off')
plot(ALPHA,Y_ALPHA_reg-Y_ALPHA,'-o');
xlabel('\alpha (rad)')
ylabel('\alpha_r_e_g - \alpha (rad)')
%% Error evaluation
% figure('Name','Distribution of errors','NumberTitle','off')
% temp_diff = Y_ALPHA_reg(2:length(ALPHA))-Y_ALPHA_reg(1:length(ALPHA)-1)-1;
% surf(GRID_ALPHA(:,1:length(ALPHA)-1),GRID_YPOS(:,1:length(ALPHA)-1),temp_diff*800);
% xlabel('\alpha')
% ylabel('y')
% zlabel('error urad/800urad')
% disp(mean(mean(abs(temp_diff*800))))