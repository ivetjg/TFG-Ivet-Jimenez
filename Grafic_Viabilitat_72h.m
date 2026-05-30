cd('C:\Users\ivetj\OneDrive\Documents\uni\TFG\assaig MTT\codi')
clear all;
clc

R1 = readmatrix('Resum_ALL_replicates.xlsx','Sheet',1);
R2 = readmatrix('Resum_ALL_replicates.xlsx','Sheet',2);

%% Càlcul de mitjanes i controls
media_R1 = mean(R1(1:3,:),1,'omitnan');
media_R2 = mean(R2(1:3,:),1,'omitnan');
control_R1 = R1(4,:);
control_R2 = R2(4,:);

%% DADES EN BRUT
% dades = [media_R1; media_R2; media_R3];
% dades = dades';
%
% figure
% bar(dades)
%
% legend({'R1','R2','R3'})
% xlabel('Column / Condition')
% ylabel('Mean value')
% title('Comparison between R1 and R2')

%% Absorbància corregida i normalitzada
media_R12   = mean([media_R1; media_R2],1,'omitnan');
control_R12 = mean([control_R1; control_R2],1,'omitnan');

Absorbancia_mitja   = media_R12 - control_R12;
Absorbancia_percent = (Absorbancia_mitja / Absorbancia_mitja(1)) * 100;

SD_R12      = std([media_R1; media_R2],0,1,'omitnan');
SD_percent  = (SD_R12 / Absorbancia_mitja(1)) * 100;

%% Figura (estil GraphPad)
figure
set(gcf, 'Color', 'w')
hold on

bar(Absorbancia_percent, 0.65, ...
    'FaceColor', [0.80 0.80 0.80], ...
    'EdgeColor', 'k', ...
    'LineWidth', 1)

errorbar(1:length(Absorbancia_percent), ...
         Absorbancia_percent, ...
         SD_percent, ...
         'k', 'LineStyle', 'none', 'LineWidth', 1, 'CapSize', 12)

ylabel('Cell viability (%)', 'FontSize', 13)

xticks(1:5)
xticklabels({'2D','Scaffold PCL','2D + LAP','GelMA - LAP','GelMA + LAP'})
xtickangle(25)

yline(100, '--k', 'LineWidth', 1)

set(gca, ...
    'FontSize',  12, ...
    'LineWidth', 1, ...
    'TickDir',   'out', ...
    'Box',       'off')

ylim([0 max(Absorbancia_percent + SD_percent) * 1.25])
title('Cell viability (72h MTT assay)', 'FontWeight', 'bold')

hold off