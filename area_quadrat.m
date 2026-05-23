% CÀLCUL ÀREA QUADRAT — Processament de múltiples rèpliques
% Per a cada fitxer de la llista, l'usuari clica els dos extrems del costat
% del quadrat i el resultat s'afegeix automàticament a un CSV acumulatiu.

clear; clc; close all;

%% ---- PARÀMETRES ----------------------------------------
fitxers = {
    '200_low_r1.jpg',
    '200_low_r2.jpg',
    '200_low_r3.jpg',
    '200_low_r4.jpg',
};
% Modifica la llista anterior amb els noms reals dels teus fitxers.
% Pots afegir o treure línies segons les rèpliques que tinguis.

scale_px_per_mm = 160;
csv_file        = 'resultats_area.csv';

%% ---- INICIALITZAR CSV si no existeix ----------------------
if ~isfile(csv_file)
    fid = fopen(csv_file, 'w');
    fprintf(fid, 'fitxer,area_mm2\r\n');
    fclose(fid);
end

%% ---- BUCLE PER CADA FITXER --------------------------------
for k = 1:length(fitxers)

    nom_fitxer = fitxers{k};

    fprintf('\n[%d/%d] Processant: %s\n', k, length(fitxers), nom_fitxer);

    %% 1. CARREGAR IMATGE
    img = imread(nom_fitxer);

    %% 2. FIGURA INTERACTIVA
    fig = figure('Name', sprintf('Mesura de costat - %s', nom_fitxer), ...
                 'NumberTitle', 'off', 'Color', 'k');
    imshow(img); hold on;
    title('Prepara''t per clicar punts...', 'FontSize', 13, 'Color', 'w');
    annotation('textbox', [0.01, 0.01, 0.55, 0.06], ...
               'String', 'Groc = punt inicial   Cian = punt final   Blanc = costat mesurat', ...
               'Color', 'w', 'BackgroundColor', [0 0 0 0.6], ...
               'FontSize', 9, 'EdgeColor', 'none', 'FitBoxToText', 'on');
    pause(0.5);

    %% 3. CLICAR ELS DOS PUNTS

    % PAS 1: punt inicial
    title({'PAS 1/2 — PUNT INICIAL', 'Clica l''INICI del costat a mesurar'}, ...
          'FontSize', 12, 'Color', 'w', 'FontWeight', 'bold');
    [x1, y1] = ginput(1);
    plot(x1, y1, 'o', 'Color', 'yellow', 'MarkerSize', 12, ...
         'LineWidth', 2.5, 'MarkerFaceColor', 'yellow');
    drawnow;

    % PAS 2: punt final
    title({'PAS 2/2 — PUNT FINAL', 'Clica el FINAL del costat a mesurar'}, ...
          'FontSize', 12, 'Color', 'w', 'FontWeight', 'bold');
    [x2, y2] = ginput(1);
    plot(x2, y2, 'o', 'Color', 'cyan', 'MarkerSize', 12, ...
         'LineWidth', 2.5, 'MarkerFaceColor', 'cyan');
    drawnow;

    %% 4. CALCULAR DISTÀNCIA I ÀREA
    dist_px  = sqrt((x2 - x1)^2 + (y2 - y1)^2);
    dist_mm  = dist_px / scale_px_per_mm;
    area_mm2 = dist_mm^2;

    %% 5. DIBUIXAR RESULTAT FINAL

    % Línia entre els dos punts
    plot([x1 x2], [y1 y2], 'w-', 'LineWidth', 2.5);

    % Barres perpendiculars als extrems (estil mesura)
    dx      = x2 - x1;
    dy      = y2 - y1;
    len_bar = 15;
    if dist_px > 0
        perp_x = -dy / dist_px * len_bar;
        perp_y =  dx / dist_px * len_bar;
        plot([x1 - perp_x, x1 + perp_x], [y1 - perp_y, y1 + perp_y], 'w-', 'LineWidth', 2);
        plot([x2 - perp_x, x2 + perp_x], [y2 - perp_y, y2 + perp_y], 'w-', 'LineWidth', 2);
    end

    % Text resultat al centre del segment
    x_mid = (x1 + x2) / 2;
    y_mid = (y1 + y2) / 2;
    txt   = sprintf('%.4f mm\n(%.1f px)', dist_mm, dist_px);
    text(x_mid + 15, y_mid - 15, txt, ...
         'Color', 'yellow', 'FontSize', 13, 'FontWeight', 'bold', ...
         'BackgroundColor', [0 0 0 0.65], 'Margin', 4);

    title(sprintf('%s  |  Costat = %.4f mm  (%.1f px)', nom_fitxer, dist_mm, dist_px), ...
          'Color', 'white', 'FontSize', 11);
    hold off;

    %% 6. GUARDAR AL CSV
    fid = fopen(csv_file, 'a');
    fprintf(fid, '%s,%.8f\r\n', nom_fitxer, area_mm2);
    fclose(fid);
    fprintf('Resultat afegit a: %s\n', csv_file);

    pause(0.5);
    close(fig);

end

fprintf('\nProcessament completat. Resultats guardats a: %s\n', csv_file);
