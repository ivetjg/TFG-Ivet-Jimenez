

% Plot Storage Modulus vs Temperature
clear; clc; close all;

%% 1 REPLICA 

% %% Carregar dades 
% data = readtable('10%_R3_data.csv');
% Temperature      = data.Temperature;
% Storage_Modulus  = data.Storage_Modulus;
% Loss_Modulus     = data.Loss_Modulus;
% Complex_Viscosity = data.Complex_Viscosity;
% 
% %% Ordenar per temperatura
% [Temperature, idx] = sort(Temperature);
% Storage_Modulus   = Storage_Modulus(idx);
% Loss_Modulus      = Loss_Modulus(idx);
% Complex_Viscosity = Complex_Viscosity(idx);
% 
% % Filtrar soroll
% mask = Temperature < 25;
% Temperature     = Temperature(mask);
% Storage_Modulus = Storage_Modulus(mask);
% Loss_Modulus    = Loss_Modulus(mask);
% Complex_Viscosity = Complex_Viscosity(mask);


%% 2 REPLIQUES
%% Carregar dades
r1 = readtable('12.5%_R1_data.csv');
r2 = readtable('12.5%_R2_data.csv');

%% Interpolar sobre l'eix de temperatura
% (les rèpliques poden tenir temperatures lleugerament diferents)
T_ref = r1.Temperature;

G_s1 = r1.Storage_Modulus;
G_s2 = interp1(r2.Temperature, r2.Storage_Modulus, T_ref, 'linear', NaN);

G_l1 = r1.Loss_Modulus;
G_l2 = interp1(r2.Temperature, r2.Loss_Modulus, T_ref, 'linear', NaN);

eta1 = r1.Complex_Viscosity;
eta2 = interp1(r2.Temperature, r2.Complex_Viscosity, T_ref, 'linear', NaN);

%% Calcular mitjanes
G_s_mean  = mean([G_s1,  G_s2],  2, 'omitnan');
G_l_mean  = mean([G_l1,  G_l2],  2, 'omitnan');
eta_mean  = mean([eta1,  eta2],   2, 'omitnan');

%% Ordenar per temperatura i filtrar soroll (< 25ºC)
data_mean = [T_ref, G_s_mean, G_l_mean, eta_mean];
data_mean = sortrows(data_mean, 1);
data_mean = data_mean(data_mean(:,1) < 25, :);

Temperature       = data_mean(:,1);
Storage_Modulus   = data_mean(:,2);
Loss_Modulus      = data_mean(:,3);
Complex_Viscosity = data_mean(:,4);


%% Plot Storage + Loss Modulus vs Temperature
figure('Name', 'Storage & Loss Modulus vs Temperature', ...
       'Color', 'white', 'Position', [100, 100, 800, 500]);

plot(Temperature, Storage_Modulus, 'k-o', 'LineWidth', 1.5, ...
     'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', "G' - Storage Modulus");

hold on;
plot(Temperature, Loss_Modulus, '-^', 'LineWidth', 1.5, 'Color', [0.5 0.5 0.5], ...
     'MarkerSize', 4, 'MarkerFaceColor', [0.5 0.5 0.5], 'DisplayName', 'G" - Loss Modulus');

xlabel('Temperature (°C)', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('Modulus (Pa)', 'FontSize', 13, 'FontWeight', 'bold');
title("Storage & Loss Modulus vs Temperature", 'FontSize', 15, 'FontWeight', 'bold');

legend('show', 'Location', 'best', 'FontSize', 11);
set(gca, 'YScale', 'log');
grid on;
box on;
set(gca, 'FontSize', 11);

