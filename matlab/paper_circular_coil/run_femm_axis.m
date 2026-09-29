function run_femm_axis()
%RUN_FEMM_AXIS  用 FEMM 建立圆形线圈轴对称有限元模型并导出磁场数据
% ========================================================================
% 前提：FEMM 4.2 已安装（本机安装于 E:\femm42，如路径不同请改 FEMM_MFILES）。
% 模型：轴对称静磁场；18 个矩形绕组截面（每匝 4 mm x 4 mm，Φ4 紫铜管），
%       归一化电流 1 A（电路 'coil'，串联，18 匝各 1 A）；
%       求解域 r ∈ [0,1500] mm、z ∈ [-1500,1500] mm（线圈半径约 26 倍），
%       不设边界条件（自然边界），边界效应 <1e-5 量级。
% 注意：① 求解域必须包含 r=0 对称轴段（否则域"开口"，网格器失败）；
%       ② FEMM 4.2 对含中文/全角字符的路径支持不佳，建模与求解在纯
%         ASCII 临时目录完成，结束后再拷回仓库 data/ 目录。
% 输出：data/femm_axis_I1A.csv（z_mm, Bz_T）
%       data/femm_radial_z-10_I1A.csv（r_mm, Br_T, Bz_T）
%       data/circle_coil_axi.fem / .ans（模型与解存档）
% ========================================================================
thisDir  = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(thisDir));
datDir   = fullfile(thisDir, 'data');
if ~exist(datDir, 'dir'), mkdir(datDir); end
wk = 'C:\Users\Frank\AppData\Local\Temp\femm_work';
if ~exist(wk, 'dir'), mkdir(wk); end

FEMM_MFILES = 'E:\femm42\mfiles';          % FEMM 自带 MATLAB 接口
assert(exist(FEMM_MFILES, 'dir') == 7, '未找到 FEMM mfiles: %s', FEMM_MFILES);
addpath(FEMM_MFILES);

