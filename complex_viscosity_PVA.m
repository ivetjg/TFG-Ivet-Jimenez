

clear; clc; close all;


%% Carregar fitxers 

ctrl_r1 = readtable('10_GelMA_R1.csv');
ctrl_r2 = readtable('10_GelMA_R2.csv');

pva_2_5_r1 = readtable('2_5_PVA_10_GelMA_R1.csv');
pva_2_5_r2 = readtable('2_5_PVA_10_GelMA_R2.csv');

pva_5_r1 = readtable('5_PVA_10_GelMA_R1.csv');
pva_5_r2 = readtable('5_PVA_10_GelMA_R2.csv');

pva_7_5_r1 = readtable('7_5_PVA_10_GelMA_R1.csv');
pva_7_5_r2 = readtable('7_5_PVA_10_GelMA_R2.csv');



%% Processar grups
[T_ctrl,    eta_ctrl]    = process_group(ctrl_r1,     ctrl_r2);
[T_2_5,     eta_2_5]     = process_group(pva_2_5_r1,  pva_2_5_r2);
[T_5,       eta_5]       = process_group(pva_5_r1,    pva_5_r2);
[T_7_5,     eta_7_5]     = process_group(pva_7_5_r1,  pva_7_5_r2);
 
%% Plot
figure('Name', 'Complex Viscosity vs Temperature', ...
       'Color', 'white', 'Position', [100, 100, 800, 500]);
 
colors = [
    0.00, 0.00, 0.00;   % ctrl     - negre
    0.40, 0.40, 0.40;   % 2.5%     - gris fosc
    0.60, 0.60, 0.60;   % 5%       - gris mig
    0.80, 0.80, 0.80;   % 7.5%     - gris clar
];
 
groups = {T_ctrl, eta_ctrl, '10% GelMA (ctrl)'; ...
          T_2_5,  eta_2_5,  '2.5% PVA'; ...
          T_5,    eta_5,    '5% PVA'; ...
          T_7_5,  eta_7_5,  '7.5% PVA'};
 
hold on;
for i = 1:size(groups, 1)
    plot(groups{i,1}, groups{i,2}, '-o', ...
         'Color', colors(i,:), ...
         'LineWidth', 1.5, ...
         'MarkerSize', 4, ...
         'MarkerFaceColor', colors(i,:), ...
         'DisplayName', groups{i,3});
end
 
xlabel('Temperature (°C)', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('|\eta*| (mPa·s)',   'FontSize', 13, 'FontWeight', 'bold');
title('Complex Viscosity vs Temperature', 'FontSize', 15, 'FontWeight', 'bold');
 
legend('show', 'Location', 'best', 'FontSize', 11);
set(gca, 'YScale', 'log');
grid on;
box on;
set(gca, 'FontSize', 11);
 

%% Interpolar i filtrar soroll < 25°C
function [T, eta] = process_group(r1, r2)
    T_ref = r1.Temperature;
    eta1  = r1.Complex_Viscosity;
    [T2_unique, idx] = unique(r2.Temperature);
    eta2  = interp1(T2_unique, r2.Complex_Viscosity(idx), T_ref, 'linear', NaN);
    eta_mean = mean([eta1, eta2], 2, 'omitnan');
    data = sortrows([T_ref, eta_mean], 1);
    data = data(data(:,1) < 25, :);
    T   = data(:,1);
    eta = data(:,2);
end

