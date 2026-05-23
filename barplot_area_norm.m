% BAR PLOT - Normalized square area vs UV exposure time
% Llegeix directament el CSV de resultats normalitzats
clear; clc; close all;

%% LLEGIR CSV NORMALITZAT
T = readtable(fullfile('resultats.csv'));
T.Properties.VariableNames = {'fitxer', 'area_mm2', 'area_norm'};

% Descartar mostres de 100s
T = T(~contains(lower(T.fitxer), '^100'), :);

%% EXTREURE TEMPS, CONCENTRACIÓ I ÀREA NORMALITZADA
n = height(T);
temps_vec = zeros(n,1);
conc_vec  = zeros(n,1);

for i = 1:n
    nom = lower(T.fitxer{i});
    if contains(nom, 'min')
        toks = regexp(nom, '(\d+)min', 'tokens');
        if ~isempty(toks)
            temps_vec(i) = str2double(toks{1}{1}) * 60;
        end
    else
        toks = regexp(nom, '^(\d+)', 'tokens');
        if ~isempty(toks)
            temps_vec(i) = str2double(toks{1}{1});
        end
    end

    if     contains(nom,'ctrl'), conc_vec(i) = 1;
    elseif contains(nom,'high'), conc_vec(i) = 2;
    elseif contains(nom,'low'),  conc_vec(i) = 3;
    end
end

area_vec = T.area_norm;

%% CALCULAR MITJANA I SD PER CADA GRUP
temps_unics  = sort(unique(temps_vec(temps_vec > 0)));
temps_labels = arrayfun(@num2str, temps_unics, 'UniformOutput', false);
conc_unics  = [1, 2, 3];
conc_labels = {'Control', 'High', 'Low'};
n_t = length(temps_unics);
n_c = length(conc_unics);

mat_mitjana = NaN(n_t, n_c);
mat_sd      = NaN(n_t, n_c);

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

%% PARÀMETRES DE LA GRÀFICA
colors  = [0.45 0.45 0.45;   % gris mig  -> Control
           0.20 0.20 0.20;   % negre      -> High
           0.80 0.80 0.80];  % gris clar  -> Low
bw      = 0.25;
offsets = [-bw, 0, bw];

%% FIGURA
fig = figure('Color','white','Position',[100 80 700 480]);
ax  = axes('Position',[0.13 0.12 0.83 0.75]);
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

% Línia de referència a 1.0 (àrea normalitzada = àrea de referència)
yline(ax, 1.0, '--', 'Color', 'black', 'LineWidth', 1.2, ...
      'FontSize', 9, 'HandleVisibility', 'off');

ylim(ax, [0, max(mat_mitjana(:) + mat_sd(:), [], 'omitnan') * 1.2 + 0.1]);
xlim(ax, [0.5, n_t+0.5]);

set(ax, 'XTick', 1:n_t, 'XTickLabel', temps_labels, ...
    'FontSize', 11, 'FontName', 'Helvetica', ...
    'Box', 'off', 'TickDir', 'out', ...
    'GridAlpha', 0.15, 'GridLineStyle', ':');
grid(ax, 'on');

xlabel(ax, 'UV exposure time (s)', 'FontSize', 12, 'FontName', 'Helvetica');
ylabel(ax, 'Normalized square area (a.u.)', 'FontSize', 12, 'FontName', 'Helvetica');
legend(ax, h, 'Location','northwest', 'FontSize',10, 'Box','off');

hold(ax, 'off');

%% GUARDAR
exportgraphics(fig, 'barplot_area_norm.png', 'Resolution', 300);
fprintf('Figura guardada: barplot_area_norm.png\n');
