function f_noise_analysis( basePath, K)
%F_NOISE_ANALYSIS Summary of this function goes here
%   Detailed explanation goes here
    background = imread([basePath 'background.png']);
    background = double(background);

    MU_X = zeros(1,10); 
    MU_Y = zeros(1,10); 

    %% Calculate the centers of the light spots
    figure('Name','Noise Image','NumberTitle','off')
    for j = 1:10
        % read image
        imgPath = [basePath sprintf('c%d.png',j)];
        img = imread(imgPath);
        img = double(img);
        % background subtraction
        img = abs(img - background);
        % filtering
        img = medfilt2(img,[3,3]);
        max_level = max(max(img));
        avg_max_level = mean(mean(img(img>max_level*0.9)));
        img = img-avg_max_level/10;
        img(img<1) = 0;
        % convert
        img = img/(avg_max_level*1.2);
        img(img>1) = 1;
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
    %% plot distribution
    figure('Name','Distribution of samples','NumberTitle','off')
    scatter(MU_X,MU_Y);
    xlabel('\mu_x (pixels)')
    ylabel('\mu_y (pixels)')
    %%
    MU_X_mean = mean(MU_X);
    MU_Y_mean = mean(MU_Y);
    DIS = sqrt((MU_X-MU_X_mean).^2 + (MU_Y-MU_Y_mean).^2);
    figure('Name','Box plot of distribution noise','NumberTitle','off')
    boxplot(DIS)
    ylabel('distribution noise (pixel)')
    %%
    ANG_DIS = abs(DIS'*K');
    figure('Name','Box plot of angular noise','NumberTitle','off')
    boxplot(ANG_DIS)
    ylabel('angular noise (rad)')
end

