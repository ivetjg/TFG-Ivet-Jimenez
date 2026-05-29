

% Plot Storage Modulus vs Temperature
clear; clc; close all;

%% Load the three replicates
r1 = readtable('12.5%_R2_data.csv');
r2 = readtable('12.5%_R3_data.csv');
 
%% Interpolate R2 onto R1 temperature axis
T_ref = r1.Temperature;
 
G_s1 = r1.Storage_Modulus;
G_s2 = interp1(r2.Temperature, r2.Storage_Modulus, T_ref, 'linear', NaN);
 
G_l1 = r1.Loss_Modulus;
G_l2 = interp1(r2.Temperature, r2.Loss_Modulus, T_ref, 'linear', NaN);
 
eta1 = r1.Complex_Viscosity;
eta2 = interp1(r2.Temperature, r2.Complex_Viscosity, T_ref, 'linear', NaN);
 
%% Compute means
G_s_mean = mean([G_s1, G_s2], 2, 'omitnan');
G_l_mean = mean([G_l1, G_l2], 2, 'omitnan');
eta_mean = mean([eta1, eta2],  2, 'omitnan');
 
%% Ordenar per temperatura i filtrar soroll (< 25ºC)
data_mean = [T_ref, G_s_mean, G_l_mean, eta_mean];
data_mean = sortrows(data_mean, 1);
data_mean = data_mean(data_mean(:,1) < 25, :);
 
Temperature       = data_mean(:,1);
Storage_Modulus   = data_mean(:,2);
Loss_Modulus      = data_mean(:,3);
Complex_Viscosity = data_mean(:,4);
 
%% Plot Storage + Loss
figure('Name', 'Storage & Loss Modulus vs Temperature', ...
       'Color', 'white', 'Position', [100, 100, 800, 500]);
 
plot(Temperature, Storage_Modulus, 'k-o', 'LineWidth', 1.5, ...
     'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', "G' - Storage Modulus");
hold on;
plot(Temperature, Loss_Modulus, '-^', 'LineWidth', 1.5, 'Color', [0.5 0.5 0.5], ...
     'MarkerSize', 4, 'MarkerFaceColor', [0.5 0.5 0.5], 'DisplayName', 'G" - Loss Modulus');
 
xlabel('Temperature (°C)', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('Modulus (Pa)',      'FontSize', 13, 'FontWeight', 'bold');
title("Storage & Loss Modulus vs Temperature", 'FontSize', 15, 'FontWeight', 'bold');
 
legend('show', 'Location', 'best', 'FontSize', 11);
set(gca, 'YScale', 'log');
grid on; box on;
set(gca, 'FontSize', 11);
 
%% Calcular punt de creuament G' = G'' per a cada rèplica
crossover_temps = [];
 
repliques = {r1, r2};
for k = 1:length(repliques)
    rep = repliques{k};
 
    % Ordenar i filtrar
    data_rep = sortrows([rep.Temperature, rep.Storage_Modulus, rep.Loss_Modulus], 1);
    data_rep = data_rep(data_rep(:,1) < 25, :);
 
    T_rep  = data_rep(:,1);
    Gs_rep = data_rep(:,2);
    Gl_rep = data_rep(:,3);
 
    diff_rep = Gs_rep - Gl_rep;
 
    % Interpolació lineal per trobar el zero exacte
    for i = 1:length(diff_rep)-1
        if diff_rep(i) * diff_rep(i+1) < 0
            t1 = T_rep(i);   t2 = T_rep(i+1);
            d1 = diff_rep(i); d2 = diff_rep(i+1);
            t_cross = t1 - d1 * (t2 - t1) / (d2 - d1);
            crossover_temps(end+1) = t_cross; 
            break
        end
    end
end
 
%% Mostrar resultats
fprintf('\n--- Punt de creuament G'' = G'''' ---\n');
for k = 1:length(crossover_temps)
    fprintf('  Rèplica %d: %.2f °C\n', k, crossover_temps(k));
end
 
if length(crossover_temps) >= 2
    fprintf('  Mitjana:   %.2f °C\n', mean(crossover_temps));
    fprintf('  SD:        ± %.2f °C\n', std(crossover_temps));
else
    fprintf('  (Només una rèplica trobada, no es pot calcular SD)\n');
end
fprintf('\n');


