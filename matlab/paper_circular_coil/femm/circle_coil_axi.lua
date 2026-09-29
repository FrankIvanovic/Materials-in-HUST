-- ========================================================================
-- 课题一：圆形线圈 —— FEMM 4.2 轴对称静磁场一键建模脚本
-- -----------------------------------------------------------------------
-- 用法：打开 FEMM 4.2，菜单 File -> Run Lua script... 选择本文件。
--       （或把本文件与 femm.exe 放同一目录后从命令行运行 femm.exe，
--        手动 File -> Run Lua script。）
-- 模型：18 个 4 mm x 4 mm 矩形绕组截面（Φ4 紫铜管，双层 9 匝），
--       归一化总电流 1 A；求解域 500 mm x 1000 mm，外边界 A = 0。
-- 输出：脚本运行目录下 femm_axis_I1A.csv / femm_radial_z-10_I1A.csv，
--       与 MATLAB 数值解网格一致，可直接用 compare_femm.m 对比。
-- ========================================================================

newdocument(0)
mi_probdef(0, "millimeters", "axisymmetric", 1e-8)
mi_getmaterial("Air")
mi_getmaterial("Copper")

-- ---- 几何参数（mm）------------------------------------------------------
rIn = 15.0
rOut = 57.5
nTurns = 9
dz = 4.0
hw = 2.0
R = 500.0
Z = 500.0

-- ---- 求解域外边界（A = 0）----------------------------------------------
mi_addnode(0, -Z);  mi_addnode(R, -Z);  mi_addnode(R, Z);  mi_addnode(0, Z)
mi_addsegment(0, -Z, R, -Z)
mi_addsegment(R, -Z, R,  Z)
mi_addsegment(R,  Z, 0,  Z)
mi_addboundprop("A0", 0, 0, 0, 0, 0, 0, 0, 0, 0)
mi_selectsegment(R/2, -Z);  mi_setsegmentprop("A0", 0, 1, 0, 0)
mi_selectsegment(R,   0);   mi_setsegmentprop("A0", 0, 1, 0, 0)
mi_selectsegment(R/2,  Z);  mi_setsegmentprop("A0", 0, 1, 0, 0)
mi_clearselected()

-- ---- 绕组截面 ------------------------------------------------------------
for k = 1, nTurns do
    a = rIn + (rOut - rIn)*((k - 0.5)/nTurns)
    for _, zc in ipairs({0.0, dz}) do
        x1 = a - hw;  x2 = a + hw
        z1 = zc - hw;  z2 = zc + hw
        mi_addnode(x1, z1);  mi_addnode(x2, z1)
        mi_addnode(x2, z2);  mi_addnode(x1, z2)
        mi_addsegment(x1, z1, x2, z1)
        mi_addsegment(x2, z1, x2, z2)
        mi_addsegment(x2, z2, x1, z2)
        mi_addsegment(x1, z2, x1, z1)
        mi_addblocklabel(a, zc)
        mi_setblockprop("Copper", 0, 0.4, "coil", 0, 0, 1)
    end
end
mi_addblocklabel(R/2, Z/2)
mi_setblockprop("Air", 0, 25, "<None>", 0, 0, 0)
mi_addcircprop("coil", 1, 1)

-- ---- 求解 ----------------------------------------------------------------
mi_saveas("circle_coil_axi.fem")
mi_analyze(0)
mi_loadsolution()

-- ---- 采样并导出 CSV ------------------------------------------------------
function bax(x, y)
    local b1, b2 = mo_getb(x, y)
    if math.abs(b2) >= math.abs(b1) then return b1, b2 else return b2, b1 end
end
-- 轴向分量判别：取模较大者为 Bz，并统一符号使 Bz(0,0) > 0
local p1, p2 = mo_getb(0.05, 0)
local sgn = 1
if (math.abs(p2) >= math.abs(p1) and p2 < 0) or (math.abs(p2) < math.abs(p1) and p1 < 0) then
    sgn = -1
end

f = io.open("femm_axis_I1A.csv", "w")
for z = -100, 60, 0.5 do
    local br, bz = bax(0.05, z)
    f:write(string.format("%.2f,%.8g\n", z, sgn*bz))
end
f:close()

f = io.open("femm_radial_z-10_I1A.csv", "w")
for r = 0, 56, 0.1 do
    local b1, b2 = mo_getb(r, -10)
    local br, bz
    if math.abs(b2) >= math.abs(b1) then br, bz = b1, b2 else br, bz = b2, b1 end
    f:write(string.format("%.2f,%.8g,%.8g\n", r, sgn*br, sgn*bz))
end
f:close()

mo_close()
print("完成：已写出 femm_axis_I1A.csv 与 femm_radial_z-10_I1A.csv")
