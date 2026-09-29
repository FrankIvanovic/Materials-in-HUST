%% 课题一：圆形线圈 —— 论文全部图件与指标生成
% ========================================================================
% 运行：直接运行本文件（需 ../common 通用库，本机 MATLAB R2026a 已验证）。
% 输出：paper/figures/*.png（300 dpi，供 LaTeX 引用）
%       matlab/paper_circular_coil/data/*.csv（供 FEMM 对比脚本使用）
%       控制台打印论文正文引用的全部数值指标（[M] 标记行）。
%
% 线圈（图纸）：平面螺旋、双层 9 圈；外径 Φ115（图纸注明略小，按标称值）、
% 内径 Φ30±1、绕组为 Φ4 紫铜管（层间距 = 管外径 4 mm，总厚约 8 mm < 10 mm）。
% 激励：归一化 I = 1 A，全部结果随 I 线性缩放。
% 引线（可选）：两条平行反流直导线，间距 18 mm、长 100 mm（R20 弯头未计入）。
% ========================================================================
clc; clear; close all;
thisDir  = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(thisDir));          % 仓库根目录
addpath(fullfile(repoRoot, 'matlab', 'common'));
figDir = fullfile(repoRoot, 'paper', 'figures');
datDir = fullfile(thisDir, 'data');
if ~exist(figDir, 'dir'), mkdir(figDir); end
if ~exist(datDir, 'dir'), mkdir(datDir); end

% ---- 全局绘图风格（中文标签）-------------------------------------------
set(groot, 'defaultAxesFontName','Microsoft YaHei', ...
           'defaultTextFontName','Microsoft YaHei', ...
           'defaultAxesFontSize', 10.5, ...
           'defaultFigureColor','w', ...
           'defaultLegendFontName','Microsoft YaHei', ...
           'defaultColorbarFontName','Microsoft YaHei');

mu0 = 4*pi*1e-7;  mm = 1e-3;  I = 1;

% ---- 线圈几何 -----------------------------------------------------------
rIn = 15*mm;  rOut = 57.5*mm;  nTurns = 9;  nPer = 240;  dz = 4*mm;
[coil, sg] = multilayer_spiral([0 0], rIn, rOut, nTurns, nPer, 0, dz, 2);
cur  = I*sg(:);
aK   = rIn + (rOut - rIn)*((1:nTurns)' - 0.5)/nTurns;   % 各匝平均半径
pitch = (rOut - rIn)/nTurns;

% 引线（两条平行反流直导线，位于线圈平面 z = 0）
leadA = [57.5*mm 0 0; 57.5*mm -100*mm 0];
leadB = [39.5*mm 0 0; 39.5*mm -100*mm 0];
pathsL = [coil, {leadA, leadB}];
curL   = [cur; I; -I];

% =========================================================================
% 图 1  线圈模型（俯视 + 三维）
% =========================================================================
figure('Position', [80 80 920 380], 'Theme','light');
subplot(1,2,1); hold on;
plot(coil{1}(:,1)*1e3, coil{1}(:,2)*1e3, '-',  'Color',[0.15 0.35 0.8], 'LineWidth',1.0);
plot(coil{2}(:,1)*1e3, coil{2}(:,2)*1e3, '--', 'Color',[0.85 0.33 0.10],'LineWidth',1.0);
thd = linspace(0, 2*pi, 200);
plot(rIn*cos(thd)*1e3,  rIn*sin(thd)*1e3,  'k:', 'LineWidth',0.8);
plot(rOut*cos(thd)*1e3, rOut*sin(thd)*1e3, 'k:', 'LineWidth',0.8);
text(0, -(rIn*1e3+4),  '\Phi30',  'HorizontalAlignment','center','FontSize',9);
text(0, -(rOut*1e3+4), '\Phi115', 'HorizontalAlignment','center','FontSize',9);
axis equal; xlim([-70 70]); ylim([-73 58]); grid on; box on;
xlabel('x / mm'); ylabel('y / mm'); title('(a) 俯视图（双层平面螺旋）');
legend({'第 1 层（z = 0）','第 2 层（z = 4 mm）'}, 'Location','northeast');

subplot(1,2,2); hold on;
plot3(coil{1}(:,1)*1e3, coil{1}(:,2)*1e3, coil{1}(:,3)*1e3, '-', 'Color',[0.15 0.35 0.8], 'LineWidth',1.0);
plot3(coil{2}(:,1)*1e3, coil{2}(:,2)*1e3, coil{2}(:,3)*1e3, '-', 'Color',[0.85 0.33 0.10],'LineWidth',1.0);
plot3(leadA(:,1)*1e3, leadA(:,2)*1e3, leadA(:,3)*1e3, ':', 'Color',[0.5 0.5 0.5], 'LineWidth',1.2);
plot3(leadB(:,1)*1e3, leadB(:,2)*1e3, leadB(:,3)*1e3, ':', 'Color',[0.5 0.5 0.5], 'LineWidth',1.2);
axis equal; grid on; box on; view(132, 22);
xlabel('x / mm'); ylabel('y / mm'); zlabel('z / mm');
title('(b) 三维走线（虚线为引线对）');
exportgraphics(gcf, fullfile(figDir,'fig01_model.png'), 'Resolution', 300);

% =========================================================================
% 图 2  轴线磁场 + 多匝圆环解析解验证
% =========================================================================
zv = (-100:0.5:60)*mm;
[za, Ba] = field_on_axis(coil, cur, zv, 0, 0);          % 数值（折线离散）
Bana = zeros(size(za));
for kk = 1:nTurns
    for zc = [0, dz]
        Bana = Bana + mu0*I*aK(kk)^2 ./ (2*(aK(kk)^2 + (za - zc).^2).^1.5);
    end
end
relAx = abs(Ba(:,3) - Bana)/abs(Bana);

figure('Position', [80 80 920 360], 'Theme','light');
subplot(1,2,1); hold on; grid on; box on;
plot(za*1e3, Ba(:,3)*1e6,  '-',  'LineWidth',1.6, 'Color',[0.15 0.35 0.8]);
plot(za*1e3, Bana*1e6, '--', 'LineWidth',1.3, 'Color',[0.85 0.33 0.10]);
xlabel('z / mm'); ylabel('B_z / \muT');
title('(a) 轴线磁场：数值 vs 解析');
legend({'毕奥-萨伐尔数值解','多匝圆环解析解'}, 'Location','northeast');
subplot(1,2,2); hold on; grid on; box on;
semilogy(za*1e3, relAx, 'LineWidth',1.3, 'Color',[0.15 0.35 0.8]);
xlabel('z / mm'); ylabel('相对偏差 |B_{num} - B_{ana}|/B_{ana}');
title('(b) 两种算法的相对偏差');
exportgraphics(gcf, fullfile(figDir,'fig02_axis_validation.png'), 'Resolution', 300);
fprintf('[M] 轴线峰值 Bz(0,0) = %.2f uT (I=1A)\n', max(Ba(:,3))*1e6);
fprintf('[M] 轴线 数值vs解析 最大相对偏差 = %.3e\n', max(relAx));

% =========================================================================
% 图 3  单匝圆环离轴场：椭圆积分精确解验证 + 离散收敛性
% =========================================================================
aTest = aK(5);                                          % 取中间匝平均半径
rho = (0:0.1:56)*mm;  zEval = -10*mm;
Pc = circle_pts([0 0], aTest, nPer, 0);                 % 单匝圆环（240 段）
Pe = [rho(:), zeros(numel(rho),1), zEval*ones(numel(rho),1)];
Bn = bs_field(Pe, {Pc}, I);                             % 数值核
[Br_e, Bz_e] = loop_field_elliptic(aTest, I, rho(:), zEval*ones(numel(rho),1));

figure('Position', [80 80 920 360], 'Theme','light');
subplot(1,2,1); hold on; grid on; box on;
plot(rho*1e3, Bn(:,3)*1e6, '-', 'LineWidth',1.6, 'Color',[0.15 0.35 0.8]);
plot(rho*1e3, Bz_e*1e6, '--', 'LineWidth',1.3, 'Color',[0.85 0.33 0.10]);
plot(rho*1e3, Bn(:,1)*1e6, '-', 'LineWidth',1.3, 'Color',[0.47 0.67 0.19]);
plot(rho*1e3, Br_e*1e6, '--', 'LineWidth',1.0, 'Color',[0.49 0.18 0.56]);
xlabel('\rho / mm'); ylabel('B / \muT');
title(sprintf('(a) 单匝 a=%.1f mm，z = -10 mm 平面', aTest*1e3));
legend({'B_z 数值','B_z 椭圆积分','B_{\rho} 数值','B_{\rho} 椭圆积分'}, 'Location','northeast');
subplot(1,2,2); hold on; grid on; box on;
BzS = max(abs(Bz_e));  BrS = max(abs(Br_e));
errBz = abs(Bn(:,3) - Bz_e)/BzS;             % 峰值归一偏差（Bz 有过零点，
errBr = abs(Bn(:,1) - Br_e)/BrS;             % Brho 在 rho=0 为零，逐点相对值会发散）
semilogy(rho*1e3, errBz, 'LineWidth',1.3, 'Color',[0.85 0.33 0.10]);
semilogy(rho*1e3, errBr, 'LineWidth',1.3, 'Color',[0.47 0.67 0.19]);
xlabel('\rho / mm'); ylabel('偏差（以各分量峰值归一）');
title('(b) 数值核 vs 椭圆积分');
legend({'B_z','B_{\rho}'}, 'Location','south');
exportgraphics(gcf, fullfile(figDir,'fig03_elliptic_validation.png'), 'Resolution', 300);
mz = abs(Bz_e) > 0.05*BzS;   mr = abs(Br_e) > 0.05*BrS;
fprintf('[M] 单匝离轴场 vs 椭圆积分：峰值归一最大偏差 Bz %.2e / Brho %.2e；逐点相对偏差(|B|>5%%峰值) Bz %.2e / Brho %.2e\n', ...
        max(errBz), max(errBr), ...
        max(abs(Bn(mz,3)-Bz_e(mz))./abs(Bz_e(mz))), max(abs(Bn(mr,1)-Br_e(mr))./abs(Br_e(mr))));

% 离散收敛性：每匝段数 nPer 增大时与解析解的偏差
fprintf('[M] 离散收敛性（整线圈轴线，vs 多匝解析）:\n');
for np = [60 120 240 480 960]
    [c2, s2] = multilayer_spiral([0 0], rIn, rOut, nTurns, np, 0, dz, 2);
    [z2, B2] = field_on_axis(c2, I*s2(:), zv, 0, 0);
    e2 = max(abs(B2(:,3) - Bana))/max(abs(Bana));
    fprintf('    nPer = %4d : 最大相对偏差 %.3e\n', np, e2);
end

% =========================================================================
% 图 4  线圈下方 z = -10 mm 平面 Bz 分布
% =========================================================================
xv = (-80:1:80)*mm;
[X, Y, Bz, Bm] = field_on_plane(coil, cur, xv, xv, -10*mm);
figure('Position', [80 80 640 560], 'Theme','light');
contourf(X*1e3, Y*1e3, Bz*1e6, 40, 'LineColor','none'); hold on;
plot(rOut*cos(thd)*1e3, rOut*sin(thd)*1e3, 'w--', 'LineWidth',0.9);
plot(rIn*cos(thd)*1e3,  rIn*sin(thd)*1e3,  'w:',  'LineWidth',0.9);
colorbar; colormap(parula); axis equal tight; grid on;
xlabel('x / mm'); ylabel('y / mm'); title('线圈下方 z = -10 mm 平面的 B_z 分布 (\muT, I = 1 A)');
exportgraphics(gcf, fullfile(figDir,'fig04_plane_Bz.png'), 'Resolution', 300);
fprintf('[M] 平面 z=-10mm：Bz 峰值 %.2f uT，位于 (%.1f, %.1f) mm\n', ...
        max(Bz(:))*1e6, X(Bz==max(Bz(:))), Y(Bz==max(Bz(:))));

% =========================================================================
% 图 5  r–z 半平面截面 |B| 云图 + 磁力线
% =========================================================================
rv  = (0:0.5:80)*mm;   zv2 = (-60:0.5:15)*mm;
[RV, ZV] = meshgrid(rv, zv2);
Pe5 = [RV(:), zeros(numel(RV),1), ZV(:)];
B5  = bs_field(Pe5, coil, cur);
Br5 = reshape(B5(:,1), size(RV));
Bz5 = reshape(B5(:,3), size(RV));
Bm5 = sqrt(Br5.^2 + Bz5.^2);

figure('Position', [80 80 760 520], 'Theme','light');
% 遮罩绕组截面（灯丝模型在导线附近无定义，区域内不画云图）
inside = false(size(RV));
for kk = 1:nTurns
    for zc = [0, dz]
        inside = inside | (RV >= aK(kk)-2*mm & RV <= aK(kk)+2*mm & ...
                           ZV >= zc-2*mm & ZV <= zc+2*mm);
    end
end
Bm5p = Bm5;  Bm5p(inside) = NaN;
contourf(RV*1e3, ZV*1e3, log10(Bm5p*1e6), 0.8:0.15:4.4, 'LineColor','none'); hold on;
% 绕组截面示意（每匝 4 mm x 4 mm）
for kk = 1:nTurns
    for zc = [0, dz]
        rectangle('Position', [aK(kk)*1e3 - 2, zc*1e3 - 2, 4, 4], ...
                  'EdgeColor','k', 'LineWidth',0.6);
    end
end
rvS = (0:2:80)*mm;  zvS = (-60:2:15)*mm;
[RS, ZS] = meshgrid(rvS, zvS);
PeS = [RS(:), zeros(numel(RS),1), ZS(:)];
BS  = bs_field(PeS, coil, cur);
Brs = reshape(BS(:,1), size(RS));  Bzs = reshape(BS(:,3), size(RS));
inS = interp2(RV, ZV, double(inside), RS, ZS, 'nearest') > 0.5;
Brs(inS) = NaN;  Bzs(inS) = NaN;
hs = streamslice(RS*1e3, ZS*1e3, Brs, Bzs);
set(hs, 'Color', 'w', 'LineWidth', 0.7);
colorbar; colormap(parula); axis equal tight; box on;
xlabel('\rho / mm'); ylabel('z / mm');
title('r–z 半平面 log_{10}(|B|/\muT) 云图与磁力线（I = 1 A）');
exportgraphics(gcf, fullfile(figDir,'fig05_rz_section.png'), 'Resolution', 300);

% =========================================================================
% 图 6  引线影响：含引线 vs 不含引线
% =========================================================================
[zaL, BaL] = field_on_axis(pathsL, curL, zv, 0, 0);
[~, ~, BzLp, BmLp] = field_on_plane(pathsL, curL, xv, xv, -10*mm);
dAx   = BaL(:,3) - Ba(:,3);
relL  = abs(dAx)./abs(Ba(:,3));

figure('Position', [80 80 920 360], 'Theme','light');
subplot(1,2,1); hold on; grid on; box on;
plot(za*1e3, Ba(:,3)*1e6,  '-', 'LineWidth',1.6, 'Color',[0.15 0.35 0.8]);
plot(za*1e3, BaL(:,3)*1e6, '--','LineWidth',1.3, 'Color',[0.85 0.33 0.10]);
xlabel('z / mm'); ylabel('B_z / \muT');
title('(a) 轴线磁场：含/不含引线');
legend({'不含引线','含引线对'}, 'Location','northeast');
subplot(1,2,2); hold on; grid on; box on;
plot(za*1e3, dAx*1e9, 'LineWidth',1.4, 'Color',[0.49 0.18 0.56]);
xlabel('z / mm'); ylabel('\Delta B_z / nT');
title('(b) 引线贡献（放大）');
exportgraphics(gcf, fullfile(figDir,'fig06_leads_comparison.png'), 'Resolution', 300);
fprintf('[M] 引线影响：轴线 Bz 最大绝对变化 %.2f nT（相对 %.3f%%）\n', max(abs(dAx))*1e9, 100*max(relL));
fprintf('[M] 引线影响：z=-10mm 平面 |B| 峰值 不含引线 %.2f uT，含引线 %.2f uT（变化 %.3f%%）\n', ...
        max(Bm(:))*1e6, max(BmLp(:))*1e6, 100*(max(BmLp(:))-max(Bm(:)))/max(Bm(:)));

% =========================================================================
% 聚焦性指标：径向半高全宽（FWHM）随深度变化
% =========================================================================
depths = [0 -5 -10 -15 -20 -25 -30]*mm;
rhoS = (0:0.1:120)*mm;
fwhm = zeros(size(depths));  peakD = zeros(size(depths));
for di = 1:numel(depths)
    PeD = [rhoS(:), zeros(numel(rhoS),1), depths(di)*ones(numel(rhoS),1)];
    BD  = bs_field(PeD, coil, cur);
    bzd = BD(:,3);
    nanm = isnan(bzd);                          % 场点恰落在导线上（螺旋起点
    if any(nanm)                                % rho=15mm,0,0），用邻点插值补
        bzd(nanm) = interp1(rhoS(~nanm), bzd(~nanm), rhoS(nanm));
    end
    peakD(di) = bzd(1);
    idx = find(bzd < bzd(1)/2, 1, 'first');
    if isempty(idx), fwhm(di) = NaN;
    else
        r1 = rhoS(idx-1); r2 = rhoS(idx);
        f = (bzd(idx-1) - bzd(1)/2)/(bzd(idx-1) - bzd(idx));
        fwhm(di) = 2*(r1 + f*(r2 - r1));
    end
end

figure('Position', [80 80 920 360], 'Theme','light');
subplot(1,2,1); hold on; grid on; box on;
sel = depths == 0 | depths == -10*mm | depths == -20*mm | depths == -30*mm;
cols = lines(nnz(sel)); ci = 0;
for di = find(sel(:).')
    ci = ci + 1;
    PeD = [rhoS(:), zeros(numel(rhoS),1), depths(di)*ones(numel(rhoS),1)];
    BD = bs_field(PeD, coil, cur);
    bpl = BD(:,3);
    nm = isnan(bpl);
    if any(nm), bpl(nm) = interp1(rhoS(~nm), bpl(~nm), rhoS(nm)); end
    nrm = bpl/max(bpl(1),eps)*100;
    % z=0 剖面经过绕组内部，仅显示孔内平滑段；其余深度显示到 60mm
    if depths(di) == 0, rLim = 15*mm; else, rLim = 60*mm; end
    nrm(rhoS(:) > rLim | abs(nrm) > 120) = NaN;
    plot(rhoS*1e3, nrm, 'LineWidth',1.4, 'Color',cols(ci,:));
end
xlabel('\rho / mm'); ylabel('B_z(\rho) / B_z(0)  (%)');
xlim([0 60]); ylim([0 125]);
title('(a) 不同深度的径向分布（归一化）');
legend({'z = 0（孔内）','z = -10 mm','z = -20 mm','z = -30 mm'}, 'Location','northeast');
subplot(1,2,2); yyaxis left; hold on; grid on; box on;
plot(depths*1e3, fwhm*1e3, '-o', 'LineWidth',1.5, 'MarkerSize',5);
ylabel('径向 FWHM / mm');
yyaxis right;
plot(depths*1e3, peakD*1e6, '-s', 'LineWidth',1.5, 'MarkerSize',5);
ylabel('轴线峰值 B_z / \muT');
xlabel('深度 z / mm');
title('(b) 聚焦度与穿透深度');
exportgraphics(gcf, fullfile(figDir,'fig07_focality.png'), 'Resolution', 300);
fprintf('[M] 聚焦性: 深度(mm) 轴线峰值(uT) FWHM(mm)\n');
for di = 1:numel(depths)
    fprintf('    %6.1f  %10.2f  %8.2f\n', depths(di)*1e3, peakD(di)*1e6, fwhm(di)*1e3);
end

% =========================================================================
% 电感 / 电阻估算 + 数值数据导出（供 FEMM 对比）
% =========================================================================
[L, Rdc, wireLen] = coil_L_R(pathsL, 2*mm, 1*mm, curL);
fprintf('[M] 电感估算 L = %.1f uH，直流电阻 R = %.1f mOhm，导线总长 %.2f m\n', L*1e6, Rdc*1e3, wireLen);

writematrix([za*1e3, Ba(:,3)], fullfile(datDir,'axis_numeric_I1A.csv'));
PeR = [rho(:), zeros(numel(rho),1), -10*mm*ones(numel(rho),1)];
BRf = bs_field(PeR, coil, cur);              % 整线圈径向线（z=-10mm）
writematrix([rho(:)*1e3, BRf(:,1), BRf(:,3)], fullfile(datDir,'radial_z-10_numeric_I1A.csv'));
fprintf('数据已导出: data/axis_numeric_I1A.csv, data/radial_z-10_numeric_I1A.csv\n');
fprintf('完成：论文图件与指标生成。\n');
