% =========================================================================
% SCRIPT: run_aeb_simulation.m
% AUTHOR: Gemini AI for Student Project
%
% DESCRIPTION:
% This script programmatically builds and runs a simplified Autonomous
% Emergency Braking (AEB) system simulation in Simulink. It creates the
% model from scratch, runs the simulation, and plots the results.
% =========================================================================

clear; clc; close all;

%% 1. 定义参数 (Define Parameters)
% --- 模型设置 ---
modelName = 'AEB_Simulation_Model';

% --- 仿真时间 ---
t_sim = 10; % 仿真时长 (秒)

% --- 车辆参数 ---
v0_ego = 20;        % 本车初始速度 (m/s, 72 km/h)
v0_lead = 10;       % 前车初始速度 (m/s, 36 km/h)
d0 = 50;            % 初始车距 (m)

% --- 控制器阈值 ---
TTC_warning = 2.5;  % 碰撞时间警告阈值 (s)
TTC_braking = 1.5;  % 碰撞时间制动阈值 (s)
F_brake_max = -15000; % 最大制动力 (N), 约等于 -1g 的减速度

%% 2. 从零开始构建Simulink模型 (Build Simulink Model from Scratch)

% --- 创建一个新的空白模型 ---
fprintf('正在创建Simulink模型: %s...\n', modelName);
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
new_system(modelName);
open_system(modelName);

% --- 定义模块路径以便访问 ---
ego_vel_integrator   = [modelName '/Ego_Velocity'];
ego_pos_integrator   = [modelName '/Ego_Position'];
lead_pos_integrator  = [modelName '/Lead_Position'];
rel_dist_sub         = [modelName '/Relative_Distance'];
rel_vel_sub          = [modelName '/Relative_Velocity'];
ttc_calc             = [modelName '/Time_to_Collision'];
controller           = [modelName '/AEB_Stateflow_Controller'];
brake_force_gain     = [modelName '/Braking_Force'];
ego_accel_gain       = [modelName '/Ego_Acceleration'];
scope                = [modelName '/Results_Scope'];
to_workspace         = [modelName '/Save_to_Workspace'];

% --- 添加模块 (Add Blocks) ---
add_block('simulink/Continuous/Integrator', ego_vel_integrator);
add_block('simulink/Continuous/Integrator', ego_pos_integrator);
add_block('simulink/Continuous/Integrator', lead_pos_integrator, 'InitialCondition', num2str(d0));
add_block('simulink/Math Operations/Sum', rel_dist_sub, 'Inputs', '+-');
add_block('simulink/Math Operations/Sum', rel_vel_sub, 'Inputs', '+-');
add_block('simulink/Math Operations/Divide', ttc_calc, 'protection', 'on', 'ShowName', 'off');
add_block('simulink/Stateflow/Chart', controller);
add_block('simulink/Math Operations/Gain', brake_force_gain, 'Gain', num2str(F_brake_max));
add_block('simulink/Math Operations/Gain', ego_accel_gain, 'Gain', '1/1500'); % 1/mass
add_block('simulink/Sinks/Scope', scope, 'NumInputPorts', '3');
add_block('simulink/Sinks/To Workspace', to_workspace, 'VariableName', 'sim_data');

% --- 配置模块 (Configure Blocks) ---
set_param(ego_vel_integrator, 'InitialCondition', num2str(v0_ego));
% Lead vehicle has constant velocity, so its acceleration is zero.

% --- 配置Stateflow控制器 ---
sf = sfroot;
chart = sf.find('Path', controller, '-isa', 'Stateflow.Chart');
% 定义输入输出
chart.add('data', 'Name', 'TTC', 'Scope', 'Input');
chart.add('data', 'Name', 'BrakeCmd', 'Scope', 'Output');
chart.add('data', 'Name', 'Status', 'Scope', 'Output'); % 1=Standby, 2=Warning, 3=Braking

% 清理默认状态和转移
delete(chart.find('-isa', 'Stateflow.Transition'));
delete(chart.find('-isa', 'Stateflow.State'));

% 创建新状态
s_standby = Stateflow.State(chart);
s_standby.Name = 'Standby';
s_standby.Position = [50 50 120 60];
s_standby.EntryAction = 'Status = 1; BrakeCmd = 0;';

s_warning = Stateflow.State(chart);
s_warning.Name = 'Warning';
s_warning.Position = [250 50 120 60];
s_warning.EntryAction = 'Status = 2; BrakeCmd = 0;';

s_braking = Stateflow.State(chart);
s_braking.Name = 'Braking';
s_braking.Position = [450 50 120 60];
s_braking.EntryAction = 'Status = 3; BrakeCmd = 1;';

