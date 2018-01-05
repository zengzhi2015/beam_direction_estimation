% Optimize image quality
%%
clc;
clear;
close all
% Read images and extract features

basePath = '/home/zhi/Datasets/beam_direction/Experiment_20171226/100cm/';
table = xlsread([basePath 'ALPHA.xlsx'])';
background = imread([basePath 'background.png']);
background = double(background);

ALPHA = (table(1,:)+table(2,:)/60+table(3,:)/3600)*pi/180;
MU_X = zeros(1,length(ALPHA)); 
MU_Y = zeros(1,length(ALPHA)); 
Y_ALPHA = ALPHA;

j = 22;
alpha = ALPHA(j);
% read image
imgPath = [basePath sprintf('%03d.png',j)];
img = imread(imgPath);
img = double(img);
% background subtraction
img = abs(img - background);
% cropping
img = img(40:160,100:240);
max_level = max(max(img));
avg_max_level = mean(mean(img(img>max_level*0.9)));
img = img-avg_max_level/10;
img(img<1) = 0;
% convert
img = img/(avg_max_level*1.2);
img(img>1) = 1;

img = imresize(img, 2.0);
% img(img>0.5) = 0.0;
img_mod = imsharpen(img, 'Radius',3,'Amount',20);
%img(img<0.1) = 0;
% img = double(localcontrast(uint8(img*255)))/255;
img_mod = double(locallapfilt(uint8(img_mod*255), 0.5, 0.1))/255;
img_mod = double(locallapfilt(uint8(img_mod*255), 0.5, 0.1))/255;
img_mod = double(locallapfilt(uint8(img_mod*255), 0.5, 0.1))/255;
img_mod = edge(img_mod,'Canny',0.7);
% se = strel('line',3,3);
% img_mod = imdilate(img_mod,se);
% img_mod = imgaussfilt(1*img_mod,[3,3]);
% img_mod = double(locallapfilt(uint8(img_mod*255), 0.5, 0.1))/255;
% img = imadjust(img);
% img = imadjust(img,[0.1,0.9],[]);
% img = histeq(img);
imshow(img_mod)

radiusRange = [9,15];
[centers,radii,metric] = imfindcircles(img_mod,radiusRange,'ObjectPolarity','dark','EdgeThreshold',0.2,'Sensitivity',0.92);
viscircles(centers, radii,'Color','b','LineStyle','-','LineWidth',0.5);

%%
for j = 1:length(ALPHA)
    alpha = ALPHA(j);
    % read image
    imgPath = [basePath sprintf('%03d.png',j)];
    img = imread(imgPath);
    img = double(img);
    % background subtraction
    img = abs(img - background);
    % cropping
    % img = img(70:130,110:210);
    img = img(40:160,100:240);
    % img = bfilter2(img,25,[25 25/2]);
    % img = imgaussfilt(img,[5,5]);
    % threshold
%     img(img<2000) = 0;
    % img(img<max(max(img))/5) = 0;
    max_level = max(max(img));
    avg_max_level = mean(mean(img(img>max_level*0.9)));
    img = img-avg_max_level/10;
    img(img<1) = 0;
    % convert
    %img = img/65535;
    img = img/(avg_max_level*1.2);
    img(img>1) = 1;
    % img = imgaussfilt(img,[3,3]);
    % imshow(img)
    %BW = edge(img,'Canny');
    %imshow(BW)
    radiusRange = [6,10];
    [centers,radii] = imfindcircles(img,radiusRange);
    viscircles(centers, radii,'Color','b');
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

% plot
figure('Name','Distribution of samples','NumberTitle','off')
plot(MU_X,MU_Y,'-o');
xlabel('\mu_x (pixels)')
ylabel('\mu_y (pixels)')
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