clc
clear all
% 3D lift calculations
data2D = [
        -5.0000 -0.2446 0.0140;
        -4.0000 -0.1465 0.0091;
        -3.0000 -0.0401 0.0073;
        -2.0000 0.0658 0.0059;
        -1.0000 0.1717 0.0049;
        0.0000 0.2737 0.0043;
        1.0000 0.4058 0.0045;
        2.0000 0.5143 0.0050;
        3.0000 0.6167 0.0057;
        4.0000 0.7194 0.0066;
        5.0000 0.8201 0.0078;
        6.0000 0.9193 0.0092;
        7.0000 1.0129 0.0112;
        8.0000 1.1027 0.0134;
        9.0000 1.1844 0.0165;
        10.0000 1.2533 0.0201;
        11.0000 1.2865 0.0252;
        12.0000 1.2763 0.0332;
        13.0000 1.2329 0.0475;
        14.0000 1.1635 0.0720;
        15.0000 1.0951 0.1052;
        ];
    
alpha = data2D(:,1); % Angle of attack
Clift = data2D(:,2); % 2D coefficient of lift
CDrag = data2D(:,3); % 2D coefficient of drag

e = 0.9; % Span efficiency factor
AR = 16.5; % Aspect Ratio

%linear region
alpha_Upper = 5;
alpha_Lower = 4;

%Find index of alpha values
x1=find(data2D(:,1)==alpha_Lower);
x2=find(data2D(:,1)==alpha_Upper);

%initial estimate of alpha
a_0 = (Clift(x2)-Clift(x1))/(alpha(x2)-alpha(x1));

%estimate alpha for finite wing
a = (a_0)/(1 + ((57.3 * a_0)/(pi * e * AR)));

%find zero lift angle of attack
sign = find(Clift>0,1);
Alpha0 = mean([alpha(sign), alpha(sign - 1)]);

%use alpha to calculate cl
CL_3D = a .* ( alpha - Alpha0);
 
% 3D coefficient of drag
D_i = (CL_3D).^2 ./ (pi*e*AR);

%calculate total drag for wing
WingD = CDrag + D_i;

%find min drag alpha value
alpha_MinDrag = alpha(find(WingD == min(WingD)));
CL_MinDrag = a * (alpha_MinDrag - Alpha0);

%define variables
%oswald's efficiency factor
e0 = 1.78 * (1 - 0.045 .* AR.^(0.68)) - 0.64;
k1 = 1 / (pi * e * AR);
k2 = -2 * k1 * CL_MinDrag;

CFE = .004;
SWet = 1.2874 + .784142 + .1992;
Sref = .63;
CD_minalt = CFE * SWet / Sref; 
CD_0alt = CD_minalt + k1 * CL_MinDrag^2;
CDalt = CD_0alt + k1 * CL_3D .^2 + k2 * CL_3D;

%total polar drag for aircraft
CD_Polar = min(WingD) + k1 * ((CL_3D - CL_MinDrag) .^ 2);

%For CFD
dataCFD=[
    -5,-0.32438,0.044251;
    -4,-0.21503,0.033783;
    -3,-0.10081,0.028627;
    -2,0.010503,0.025864;
    -1,0.12155,0.024643;
    0,0.24163,0.025099;
    1,0.34336,0.025635;
    2,0.45256,0.02766;
    3,0.56037,0.030677;
    4,0.66625,0.034855;
    5,0.76942,0.040403;
    6,0.86923,0.04759;
    7,0.96386,0.057108;
    8,1.0441,0.070132;
    9,1.0743,0.090921;
    10,1.0807,0.11193;
    11,1.0379,0.13254;
    12,1.034,0.15645;
    ];
alphaCFD = dataCFD(:,1); % Angle of attack
CliftCFD = dataCFD(:,2); % 3D coefficient of lift
CDragCFD = dataCFD(:,3); % 3D coefficient of drag

%% plot and compare the lift with respect to alpha
figure(1)
plot(alpha, CL_3D, '--', 'LineWidth', 2);
hold on
plot(alphaCFD, CliftCFD, '--', 'LineWidth', 2);
hold on
plot(alpha, Clift, '--', 'LineWidth', 2);
hold off

%mark each plot
title('Compare Lift Results of Calculated and CFD Data');
legend('3D Calculated Data', 'CFD Data', '2D Calculated Data', 'Location', 'Southeast');
xlabel('\alpha (\circ)');
ylabel('C_L');

%% compare the Drag with respect to lift
figure(2)
plot(CL_3D, CD_Polar, '--', 'LineWidth', 2);
hold on
plot(CL_3D, WingD, '--', 'LineWidth', 2);
hold on
plot(CliftCFD, CDragCFD, '--', 'LineWidth', 2);
hold off
title('Compare Polar Drag Results of Calculated and CFD Data');
legend('3D Calculated Polar Drag', 'Calculated Wing Drag', 'CFD Polar Drag', 'Location', 'Northwest');
xlabel('C_L');
ylabel('C_D');

%% Plot and compare the C_L/C_D with respect to alpha
figure(3)
CLCD3D =  CL_3D./WingD;
CLCDCFD = CliftCFD./CDragCFD;
plot(alpha, CLCD3D, '--', 'LineWidth', 2);
hold on
plot(alphaCFD, CLCDCFD, '--', 'LineWidth', 2);
hold off
title('Compare C_L over C_D for Calculated and CFD Data');
legend('Calculated Wing Lift over Drag', 'CFD Lift over Drag', 'Location', 'Northwest');
xlabel('\alpha (\circ)');
ylabel('C_L / C_D');

%% compare methods for finding drag polar
figure(4)
plot(CL_3D, CD_Polar, '--', 'LineWidth', 2);
hold on
plot(CL_3D, CDalt, '--', 'LineWidth', 2);
hold off;
title('Compare the Methods of Calculating Wing Drag');
legend('k1', 'k1 & k2', 'Location', 'Northwest');
xlabel('C_L');
ylabel('C_D');