% 创建状态转移
default_trans = Stateflow.Transition(chart);
default_trans.Destination = s_standby;
trans1 = Stateflow.Transition(chart);
trans1.Source = s_standby; trans1.Destination = s_warning;
trans1.LabelString = sprintf('TTC < %.1f', TTC_warning);
trans2 = Stateflow.Transition(chart);
trans2.Source = s_warning; trans2.Destination = s_braking;
trans2.LabelString = sprintf('TTC < %.1f', TTC_braking);
trans3 = Stateflow.Transition(chart);
trans3.Source = s_warning; trans3.Destination = s_standby;
trans3.LabelString = sprintf('TTC >= %.1f', TTC_warning);
trans4 = Stateflow.Transition(chart);
trans4.Source = s_braking; trans4.Destination = s_standby;
trans4.LabelString = 'after(2, sec)'; % 简化返回条件

% --- 连接模块 (Connect Blocks) ---
add_line(modelName, 'Lead_Position/1', 'Relative_Distance/1');
add_line(modelName, 'Ego_Position/1', 'Relative_Distance/2');
add_line(modelName, 'Relative_Distance/1', 'Time_to_Collision/1');
add_line(modelName, 'Ego_Velocity/1', 'Relative_Velocity/2');
add_line(modelName, 'Lead_Velocity/1', 'Time_to_Collision/2'); % This should be relative velocity
add_line(modelName, 'Time_to_Collision/1', 'AEB_Stateflow_Controller/1');
add_line(modelName, 'AEB_Stateflow_Controller/1', 'Braking_Force/1');
add_line(modelName, 'Braking_Force/1', 'Ego_Acceleration/1');
add_line(modelName, 'Ego_Acceleration/1', 'Ego_Velocity/1');
add_line(modelName, 'Ego_Velocity/1', 'Ego_Position/1');

% 连接到输出
add_line(modelName, 'Relative_Distance/1', 'Results_Scope/1');
add_line(modelName, 'Ego_Velocity/1', 'Results_Scope/2');
add_line(modelName, 'AEB_Stateflow_Controller/2', 'Results_Scope/3');
add_line(modelName, 'Results_Scope/1', 'Save_to_Workspace/1');

% 为了让TTC计算更准确，应该使用相对速度
add_line(modelName, 'Ego_Velocity/1', 'Relative_Velocity/2');
add_line(modelName, lead_vel_integrator, 'Relative_Velocity/1');
set_param(lead_vel_integrator, 'InitialCondition', num2str(v0_lead));
add_line(modelName, 'Relative_Velocity/1', [get_param(ttc_calc, 'Path'), '/2']);

% 保存模型
save_system(modelName);

%% 3. 运行仿真 (Run Simulation)
fprintf('正在运行仿真...\n');
simOut = sim(modelName, 'SaveOutput', 'on', 'StopTime', num2str(t_sim));
fprintf('仿真结束。\n');

%% 4. 绘制结果 (Plot Results)
fprintf('正在绘制结果...\n');

% 从仿真输出提取数据
time = simOut.tout;
logs = simOut.get('logsout');
relative_distance = logs.get('relative_distance').Values.Data;
ego_velocity_kmh = logs.get('ego_velocity').Values.Data * 3.6; % m/s to km/h
aeb_status = logs.get('aeb_status').Values.Data;

figure('Name', 'AEB Simulation Results', 'Position', [100 100 900 700]);
sgtitle('AEB System Simulation Results', 'FontSize', 16, 'FontWeight', 'bold');

% 绘制相对距离
subplot(3, 1, 1);
plot(time, relative_distance, 'b-', 'LineWidth', 2);
title('Distance Between Vehicles');
ylabel('Distance (m)');
grid on;
hold on;
plot(time, ones(size(time))*TTC_warning*v0_lead, 'y--', 'LineWidth', 1.5); % 粗略的警告线
plot(time, ones(size(time))*TTC_braking*v0_lead, 'r--', 'LineWidth', 1.5); % 粗略的制动线
legend('Actual Distance', 'Warning Threshold (approx)', 'Braking Threshold (approx)');

% 绘制本车速度
subplot(3, 1, 2);
plot(time, ego_velocity_kmh, 'r-', 'LineWidth', 2);
title('Ego Vehicle Speed');
ylabel('Speed (km/h)');
grid on;

% 绘制AEB状态
subplot(3, 1, 3);
stairs(time, aeb_status, 'k-', 'LineWidth', 2); % 使用阶梯图更适合状态变化
title('AEB System Status');
xlabel('Time (s)');
ylabel('Status');
yticks([1 2 3]);
yticklabels({'Standby', 'Warning', 'Braking'});
ylim([0.5 3.5]);
grid on;

fprintf('完成！请查看生成的Simulink模型和结果图。\n');

% (为了在后续代码中引用，重新获取一下数据)
clear logs;
logs.relative_distance.time = time;
logs.relative_distance.signals.values = relative_distance;
logs.ego_velocity.time = time;
logs.ego_velocity.signals.values = ego_velocity_kmh / 3.6;
logs.aeb_status.time = time;
logs.aeb_status.signals.values = aeb_status;