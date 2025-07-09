# aeb_logic_verification.py

from z3 import *

print("--- AEB Controller Logic Verification with Z3 ---")

# 1. 定义系统变量 (Inputs, Outputs, and Parameters of the Controller)
# 我们将控制器核心逻辑中用到的所有变量都定义为Z3的实数(Real)变量
TTC      = Real('TTC')      # Input: Time to Collision
FCWtime  = Real('FCWtime')  # Input: Forward Collision Warning Time Threshold
PB1time  = Real('PB1time')  # Input: Partial Braking 1 Time Threshold
PB2time  = Real('PB2time')  # Input: Partial Braking 2 Time Threshold
FBtime   = Real('FBtime')   # Input: Full Braking Time Threshold

decel    = Real('decel')    # Output: The final deceleration value
FBdecel  = Real('FBdecel')  # Parameter: The constant deceleration for Full Braking
PB2decel = Real('PB2decel') # Parameter: The constant deceleration for Partial Braking 2
PB1decel = Real('PB1decel') # Parameter: The constant deceleration for Partial Braking 1

# 2. 将AEB状态机逻辑翻译为Z3约束
# 根据 AEB_Controller 中的Stateflow图，将决策逻辑形式化。
# 核心逻辑是：根据TTC所处的区间，决定decel输出值。

# 定义进入各个状态的条件 (Guards)
is_full_braking_zone = And(Abs(TTC) < FBtime, TTC < 0)
is_pb2_braking_zone  = And(Abs(TTC) < PB2time, TTC < 0)
is_pb1_braking_zone  = And(Abs(TTC) < PB1time, TTC < 0)
is_fcw_zone          = And(Abs(TTC) < FCWtime, TTC < 0)

# 使用Z3的If(condition, then_value, else_value)来构建决策树
# 模拟状态机的entry actions
controller_logic = If(is_full_braking_zone, decel == FBdecel,
                   If(is_pb2_braking_zone, decel == PB2decel,
                   If(is_pb1_braking_zone, decel == PB1decel,
                   If(is_fcw_zone,          decel == 0,
                                            decel == 0  # Default state
                   ))))

# 3. 定义系统参数约束
# 根据 AEB_Controller 中的测试参数，我们为制动等级设定具体值
param_constraints = [
    FBdecel  == 9.8,
    PB2decel == 5.3,
    PB1decel == 3.8
]

# 4. 定义待验证的“坏”情况 (Property to Verify)
# 我们要验证的安全属性是：“不应该在安全时全力制动”。
# 它的“反例”就是：“系统在全力制动，并且当时情况是安全的”。

# 定义“系统在全力制动”
full_brakes_applied = (decel == FBdecel)

# 定义“当时情况是安全的” (即，不满足进入全力制动状态的条件)
# "不满足 (abs(TTC) < FBtime && TTC < 0)" 的逻辑非
situation_is_safe = Not(And(Abs(TTC) < FBtime, TTC < 0))

# 将“坏”情况组合成一个断言
property_to_check = And(full_brakes_applied, situation_is_safe)

print("\n[INFO] Verifying property: 'The system should NOT apply full brakes when the situation is safe.'")
print("[INFO] Z3 will search for a counterexample where:")
print(f"[INFO]   1. {full_brakes_applied}")
print(f"[INFO]   AND 2. {situation_is_safe}")

# 5. 创建求解器并进行求解
solver = Solver()

# 添加所有规则：控制器逻辑、参数值、以及我们想要寻找的“坏”情况
solver.add(controller_logic)
solver.add(param_constraints)
solver.add(property_to_check)

# 运行检查
result = solver.check()

# 6. 分析结果
print("\n--- Z3 Solver Result ---")
print(f"Result: {result}")

if result == sat:
    # 如果结果是 sat (satisfiable)，说明Z3找到了一个反例
    print("\n[BUG FOUND!] Z3 found a scenario where the safety property is violated.")
    print("This means the system can apply full brakes under unsafe conditions.")
    print("Model that triggers the bug:")
    # 打印出导致bug的具体数值
    m = solver.model()
    print(m)
else:
    # 如果结果是 unsat (unsatisfiable)，说明Z3穷尽所有可能也找不到反例。
    print("\n[PROPERTY VERIFIED!] Z3 could not find any counterexample.")
    print("This formally proves that based on the provided logic, the system will ONLY apply full brakes")
    print("when the condition 'Abs(TTC) < FBtime && TTC < 0' is met.")