# 课题一：圆形线圈 —— 课程论文（LaTeX）

基于毕奥–萨伐尔定律的圆形 TMS 线圈磁场计算、MATLAB 数值实现与 FEMM
有限元对比。论文 PDF：`main.pdf`（13 页，已随仓库提交）。

## 编译方法

需要 XeLaTeX（本机已装 TeX Live 2026）。在 `paper/` 目录下：

```bash
xelatex main.tex
bibtex main
xelatex main.tex
xelatex main.tex
```

依赖宏包：`ctex`、`siunitx`、`xcolor`、`booktabs`、`subcaption`、`listings`、
`hyperref`（TeX Live 完整安装均自带）。

## 文件结构

```
paper/
├── main.tex      % 论文主体（七节：简介/理论/MATLAB/结果/FEMM对比/结论/参考文献）
├── ref.bib       % 参考文献库
├── figures/      % 插图（由 matlab/paper_circular_coil 脚本生成，PNG 300dpi）
├── main.pdf      % 编译产物
└── README.md     % 本文件
```

## 图件与数据的生成

论文全部图件、数值指标与对比数据由 `matlab/paper_circular_coil/` 下的
MATLAB 脚本生成（MATLAB R2026a 实测通过，无工具箱依赖），运行顺序：

```matlab
main_paper_figures   % 论文图 1–7 + 全部指标 + 数值解 CSV
run_femm_axis        % FEMM 轴对称建模求解（需安装 FEMM 4.2，本机 E:\femm42）
compare_femm         % 图 8（FEMM 对比）+ 偏差指标
```

详见 `matlab/README.md` 与各脚本头部说明。

## 关键结果速览（归一化电流 1 A）

| 量 | 数值 |
|----|------|
| 线圈中心磁感应强度 Bz(0,0) | 351.29 µT（轴线峰值 354.34 µT，位于双层之间） |
| z = −10 mm 平面峰值 | 273.85 µT（77.7%） |
| 半衰深度 | ≈27 mm；径向 FWHM 由 30 mm（孔内）增至 ≈70 mm |
| 引线影响 | 轴线 ≤0.42%，平面峰值 +0.19%（可忽略） |
| 电感 / 直流电阻 | 19.5 µH / 7.8 mΩ（导线总长 4.30 m） |
| FEMM 对比 | 轴线 RMS 偏差 0.44%（最大 1.02%）；径向峰值偏差 +0.29% |
