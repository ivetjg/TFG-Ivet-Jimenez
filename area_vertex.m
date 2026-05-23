%% ANALISI DEL VERTEX 

clear; clc; close all;

%% CALIBRATGE: mesura la barra d'escala
img = imread('200_high_cant2.jpg'); 
imshow(img);
title('Clica l''INICI i el FINAL de la barra d''escala 1mm', 'Color','w');

[x_bar, ~] = ginput(2);   % clica 2 punts: extrem esquerre i dret de la barra
scale_px_per_mm = abs(x_bar(2) - x_bar(1));
fprintf('Escala: %.1f px/mm\n', scale_px_per_mm);

%% ---- PARÀMETRES ----------------------------------------
nom_fitxer      = '250_ctrl_cant2.jpg'; % canviar per cada imatge
scale_px_per_mm = 160;
N_ARC           = 8;   % punts a clicar sobre l'arc (7-10 recomanat)

%% 1. CARREGAR IMATGE
img = imread(nom_fitxer);
[nrows, ncols, ~] = size(img);

%% 2. FIGURA INTERACTIVA
fig = figure('Name', sprintf('Selecció de punts - %s', nom_fitxer), ...
             'NumberTitle', 'off', 'Color', 'k');
imshow(img); hold on;
title('Prepara''t per clicar punts...', 'FontSize', 13, 'Color', 'w');
annotation('textbox', [0.01, 0.01, 0.60, 0.06], ...
           'String', 'Cian = costat horitzontal   Magenta = costat vertical   Groc = arc cantonada', ...
           'Color', 'w', 'BackgroundColor', [0 0 0 0.6], ...
           'FontSize', 9, 'EdgeColor', 'none', 'FitBoxToText', 'on');
pause(0.5);

%% 3. CLICAR PUNTS

% PAS 1: costat horitzontal
[xh, yh] = clicar_punts(fig, 5, 'cyan', 'o', ...
    'PAS 1/3 — COSTAT HORITZONTAL', ...
    'Clica 5 punts sobre la vora recta SUPERIOR (lluny de la cantonada)');
ph    = polyfit(xh, yh, 1);
x_lin = linspace(1, ncols, 300);
plot(x_lin, polyval(ph, x_lin), 'c--', 'LineWidth', 1.5);
drawnow;

% PAS 2: costat vertical
[xv, yv] = clicar_punts(fig, 5, 'magenta', 'o', ...
    'PAS 2/3 — COSTAT VERTICAL', ...
    'Clica 5 punts sobre la vora recta ESQUERRA (lluny de la cantonada)');
pv    = polyfit(yv, xv, 1);
y_lin = linspace(1, nrows, 300);
plot(polyval(pv, y_lin), y_lin, 'm--', 'LineWidth', 1.5);
drawnow;

% PAS 3: arc de la cantonada (més punts, repartits)
msg2_arc = sprintf('Clica %d punts sobre l''ARC (esquerra→dreta, repartits uniformement)', N_ARC);
[xa, ya] = clicar_punts(fig, N_ARC, 'yellow', 'o', ...
    'PAS 3/3 — ARC DE LA CANTONADA', msg2_arc);

% Dibuixar spline de l'arc clicat (visual)
if N_ARC >= 4
    t_sp  = 1:N_ARC;
    t_fin = linspace(1, N_ARC, 200);
    xa_sp = spline(t_sp, xa, t_fin);
    ya_sp = spline(t_sp, ya, t_fin);
    plot(xa_sp, ya_sp, 'y-', 'LineWidth', 1.5);
    drawnow;
end

%% 4. INTERSECCIÓ DE LES DUES TANGENTS (vèrtex ideal)
a_h = ph(1); b_h = ph(2);   % y = a_h*x + b_h
a_v = pv(1); b_v = pv(2);   % x = a_v*y + b_v

x_int = (a_v*b_h + b_v) / (1 - a_v*a_h);
y_int = a_h*x_int + b_h;


%% 5. TROBAR ELS PUNTS DE TALL TANGENT↔ARC
% Usem la spline interpolada de l'arc per trobar on creua cada tangent

% Generar arc interpolat dens
if N_ARC >= 4
    t_sp   = 1:N_ARC;
    t_fin  = linspace(1, N_ARC, 2000);
    xa_den = spline(t_sp, xa, t_fin);
    ya_den = spline(t_sp, ya, t_fin);
else
    xa_den = xa;
    ya_den = ya;
end

% Distància de cada punt de l'arc a la recta horitzontal
% Recta H: a_h*x - y + b_h = 0
dist_h = a_h * xa_den - ya_den + b_h;   % positiu = per sota, negatiu = per sobre
% Punt de tall: on dist_h canvia de signe (o és mínim en valor absolut)
[~, idx_th] = min(abs(dist_h));
x_tall_h = xa_den(idx_th);
y_tall_h = ya_den(idx_th);

