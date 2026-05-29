% ESTADÍSTICA - ANOVA + Tukey per àrea normalitzada
clear; clc;

%% LLEGIR CSV
T = readtable('resultats.csv');
T.Properties.VariableNames = {'fitxer', 'area_mm2', 'area_norm'};

% Descartar 100s
T = T(~contains(lower(T.fitxer), '^100'), :);

%% EXTREURE TEMPS, CONCENTRACIÓ I ÀREA
n = height(T);
temps_vec = zeros(n,1);
conc_vec  = cell(n,1);

for i = 1:n
    nom = lower(T.fitxer{i});
    % Temps
    if contains(nom, 'min')
        toks = regexp(nom, '(\d+)min', 'tokens');
        if ~isempty(toks), temps_vec(i) = str2double(toks{1}{1}) * 60; end
    else
        toks = regexp(nom, '^(\d+)', 'tokens');
        if ~isempty(toks), temps_vec(i) = str2double(toks{1}{1}); end
    end
    % Condició
    if     contains(nom,'ctrl'), conc_vec{i} = 'Control';
    elseif contains(nom,'high'), conc_vec{i} = 'High';
    elseif contains(nom,'low'),  conc_vec{i} = 'Low';
    end
end

area_vec = T.area_norm;

%% ANOVA + TUKEY PER CADA TEMPS
temps_unics = sort(unique(temps_vec(temps_vec > 0)));

fprintf('=== ANOVA + TUKEY: Àrea normalitzada ===\n\n');

for ti = 1:length(temps_unics)
    t = temps_unics(ti);
    mask = temps_vec == t;
    
    dades  = area_vec(mask);
    grups  = conc_vec(mask);
    
    fprintf('--- Temps: %d s ---\n', t);
    [p, ~, stats] = anova1(dades, grups, 'off');
    fprintf('ANOVA p-value: %.4f\n', p);
    
    if p < 0.05
        fprintf('Diferències significatives (p < 0.05). Post-hoc Tukey:\n');
        [c, ~, ~, gnames] = multcompare(stats, 'Display', 'off');
        for k = 1:size(c,1)
            fprintf('  %s vs %s: p = %.4f', gnames{c(k,1)}, gnames{c(k,2)}, c(k,6));
            if c(k,6) < 0.05
                fprintf(' *');
            end
            fprintf('\n');
        end
    else
        fprintf('No hi ha diferències significatives.\n');
    end
    fprintf('\n');
end