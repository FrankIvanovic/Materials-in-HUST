# 课题一：圆形线圈 —— 课程论文（LaTeX）

## 编译方法

需要 XeLaTeX（仓库所在机器已装 TeX Live 2026）。在 `paper/` 目录下：

```bash
xelatex main.tex
bibtex main
xelatex main.tex
xelatex main.tex
```

依赖宏包：`ctex`、`siunitx`、`booktabs`、`subcaption`、`hyperref`（TeX Live 完整安装均自带）。

## 文件结构

```
paper/
├── main.tex      % 论文主体（七节骨架，[TODO] 处待填写）
├── ref.bib       % 参考文献库（初稿）
├── figures/      % 插图（MATLAB/仿真导出图放这里）
└── README.md     % 本文件
```

## 待讨论/待确认清单

1. **径向绕距 Δa**：由内外径与 9 匝反推 ≈5.3 mm，需确认导线/铜带宽度。
2. **层间距离 h**：图纸侧视图给出线圈总厚度 <10 mm（双层紧贴），模型默认取中心距 h≈4 mm，可调。
3. **激励电流 I**：取归一化 1 A，还是 TMS 实际脉冲峰值（kA 量级）？
4. **引线与手柄**（R20 颈部、60/40/18 尺寸）是否计入磁场计算？
5. **有限元软件选型**：COMSOL / Ansys Maxwell / FEMM？
6. 离轴场解析式（椭圆积分）是否写入正文还是附录？
7. 摘要、各节正文的撰写分工与篇幅。
