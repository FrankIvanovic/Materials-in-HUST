# MATLAB 计算代码（课题一：圆形线圈 —— 论文分支）

本分支只包含课题一论文所需的代码：`common/` 通用磁场计算库（与
`experiment_code` 分支的 15 线圈通用库同源）和 `paper_circular_coil/`
论文专用脚本。全部 15 个题目的实验代码见 `experiment_code` 分支。

## 环境要求

- MATLAB **R2016b 或更高**（本机实测 R2026a），无任何 Toolbox 依赖
- FEMM 4.2（仅 `run_femm_axis.m` 需要，本机安装于 `E:\femm42`；
  免费软件，https://www.femm.info）

## 运行顺序（生成论文全部图件与数据）

```matlab
cd matlab/paper_circular_coil
main_paper_figures   % 图 1–7、全部数值指标、数值解 CSV（约 1 min）
run_femm_axis        % FEMM 自动建模求解，导出有限元 CSV（会弹出 FEMM 窗口）
compare_femm         % 图 8、FEMM 对比指标
```

也可不用 MATLAB 自动化，直接在 FEMM 中 File → Run Lua script 运行
`paper_circular_coil/femm/circle_coil_axi.lua`，生成同名 CSV 供
`compare_femm.m` 对比。

## 文件说明

| 文件 | 功能 |
|------|------|
| `common/bs_field.m` | 直线单元闭式毕奥–萨伐尔磁场核 |
| `common/spiral_pts.m` / `multilayer_spiral.m` | 平面螺旋 / 多层绕组几何 |
| `common/field_on_axis.m` / `field_on_plane.m` | 轴线 / 平面磁场采样 |
| `common/coil_L_R.m` | 电感（Neumann）与直流电阻估算 |
| `paper_circular_coil/elliptic_ke.m` | AGM 完全椭圆积分（免工具箱） |
| `paper_circular_coil/loop_field_elliptic.m` | 单匝圆环离轴场精确解 |
| `paper_circular_coil/main_paper_figures.m` | 主脚本：论文图 1–7 与全部指标 |
| `paper_circular_coil/run_femm_axis.m` | FEMM 自动建模、求解、导出 |
| `paper_circular_coil/compare_femm.m` | 有限元解 vs 数值解对比（图 8） |
| `paper_circular_coil/femm/circle_coil_axi.lua` | FEMM 一键 Lua 脚本（手动运行用） |
| `paper_circular_coil/data/` | CSV 中间数据与 FEMM 模型存档 |

模型参数：平面螺旋双层 9 匝、内外径 Φ30/Φ115 mm、绕距 4.72 mm、层间距
4 mm（Φ4 紫铜管）、归一化电流 1 A；引线（两条平行反流直导线，间距
18 mm、长 100 mm）作为可选工况对比。
