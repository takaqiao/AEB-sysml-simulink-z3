# 项目：基于 Simulink 的 AEB 系统建模、仿真与逆向建模

## 1. 项目简介

本项目采用“仿真驱动的逆向建模”方法，对一个汽车自动紧急制动（AEB）系统进行开发与分析。首先，我们利用 MATLAB 脚本自动化构建并运行一个包含车辆动力学和 Stateflow 控制逻辑的 Simulink 模型。在确保仿真结果符合预期后，我们再利用 PlantUML 工具，根据已验证的模型结构和行为，逆向生成项目报告所需的 SysML 图表（如 BDD, IBD, STM 等）。

此方法的核心优势在于，它将工程实现的正确性置于首位，同时保证了建模文档与实际系统的高度一致性，并且整个流程高效、自动化。

## 2. 核心技术栈

- **仿真与控制**: `MATLAB R2023b` 或更高版本, `Simulink`, `Stateflow`
- **建模与绘图**: `PlantUML`
- **开发环境**: `Visual Studio Code` (推荐安装 PlantUML 插件)

## 3. 项目结构说明

```
aeb_project/
├── run_aeb_simulation.m    # 【核心】MATLAB主脚本，构建并运行仿真
├── diagrams/               # 存放所有PlantUML代码 (.puml) 和生成的图片
│   ├── requirement.puml
│   ├── usecase.puml
│   ├── bdd.puml
│   ├── ibd.puml
│   └── stm.puml
└── README.md               # 本项目说明文件
```

## 4. 执行流程

1.  **环境准备**:

    - 安装 MATLAB & Simulink。
    - 安装 VS Code 并从扩展商店安装 `PlantUML` 插件。
    - 安装 [Graphviz](https://graphviz.org/download/)（PlantUML 需要它来生成图表）。

2.  **运行仿真**:

    - 在 MATLAB 中打开并运行 `run_aeb_simulation.m` 脚本。
    - 脚本会自动创建一个名为 `AEB_Simulation_Model.slx` 的 Simulink 模型文件。
    - 脚本会自动运行仿真，并在完成后弹出一个包含三张子图的结果图。

3.  **生成 SysML 图表**:

    - 在 VS Code 中，打开 `diagrams/` 目录下的任意 `.puml` 文件。
    - 使用快捷键 `Alt+D` (或根据插件说明) 可以实时预览生成的图表。
    - 您可以右键点击预览图，将其导出为 PNG 或 SVG 格式，用于您的报告。

4.  **模型检查 (UPPAAL)**:
    - Simulink 的 Stateflow 模型可以被导出为可供形式化验证工具使用的格式。您可以利用 **Simulink Design Verifier** 等工具，将 `AEB_Stateflow_Controller` 导出，然后在 UPPAAL 中进行分析。

## 5. 作者

- ...
