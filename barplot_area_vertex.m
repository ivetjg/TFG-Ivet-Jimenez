% BAR PLOT - Vertex area vs UV exposure time
clear; clc; close all;

%% LLEGIR CSV
T = readtable(fullfile('resultats.csv'));
T.Properties.VariableNames = {'fitxer', 'area_mm2', 'R_eq_mm'};

%% EXTREURE TEMPS, CONCENTRACIO I AREA
n = height(T);
temps_vec = zeros(n,1);
conc_vec  = zeros(n,1);
for i = 1:n
    nom = lower(T.fitxer{i});
    toks = regexp(nom, '(\d+)', 'tokens');
if ~isempty(toks)
        temps_vec(i) = str2double(toks{1}{1}) * (1 + 59*contains(nom,'min'));
end
if     contains(nom,'ctrl'), conc_vec(i) = 1;
elseif contains(nom,'high'), conc_vec(i) = 2;
elseif contains(nom,'low'),  conc_vec(i) = 3;
end
end
area_vec = T.area_mm2;

%% DESCARTAR TEMPS = 100s
mask_100  = temps_vec == 100;
temps_vec = temps_vec(~mask_100);
conc_vec  = conc_vec(~mask_100);
area_vec  = area_vec(~mask_100);
T         = T(~mask_100, :);   % Filtrar també la taula per al CSV de sortida

%% CALCULAR MITJANA I SD PER CADA GRUP
temps_unics  = sort(unique(temps_vec(temps_vec > 0)));
temps_labels = arrayfun(@num2str, temps_unics, 'UniformOutput', false);
conc_unics   = [1, 2, 3];
conc_labels  = {'Control', 'High', 'Low'};
n_t = length(temps_unics);
n_c = length(conc_unics);
mat_mitjana = NaN(n_t, n_c);
mat_sd      = NaN(n_t, n_c);

% Càlcul SD
for ti = 1:n_t
for ci = 1:n_c
        mask = (temps_vec == temps_unics(ti)) & (conc_vec == conc_unics(ci));
        vals = area_vec(mask);
if ~isempty(vals)
            mat_mitjana(ti,ci) = mean(vals);
            mat_sd(ti,ci)      = std(vals);
end
end
end

%% PARAMETRES DE LA GRAFICA
colors  = [0.45 0.45 0.45;   % gris mig  -> Control
           0.20 0.20 0.20;   % negre     -> High
           0.80 0.80 0.80];  % gris clar -> Low
bw      = 0.25;
offsets = [-bw, 0, bw];
y_baix = [0,   1.0];   % rang inferior (tall d'eix)
y_dalt = [2.5, 7.5];  % rang superior (tall d'eix)

%% FIGURA AMB TALL D'EIX Y (broken axis)
fig = figure('Color','white','Position',[100 80 700 580]);
ax_b = subplot('Position',[0.13 0.10 0.83 0.52]);   % panel inferior
ax_t = subplot('Position',[0.13 0.65 0.83 0.22]);   % panel superior
for panel = 1:2
if panel == 1, ax = ax_b; yl = y_baix;
else,          ax = ax_t; yl = y_dalt; end
    hold(ax, 'on');
    h = gobjects(n_c, 1);
for ci = 1:n_c
        ti_valids = find(~isnan(mat_mitjana(:,ci)));
        xpos = ti_valids + offsets(ci);
        mij  = mat_mitjana(ti_valids, ci);
        sd   = mat_sd(ti_valids, ci);    
        
% Barres
        h(ci) = bar(ax, xpos, mij, bw*0.9, ...
'FaceColor', colors(ci,:), ...
'EdgeColor', colors(ci,:)*0.3, ...
'LineWidth', 0.7, ...
'DisplayName', conc_labels{ci});

% Barres d'error (SD)
        errorbar(ax, xpos, mij, sd, ...
'LineStyle','none', ...
'Color', colors(ci,:)*0.3, ...
'LineWidth', 0.9, ...
'CapSize', 5, ...
'HandleVisibility','off');
end
    ylim(ax, yl);
    xlim(ax, [0.5, n_t+0.5]);
    set(ax, 'XTick', 1:n_t, 'XTickLabel', temps_labels, ...
'FontSize', 11, 'FontName', 'Helvetica', ...
'Box', 'off', 'TickDir', 'out', ...
'GridAlpha', 0.15, 'GridLineStyle', ':');
    grid(ax, 'on');
if panel == 1
        xlabel(ax, 'UV exposure time (s)', 'FontSize', 12, 'FontName', 'Helvetica');
        ylabel(ax, 'Vertex area (mm²)',    'FontSize', 12, 'FontName', 'Helvetica');
        legend(ax, h, 'Location','northwest', 'FontSize',10, 'Box','off');
else
        set(ax, 'XTickLabel', {});
end
    hold(ax, 'off');
end

%% GUARDAR
exportgraphics(fig, fullfile('barplot_area_vertex.png'), 'Resolution', 300);
