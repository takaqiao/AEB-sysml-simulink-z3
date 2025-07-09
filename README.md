# AEB 系统：基于模型的系统工程全流程实践

## 1. 项目概述 (Project Overview)

本项目完整地展示了如何运用**基于模型的系统工程 (Model-Based Systems Engineering, MBSE)** 的思想，对一个**自动紧急制动 (AEB)** 安全关键系统进行从概念到验证的全流程开发。

我们采用了一套现代化的、集成的工具链，覆盖了系统工程的“V”模型的核心阶段：

- **需求分析与架构设计 (SysML)**: 在高层抽象地定义系统的目标、功能、结构与接口。
- **动态行为仿真 (Simulink)**: 在特定的测试场景下，验证系统设计的动态行为是否符合预期。
- **逻辑正确性证明 (Z3)**: 对系统最核心的决策逻辑，进行数学级别的形式化验证，以穷尽所有可能性的方式确保其安全性。

这个项目不仅仅是一个 AEB 功能的实现，更是一套可复用的、现代化的复杂系统开发方法论的完整展示。

---

## 2. 核心技术与工具链 (Core Technologies & Toolchain)

| 工具 (Tool)              | 版本     | 用途 (Purpose)                                                                                    | 所在目录             |
| :----------------------- | :------- | :------------------------------------------------------------------------------------------------ | :------------------- |
| **Enterprise Architect** | 17.1     | **系统建模 (SysML)**: 创建需求图、块定义图、状态机图等，是整个系统设计的“单一事实来源”。          | `./diagrams/`        |
| **MATLAB / Simulink**    | R2025a   | **动态仿真 (Simulation)**: 构建和运行 AEB 系统的闭环仿真模型，观察系统在特定场景下的动态行为。    | `./simulink/`        |
| **Z3 SMT Solver**        | 4.15.1.0 | **形式化验证 (Formal Verification)**: 使用其 Python API 对 AEB 控制器的核心安全逻辑进行数学证明。 | `./verification-z3/` |

---

## 3. 项目结构 (Project Structure)

.
├── diagrams/ # 存放所有 SysML 模型文件和相关文档
│ ├── AEB_System.eapx # (示例)Enterprise Architect 项目文件
│ └── sysml_readme.docx # SysML 模型详细说明文档
├── simulink/ # 存放所有 Simulink 模型和相关文档
│ ├── cfarrell_assign2.slx # 集成了 AEB 逻辑的顶层仿真模型
│ ├── car_model.slx # 车辆动力学模型
│ └── simulink_readme.docx # Simulink 模型分析与优化策略文档
├── verification-z3/ # 存放形式化验证代码和结果
│ ├── veri.py # Z3 Python 验证脚本
│ ├── output.txt # 验证脚本的运行输出结果
│ └── verireadme.docx # Z3 验证工作的详细说明文档
├── requirements.txt # Python 项目依赖
└── README.md # 本文档

---

## 4. 设计与实现详解 (Design & Implementation Details)

### 4.1 系统建模 (SysML)

我们使用 SysML 对 AEB 系统进行了全面的建模，涵盖了系统的需求、结构和行为。

- **需求 (Requirements)**: 我们通过需求图定义了系统的核心功能，如计算碰撞风险、提供预警和施加分阶段制动。
- **结构 (Structure)**: 通过块定义图 (BDD) 和内部块图 (IBD)，我们设计了系统的静态架构。这包括定义`Car`, `AEB_Controller`, `Sensor`等核心组件，以及它们之间的数据接口 (`iSensorData`, `iCarOutputs`等)。
- **行为 (Behavior)**: 我们使用状态机图 (State Machine Diagram) 精确地描述了`AEB_Controller`的核心决策逻辑，该逻辑直接基于原始报告中的`Stateflow`模型，包含了`Default`, `FCW`, `Partial_Braking1/2`, 和 `Full_Braking`等状态。

### 4.2 动态仿真 (Simulink)

我们对现有的 Simulink 模型进行了深入分析，识别出了其无法正常工作的核心原因。

- **现状**: 模型拥有一个良好的车辆动力学子系统 (`Car`) 和一个逻辑清晰的控制器子系统 (`AEB Controller`)。
- **关键问题**:
  1.  **开环控制**: 控制器的制动输出未连接到车辆模型，无法形成反馈。
  2.  **代数环**: 尝试连接时，因瞬时循环依赖导致 Simulink 报错。
  3.  **接口不匹配**: 控制器输出的“减速度(a)”与车辆模型需要的“制动力(F)”物理单位不匹配。
- **优化策略**: 我们提出了一套包含**实现制动执行器**、**插入 Unit Delay 打破代数环**和**构建闭环测试场景**的完整优化方案。

### 4.3 形式化验证 (Z3)

为了给系统的安全性提供数学级别的保证，我们对`AEB_Controller`的核心逻辑进行了形式化验证。

- **验证属性**: 我们验证了一个关键的安全属性：“系统绝不应该在情况安全时，却错误地执行了全力制动”。
- **验证策略**: 采用“证明-by-反例”的策略，我们要求 Z3 求解器去寻找是否存在一个场景，能同时满足“系统全力制动”和“情况是安全的”这两个相互矛盾的条件。
- **验证结果**: Z3 返回`unsat`（不可满足），这意味着它无法找到任何反例。这从数学上**证明**了我们的控制器逻辑是健全的，不会发生危险的“幽灵刹车”。

---

## 5. 如何开始 (Getting Started)

### 5.1 环境要求 (Prerequisites)

- **Enterprise Architect 17.1** 或更高版本，并确保 SysML 插件已激活。
- **MATLAB R2025a** 或更高版本，并安装 Simulink 和 Stateflow。
- **Python 3.8+**

### 5.2 安装依赖 (Installation)

本项目依赖`z3-solver`库。请在项目根目录打开终端，并运行以下命令：

```bash
# 使用pip安装所有在requirements.txt中定义的依赖
pip install -r requirements.txt
```

### 5.3 使用方法 (Usage)

1.  **查看 SysML 模型**:

    - 使用 **Enterprise Architect 17.1** 打开 `diagrams/AEB_System.eapx` 文件。
    - 参考 `diagrams/sysml_readme.docx` 文档来导航和理解模型。

2.  **运行 Simulink 仿真**:

    - 使用 **MATLAB R2025a** 打开 `simulink/` 目录。
    - 打开 `cfarrell_assign2.slx` 文件。
    - 在运行前，请务必根据 `simulink/simulink_readme.docx` 中的优化策略对模型进行修改，否则模型将无法正确运行。

3.  **运行形式化验证**:
    - 在项目根目录打开终端 (Terminal / PowerShell / CMD)。
    - 确保您的 Python 环境已激活并已安装`z3-solver`。
    - 执行以下命令：
      ```bash
      python verification-z3/veri.py
      ```
    - 观察输出结果，应显示 `Result: unsat`，代表安全属性验证通过。

---
