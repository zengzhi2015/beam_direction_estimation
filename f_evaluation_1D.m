function f_evaluation_1D( basePath, B_K, distance )
%F_EVALUATION_1D Summary of this function goes here
%   Detailed explanation goes here
    table = xlsread([basePath 'ALPHA.xlsx'])';
    background = imread([basePath 'background.png']);
    background = double(background);

    ALPHA = (table(1,:)+table(2,:)/60.0+table(3,:)/3600.0)*pi/180;
    ALPHA = ALPHA-ALPHA(1);
    MU_X = zeros(1,length(ALPHA)); 
    MU_Y = zeros(1,length(ALPHA)); 
    Y_ALPHA = ALPHA;

    %% Calculate the centers of the light spots
    figure('Name','Image','NumberTitle','off')
    for j = 1:length(ALPHA)
        % read image
        imgPath = [basePath sprintf('%03d.png',j)];
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

    % plot
    figure('Name','Distribution of samples','NumberTitle','off')
    plot(MU_X,MU_Y,'-o');
    xlabel('\mu_x (pixels)')
    ylabel('\mu_y (pixels)')
    %% Calculate distances
    MU_X_0 = mean(MU_X(1));
    MU_Y_0 = mean(MU_Y(1));
    DIS = zeros(1,length(ALPHA));
    for j = 1:length(ALPHA)
        dis_norm = sqrt((MU_X(j)-MU_X_0)^2 + (MU_Y(j)-MU_Y_0)^2);
        temp_direction = cross([MU_X(j),MU_Y(j),0],[MU_X_0,MU_Y_0,0]);
        DIS(j) = dis_norm*sign(temp_direction(3));
    end
    %% regression evaluation
    k_eval = [1,distance]*B_K;
    b_eval = [0;k_eval];
    Y_ALPHA_reg = zeros(size(Y_ALPHA));

    for j = 1:length(ALPHA)
        mu_x = MU_X(j);
        mu_y = MU_Y(j);
        dis_norm = sqrt((mu_x-MU_X_0)^2+(mu_y-MU_Y_0)^2);
        temp_direction = cross([mu_x,mu_y,0],[MU_X_0,MU_Y_0,0]);
        dis = dis_norm*sign(temp_direction(3));
        Y_ALPHA_reg(j) = [1,dis]*b_eval;
    end
    %% Plot regression
    figure('Name','Distribution of \alpha_r_e_g','NumberTitle','off')
    scatter(ALPHA,Y_ALPHA_reg);
    xlabel('\alpha (rad)')
    ylabel('\alpha_r_e_g (rad)')
    hold on
    plot(ALPHA,Y_ALPHA','-*');
    hold off
    figure('Name','Distribution of \alpha_r_e_g - \alpha','NumberTitle','off')
    plot(ALPHA,Y_ALPHA_reg-Y_ALPHA,'-o');
    xlabel('\alpha (rad)')
    ylabel('\alpha_r_e_g - \alpha (rad)')
end