% ---- 几何参数（与 main_paper_figures.m 一致，单位 mm）-------------------
rIn = 15;  rOut = 57.5;  nTurns = 9;  dz = 4;  hw = 2;   % 匝半宽/半高
aK  = rIn + (rOut - rIn)*((1:nTurns)' - 0.5)/nTurns;

% ---- 启动 FEMM（COM 自动化，会弹出 FEMM 窗口）---------------------------
fprintf('清理旧实例并启动 FEMM ...\n');
system('taskkill /IM femm.exe /F >nul 2>&1');
pause(0.5);
openfemm;                                   % actxserver('femm.ActiveFEMM')
cleanupObj = onCleanup(@() closeFemm());

newdocument(0);
% 注意：FEMM 自带 mfiles 封装在 mi_probdef 的 4 参数分支缺逗号（num 不带
% 前导逗号），故按 5 参数调用（第 5 参 depth 对轴对称问题无效）。
mi_probdef(0, 'millimeters', 'axi', 1e-8, 0);
mi_getmaterial('Air');
mi_getmaterial('Copper');

% ---- 求解域：半圆域（r=0 轴线 + 180° 圆弧），弧边界用渐近混合条件 ---------
% 注1：远边界用 FEMM 手册附录 A.3.2 的渐近（混合）边界条件
%      ∂A/∂n + c0·A = 0，c0 = n/(μ0·ro)，ro 为外半径（取米，与工作单位无关）；
%      轴对称偶极子远场 A ∝ 1/r²，取 n = 2。
%      （实测：自然边界使远场抬高 ~7%，全域 A=0 则封死赤道回流、近远场
%       均失真，渐近边界近远场均正确。）
% 注2：本机 FEMM 4.2 (21Apr2019) 的 mi_setsegmentprop 无法为直线段挂边界
%      属性（automesh 等参数生效、propname 不生效），但 mi_setarcsegmentprop
%      正常，故外边界采用单条 180° 圆弧。
R = 1200;
mu0 = 4*pi*1e-7;
c0asym = 2/(mu0*(R*1e-3));                   % = 1.3263e6
mi_addnode(0, -R);  mi_addnode(0, R);
mi_addnode(0, 130);  mi_addnode(0, -130);
% r = 0 对称轴在 ±130 处显式分段（内层空气盒的边界 T 接于此，避免未分割
% 的 T 结），三段均施加 A = 0（轴对称问题 A(0)=0 为精确条件）
mi_addsegment(0, R, 0, 130);
mi_addsegment(0, 130, 0, -130);
mi_addsegment(0, -130, 0, -R);
mi_addarc(0, -R, 0, R, 180, 45);             % 圆弧经过 (R, 0)
mi_addboundprop('A0', 0, 0, 0, 0, 0, 0, 0, 0);
for zsel = [700 0 -700]
    mi_selectsegment(0, zsel);
    mi_setsegmentprop('A0', 0, 1, 0, 0);
    mi_clearselected();
end
% 9 参调用生成的 BdryType=0（prescribed A）会忽略 c0，且与混合边界同名时
% 会抢先被选中，故只通过原始 10 参字符串创建 type=2 的混合边界：
callfemm(sprintf('mi_addboundprop("asym",0,0,0,0,0,0,%.17g,0,2)', c0asym));
mi_selectarcsegment(R, 0);
mi_setarcsegmentprop(30, 'asym', 0, 0);
mi_clearselected();

% ---- 18 个绕组截面（矩形 4 mm x 4 mm，电路 'coil' 串联 1 A/匝）-----------
for kk = 1:nTurns
    for zc = [0, dz]
        x1 = aK(kk) - hw;  x2 = aK(kk) + hw;
        z1 = zc - hw;      z2 = zc + hw;
        mi_addnode(x1, z1);  mi_addnode(x2, z1);
        mi_addnode(x2, z2);  mi_addnode(x1, z2);
        mi_addsegment(x1, z1, x2, z1);
        mi_addsegment(x2, z1, x2, z2);
        mi_addsegment(x2, z2, x1, z2);
        mi_addsegment(x1, z2, x1, z1);
        mi_addblocklabel(aK(kk), zc);
        mi_selectlabel(aK(kk), zc);
        mi_setblockprop('Copper', 0, 0.4, 'coil', 0, 0, 1);
        mi_clearselected();
    end
end
% ---- 内层细化空气区（线圈附近 3 mm 网格；左边界即 r=0 轴段）--------------
ri = 130; zi = 130;
mi_addnode(ri, -zi);  mi_addnode(ri, zi);
mi_addsegment(0, -zi,  ri, -zi);
mi_addsegment(ri, -zi, ri,  zi);
mi_addsegment(ri,  zi, 0,   zi);
mi_addblocklabel(ri/2, 0);
mi_selectlabel(ri/2, 0);
mi_setblockprop('Air', 0, 1, '<None>', 0, 0, 0);
mi_clearselected();

mi_addblocklabel(600, 600);
mi_selectlabel(600, 600);
mi_setblockprop('Air', 0, 25, '<None>', 0, 0, 0);
mi_clearselected();
mi_addcircprop('coil', 1, 1);               % 串联电路，1 A

% ---- 求解 ---------------------------------------------------------------
fprintf('划分网格并求解（几千单元，约数十秒）...\n');
mi_saveas(fullfile(wk, 'circle_coil_axi.fem'));
mi_analyze(0);
mi_loadsolution();
fprintf('[M] FEMM 网格规模：节点 %d，一阶三角元 %d\n', ...
        callfemm('mo_numnodes()'), callfemm('mo_numelements()'));

% ---- 轴向分量判别：FEMM 轴对称输出 (Bx,By) = (Br,Bz) ---------------------
p0 = mo_getb(0.05, 0);
if abs(p0(2)) >= abs(p0(1))
    bAx = 2;  fprintf('FEMM 轴向分量 = By（第 2 列）\n');
else
    bAx = 1;  fprintf('FEMM 轴向分量 = Bx（第 1 列）\n');
end
sgn = sign(p0(bAx));                        % 电流方向约定校准，使 Bz(0,0) > 0
fprintf('Bz(0,0) = %.2f uT\n', p0(bAx)*sgn*1e6);

% ---- 采样：轴线 + z=-10mm 径向线（点距放宽以减少 COM 往返；对比时插值）----
zv = (-100:1:60).';                         % mm
BzA = zeros(size(zv));
for i = 1:numel(zv)
    p = mo_getb(0.05, zv(i));
    BzA(i) = sgn*p(bAx);
end
rho = (0:0.25:56).';                        % mm
BrR = zeros(size(rho));  BzR = zeros(size(rho));
for i = 1:numel(rho)
    p = mo_getb(rho(i), -10);
    BrR(i) = sgn*p(3-bAx);                  % 径向分量
    BzR(i) = sgn*p(bAx);
end

writematrix([zv, BzA], fullfile(datDir, 'femm_axis_I1A.csv'));
writematrix([rho, BrR, BzR], fullfile(datDir, 'femm_radial_z-10_I1A.csv'));
fprintf('[M] FEMM 轴线峰值 Bz(0,0) = %.2f uT (I=1A)\n', max(BzA)*1e6);
fprintf('已导出: data/femm_axis_I1A.csv, data/femm_radial_z-10_I1A.csv\n');

% ---- 模型与解存档拷回仓库 -----------------------------------------------
try
    copyfile(fullfile(wk, 'circle_coil_axi.fem'), fullfile(datDir, 'circle_coil_axi.fem'));
    copyfile(fullfile(wk, 'circle_coil_axi.ans'), fullfile(datDir, 'circle_coil_axi.ans'));
catch
end
fprintf('完成：run_femm_axis\n');
end

function closeFemm()
try
    callfemm('quit()');
catch
end
try
    system('taskkill /IM femm.exe /F >nul 2>&1');
catch
end
clear global HandleToFEMM
end