% Distància de cada punt de l'arc a la recta vertical
% Recta V: -x + a_v*y + b_v = 0
dist_v = -xa_den + a_v * ya_den + b_v;
[~, idx_tv] = min(abs(dist_v));
x_tall_v = xa_den(idx_tv);
y_tall_v = ya_den(idx_tv);

% Extreure el tros d'arc entre els dos punts de tall
if idx_th <= idx_tv
    arc_x = xa_den(idx_th:idx_tv);
    arc_y = ya_den(idx_th:idx_tv);
else
    arc_x = xa_den(idx_tv:idx_th);
    arc_y = ya_den(idx_tv:idx_th);
    % Invertir per mantenir ordre H→V
    arc_x = fliplr(arc_x);
    arc_y = fliplr(arc_y);
end

%% 6. CALCULAR ÀREA AMB SHOELACE (sense cap suposició de forma)
% Polígon: vèrtex ideal → tall H → arc real → tall V → tanca
poly_x = [x_int; x_tall_h; arc_x(:); x_tall_v; x_int];
poly_y = [y_int; y_tall_h; arc_y(:); y_tall_v; y_int];

n_poly   = length(poly_x);
area_px2 = abs(sum(poly_x(1:end-1).*poly_y(2:end) - ...
                   poly_x(2:end).*poly_y(1:end-1))) / 2;
area_mm2 = area_px2 / scale_px_per_mm^2;

% Radi equivalent (per comparació entre mostres)
R_eq    = sqrt(area_px2 / (1 - pi/4));
R_eq_mm = R_eq / scale_px_per_mm;

%% 7. DIBUIXAR RESULTAT FINAL
marge = 300;
x_rng = linspace(x_int - marge, x_int + marge*0.3, 200);
y_rng = linspace(y_int - marge, y_int + marge*0.3, 200);

% Tangents forçades a 90º
plot(x_rng, a_h*x_rng + b_h, 'w-', 'LineWidth', 2.5);
plot(a_v*y_rng + b_v, y_rng,  'w-', 'LineWidth', 2.5);

% Àrea vermella (polígon real)
fill(poly_x, poly_y, 'r', 'FaceAlpha', 0.55, ...
     'EdgeColor', [1 0.4 0.4], 'LineWidth', 1.5);

% Punts de tall (on les tangents troben l'arc)
plot(x_tall_h, y_tall_h, 'ws', 'MarkerSize', 10, 'LineWidth', 2);
plot(x_tall_v, y_tall_v, 'ws', 'MarkerSize', 10, 'LineWidth', 2);

% Vèrtex ideal
plot(x_int, y_int, 'w+', 'MarkerSize', 20, 'LineWidth', 2.5);

% Text resultat
txt = sprintf('A = %.5f mm²\nR = %.4f mm', area_mm2, R_eq_mm);
text(x_int - 280, y_int + 70, txt, 'Color', 'yellow', 'FontSize', 12, ...
     'FontWeight', 'bold', 'BackgroundColor', [0 0 0 0.6]);

title(sprintf('%s  |  A = %.6f mm²  |  R= %.4f mm', ...
      nom_fitxer, area_mm2, R_eq_mm), ...
      'Color', 'white', 'FontSize', 11);

hold off;

%% 8. GUARDAR FIGURA
carpeta = 'resultats';
if ~exist(carpeta, 'dir')
    mkdir(carpeta);
end
nom_sortida = fullfile(carpeta, [nom_fitxer(1:end-4), '_resultat.png']);
exportgraphics(fig, nom_sortida, 'Resolution', 150);
fprintf('Figura guardada: %s\n', nom_sortida);

%% 9. GUARDAR CSV ACUMULATIU
csv_file = fullfile(carpeta, 'resultats_vertex.csv');

fid = fopen(csv_file, 'a');
fprintf(fid, '%s,%.8f,%.6f\r\n', nom_fitxer, area_mm2, R_eq_mm);
fclose(fid);
fprintf('Resultat afegit a: %s\n', csv_file);

%% =========================================================
%  FUNCIONS LOCALS

function [xp, yp] = clicar_punts(fig, n, color, marcador, msg1, msg2)
    figure(fig);
    xp = zeros(n,1);
    yp = zeros(n,1);
    for i = 1:n
        title({msg1, sprintf('%s   [%d / %d]', msg2, i, n)}, ...
              'FontSize', 12, 'Color', 'w', 'FontWeight', 'bold');
        [xi, yi] = ginput(1);
        xp(i) = xi;
        yp(i) = yi;
        plot(xi, yi, marcador, 'Color', color, 'MarkerSize', 10, ...
             'LineWidth', 2, 'MarkerFaceColor', color);
        drawnow;
    end
end
