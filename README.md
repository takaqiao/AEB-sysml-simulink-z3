# 基于 SysML v2 的集成式系统建模、仿真与验证项目

## 1. 项目简介

本项目旨在探索和实践基于模型的系统工程（MBSE）的现代化工作流。我们使用 OMG 最新的 SysML v2 标准，对一个复杂的软硬件混合系统（**请在此处替换为您自己的系统名称，例如：自动驾驶汽车感知系统**）进行建模。

项目的核心目标是打通从高级设计到具体分析的桥梁，实现以下集成：

- **建模**: 使用 SysML v2 的文本和图形化表示法来精确描述系统需求、结构和行为。
- **仿真**: 将 SysML 模型中定义的参数和逻辑与 MATLAB/Simulink 的动态仿真环境相结合。
- **验证**: 利用 UPPAAL 模型检查工具，对系统关键行为（如状态机）的正确性进行形式化验证。
- **扩展性**: 在模型中集成并分析复杂算法（如神经网络）。

本项目的所有工作都在 Visual Studio Code (VS Code) 中完成，利用其强大的集成开发能力。

## 2. 核心技术栈

- **建模语言**: `SysML v2` (通过官方试验性 `Jupyter Java Kernel` 实现)
- **核心编程语言**: `Python 3.11`
- **开发环境**: `Visual Studio Code`
- **环境管理**: `Miniconda`
- **仿真工具**: `MATLAB / Simulink`
- **模型检查工具**: `UPPAAL`
- **主要 Python 库**: `Pandas` (数据处理), `Matplotlib` (绘图), `lxml` (模型文件解析), `matlabengine` (Python-MATLAB 接口)

## 3. 项目结构说明

```
sysml_project/
├── conda_requirements.txt  # Conda环境依赖文件
├── requirements.txt        # Pip环境依赖文件
├── README.md               # 您正在阅读的这个文件
|
├── data/                   # 存放数据文件
│   ├── model_export/       # 存放从SysML模型导出的文件(如.json, .xml)
│   └── simulation_output/  # 存放仿真输出结果(如.csv)
|
├── docs/                   # 存放项目文档 (最终报告、演讲稿)
|
├── models/                 # 存放外部模型文件
│   ├── simulink/           # 存放.slx文件
│   └── verification/       # 存放UPPAAL模型文件
|
└── notebooks/              # 核心工作目录，存放Jupyter Notebooks
    ├── 1_System_Modeling.ipynb         # 【使用SysML内核】定义系统模型
    ├── 2_Simulation_Driver.ipynb     # 【使用Python内核】驱动Simulink仿真
    ├── 3_Verification_Driver.ipynb   # 【使用Python内核】生成UPPAAL模型
    └── 4_Results_Analysis.ipynb      # 【使用Python内核】分析和可视化结果
```

## 4. 环境配置与安装

在运行本项目前，请确保您的系统已安装以下**前置软件**：

1.  **Miniconda**: [Miniconda 官网](https://docs.conda.io/projects/miniconda/en/latest/)
2.  **Java**: [Java 官网](https://adoptium.net/) (SysML 内核需要)
3.  **MATLAB & Simulink**: [MathWorks 官网](https://www.mathworks.com/)
4.  **UPPAAL**: [UPPAAL 官网](https://uppaal.org/)

然后，请按照以下步骤在终端中配置 Python 环境：

1.  **创建并激活 Conda 虚拟环境**:

    ```bash
    conda create -n sysml_env python=3.11 -y
    conda activate sysml_env
    ```

2.  **安装 Conda 依赖**:
    然后运行安装命令:

    ```bash
    conda install --file conda_requirements.txt -c conda-forge -y
    ```

3.  **安装 Pip 依赖**:
    然后运行安装命令:

    ```bash
    pip install -r requirements.txt
    ```

4.  **在 VS Code 中配置**:
    - 安装 **Python** 和 **Jupyter** 官方扩展。
    - 使用 `Ctrl+Shift+P` 打开命令面板，选择 `Python: Select Interpreter`，然后指向我们创建的 `sysml_env` 环境。

## 5. 工作流与执行顺序**WIP**

本项目的核心思想是**模型驱动**，但由于工具链的限制，我们采用**基于文件导出的半集成工作流**。

1.  **步骤一：系统建模 (`1_System_Modeling.ipynb`)**

    - 在 VS Code 中打开此文件。
    - **关键**：为此 Notebook 选择 **"SysML" 内核**。
    - 使用 SysML v2 文本语法完成对系统的建模。
    - 完成后，使用 VS Code 的 **"导出(Export)"** 功能，将模型导出为 **JSON 文件**（或其他机器可读格式），并存放在 `data/model_export/` 目录下。

2.  **步骤二：驱动仿真 (`2_Simulation_Driver.ipynb`)**

    - 在 VS Code 中打开此文件。
    - **关键**：为此 Notebook 选择 **`sysml_env` (Python)** 内核。
    - 编写 Python 代码，读取上一步导出的 JSON 文件，解析出模型参数。
    - 使用 `matlabengine` 库，将这些参数设置到 `models/simulink/` 中的 `.slx` 文件，并运行仿真。

3.  **步骤三：执行验证 (`3_Verification_Driver.ipynb`)**

    - 在 VS Code 中打开此文件。
    - **关键**：为此 Notebook 选择 **`sysml_env` (Python)** 内核。
    - 编写 Python 代码，同样读取导出的 JSON 文件，解析出状态机等行为模型。
    - 将解析出的逻辑转换为 UPPAAL 的 XML 格式，并存放在 `models/verification/` 目录下。

4.  **步骤四：结果分析 (`4_Results_Analysis.ipynb`)**
    - 在 VS Code 中打开此文件。
    - **关键**：为此 Notebook 选择 **`sysml_env` (Python)** 内核。
    - 读取并分析仿真产生的数据，使用 `Matplotlib` / `Plotly` 等库进行可视化。

## 6. 注意事项

- 本项目的工作流被清晰地划分为两个领域：**SysML 内核领域**（用于权威建模）和**Python 内核领域**（用于分析、仿真和集成）。
- 两个领域之间通过**模型导出文件**作为桥梁，这保证了设计模型的“单一事实来源”地位，是符合 MBSE 核心思想的务实选择。

- ...
