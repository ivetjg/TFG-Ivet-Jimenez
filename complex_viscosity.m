

% Plot Storage Modulus vs Temperature
clear; clc; close all;

%% Carregar fitxers 
r1_7 = readtable('7.5%_R1_data.csv');
r2_7 = readtable('7.5%_R2_data.csv');

r1_10 = readtable('10%_R2_data.csv');
r2_10 = readtable('10%_R3_data.csv');

r1_12 = readtable('12.5%_R1_data.csv');
r2_12 = readtable('12.5%_R1_data.csv');

%% Interpolar sobre l'eix de temperatura

T_ref7 = r1_7.Temperature;
eta7 = r1_7.Complex_Viscosity;
eta7_2 = interp1(r2_7.Temperature, r2_7.Complex_Viscosity, T_ref7, 'linear', NaN);
eta_mean7  = mean([eta7,  eta7_2],   2, 'omitnan');

T_ref10 = r1_10.Temperature;
eta10 = r1_10.Complex_Viscosity;
eta10_2 = interp1(r2_10.Temperature, r2_10.Complex_Viscosity, T_ref10, 'linear', NaN);
eta_mean10  = mean([eta10,  eta10_2],   2, 'omitnan');

T_ref12 = r1_12.Temperature;
eta12 = r1_12.Complex_Viscosity;
eta12_2 = interp1(r2_12.Temperature, r2_12.Complex_Viscosity, T_ref12, 'linear', NaN);
eta_mean12  = mean([eta12,  eta12_2],   2, 'omitnan');

%% Ordenar per temperatura i filtrar soroll (< 25ºC)

data_mean_7 = [T_ref7, eta_mean7];
data_mean_7 = sortrows(data_mean_7, 1);
data_mean_7 = data_mean_7(data_mean_7(:,1) < 25, :);
Temperature_7= data_mean_7(:,1);
Complex_Viscosity_7 = data_mean_7(:,2);

data_mean_10 = [T_ref10, eta_mean10];
data_mean_10 = sortrows(data_mean_10, 1);
data_mean_10 = data_mean_10(data_mean_10(:,1) < 25, :);
Temperature_10       = data_mean_10(:,1);
Complex_Viscosity_10 = data_mean_10(:,2);

data_mean_12 = [T_ref12, eta_mean12];
data_mean_12 = sortrows(data_mean_12, 1);
data_mean_12 = data_mean_12(data_mean_12(:,1) < 25, :);
Temperature_12      = data_mean_12(:,1);
Complex_Viscosity_12 = data_mean_12(:,2);


%% Plot Complex viscosity
figure('Name', 'Complex Viscosity vs Temperature', ...
       'Color', 'white', 'Position', [100, 100, 800, 500]);

plot(Temperature_7, Complex_Viscosity_7, 'k-o', 'LineWidth', 1.5, ...
     'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', '|\eta*| GelMA a 7.5%');

hold on;
plot(Temperature_10, Complex_Viscosity_10, 'k-o', 'LineWidth', 1.5, 'Color', [0.5 0.5 0.5], ...
     'MarkerSize', 4, 'MarkerFaceColor', [0.5 0.5 0.5], 'DisplayName', '|\eta*| GelMA a 10%');

hold on;
plot(Temperature_12, Complex_Viscosity_12, 'k-o', 'LineWidth', 1.5, 'Color', [0.75 0.75 0.75], ...
     'MarkerSize', 4, 'MarkerFaceColor', [0.75 0.75 0.75], 'DisplayName', '|\eta*| GelMA a 12.5%');

xlabel('Temperature (°C)', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('Viscosity (mPa·s)', 'FontSize', 13, 'FontWeight', 'bold');
title("Complex Viscosity vs Temperature", 'FontSize', 15, 'FontWeight', 'bold');

legend('show', 'Location', 'best', 'FontSize', 11);
set(gca, 'YScale', 'log');
grid on;
box on;
set(gca, 'FontSize', 11);


