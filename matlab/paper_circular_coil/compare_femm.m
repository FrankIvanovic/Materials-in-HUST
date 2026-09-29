%% 毕奥--萨伐尔数值解 vs FEMM 有限元解 —— 对比图与偏差指标
% ========================================================================
% 前提：已运行 main_paper_figures.m 与 run_femm_axis.m（或用 femm/ 下的
%       circle_coil_axi.lua 手动生成同名 CSV 放入 data/）。
% 输出：paper/figures/fig08_femm_comparison.png 与控制台偏差指标。
% ========================================================================
clc; clear; close all;
thisDir  = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(thisDir));
datDir   = fullfile(thisDir, 'data');
figDir   = fullfile(repoRoot, 'paper', 'figures');

set(groot, 'defaultAxesFontName','Microsoft YaHei', ...
           'defaultTextFontName','Microsoft YaHei', ...
           'defaultAxesFontSize',10.5, ...
           'defaultFigureColor','w', ...
           'defaultLegendFontName','Microsoft YaHei');

dN = readmatrix(fullfile(datDir, 'axis_numeric_I1A.csv'));
dF = readmatrix(fullfile(datDir, 'femm_axis_I1A.csv'));

% ---- 轴线对比 ------------------------------------------------------------
zN = dN(:,1);  BN = dN(:,2);
zF = dF(:,1);  BF = dF(:,2);
BFi = interp1(zF, BF, zN, 'linear', 'extrap');

mask  = zN >= -60 & zN <= 10;                       % 有效对比区间
relD  = (BFi - BN)./BN;
rmsRel = sqrt(mean(relD(mask).^2));
maxRel = max(abs(relD(mask)));

figure('Position', [80 80 920 360], 'Theme','light');
subplot(1,2,1); hold on; grid on; box on;
plot(zN, BN*1e6, '-',  'LineWidth',1.8, 'Color',[0.15 0.35 0.8]);
plot(zF, BF*1e6, '--', 'LineWidth',1.3, 'Color',[0.85 0.33 0.10]);
xlim([-100 60]);
xlabel('z / mm'); ylabel('B_z / \muT');
title('(a) 轴线磁场：数值解 vs FEMM');
legend({'毕奥-萨伐尔数值解','FEMM 有限元'}, 'Location','northwest');
subplot(1,2,2); hold on; grid on; box on;
plot(zN, relD*100, 'LineWidth',1.4, 'Color',[0.49 0.18 0.56]);
xlim([-100 60]);
xlabel('z / mm'); ylabel('相对偏差 (%)');
title('(b) FEMM 相对数值解的偏差');
exportgraphics(gcf, fullfile(figDir,'fig08_femm_comparison.png'), 'Resolution', 300);

fprintf('[M] 轴线对比（z in [-60,10] mm）：峰值 数值 %.2f uT / FEMM %.2f uT\n', ...
        max(BN)*1e6, max(BF)*1e6);
fprintf('[M] 轴线相对偏差：RMS = %.3f%%，最大 = %.3f%%\n', 100*rmsRel, 100*maxRel);
for zq = [-10 -20 -30 -40 -50]
    [~, i] = min(abs(zN - zq));
    fprintf('    z = %4d mm : 数值 %.2f uT，FEMM %.2f uT，偏差 %+.3f%%\n', ...
            zq, BN(i)*1e6, BFi(i)*1e6, 100*(BFi(i)-BN(i))/BN(i));
end

% ---- z = -10 mm 径向 Bz 对比 ---------------------------------------------
fN = fullfile(datDir, 'radial_z-10_numeric_I1A.csv');
fF = fullfile(datDir, 'femm_radial_z-10_I1A.csv');
if exist(fN,'file') && exist(fF,'file')
    rN = readmatrix(fN);  rF = readmatrix(fF);
    BzNi = rN(:,3);  BzFi = interp1(rF(:,1), rF(:,3), rN(:,1), 'linear', 'extrap');
    relR = (BzFi - BzNi)./BzNi;
    pk   = max(abs(BzNi));
    m2   = abs(BzNi) > 0.05*pk;              % 过零点附近相对值无意义，只在
                                             % |Bz|>5% 峰值区域统计逐点偏差
    fprintf('[M] 径向 Bz（z=-10mm）：峰值 数值 %.2f uT / FEMM %.2f uT（%+.2f%%）\n', ...
            pk*1e6, max(BzFi)*1e6, 100*(max(BzFi)-pk)/pk);
    fprintf('[M] 径向逐点偏差（|Bz|>5%%峰值，rho<=%.0fmm）：RMS %.3f%%，最大 %.3f%%\n', ...
            max(rN(m2,1)), 100*sqrt(mean(relR(m2).^2)), 100*max(abs(relR(m2))));
    fprintf('[M] 径向峰值归一偏差（全量程 rho<=%.0fmm）：最大 %.3f%%\n', ...
            max(rN(:,1)), 100*max(abs(BzFi-BzNi))/pk);
end
fprintf('完成：compare_femm\n');
