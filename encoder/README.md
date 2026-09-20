# 三输入编码器实验

## 实现及约定

`encoder.srcs/sources_1/new/encoder.v` 包含两种实现：

- `encoder`：过程性语句，使用 `always @*` 和 `case`，作为工程顶层。
- `encoder_behavioral`：直接描述逻辑表达式，使用 `assign`。严格按 Verilog 建模分类，这属于数据流建模；这里对应题目中要求先列真值表、求逻辑表达式的实现。

EN 和数据端均高电平有效。D[2]、D[1]、D[0] 分别代表 D3、D2、D1。B[1] 是编码高位，B[0] 是低位。禁止使能、无有效数据或多个数据有效时输出 00。本设计是组合电路，不需要时钟。

## 真值表

| EN | D3 | D2 | D1 | B[1] | B[0] |
| --- | --- | --- | --- | --- | --- |
| 0 | 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 0 | 1 | 0 | 0 |
| 0 | 0 | 1 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 | 0 | 0 |
| 0 | 1 | 0 | 0 | 0 | 0 |
| 0 | 1 | 0 | 1 | 0 | 0 |
| 0 | 1 | 1 | 0 | 0 | 0 |
| 0 | 1 | 1 | 1 | 0 | 0 |
| 1 | 0 | 0 | 0 | 0 | 0 |
| 1 | 0 | 0 | 1 | 0 | 1 |
| 1 | 0 | 1 | 0 | 1 | 0 |
| 1 | 0 | 1 | 1 | 0 | 0 |
| 1 | 1 | 0 | 0 | 1 | 1 |
| 1 | 1 | 0 | 1 | 0 | 0 |
| 1 | 1 | 1 | 0 | 0 | 0 |
| 1 | 1 | 1 | 1 | 0 | 0 |

## 逻辑表达式

用 ~ 表示非、& 表示与、| 表示或、^ 表示异或。

高位只在编号 2 或 3 单独有效时为 1：

```text
B[1] = EN & ((~D3 & D2 & ~D1) | (D3 & ~D2 & ~D1))
     = EN & ~D1 & (D3 ^ D2)
```

低位只在编号 1 或 3 单独有效时为 1：

```text
B[0] = EN & ((~D3 & ~D2 & D1) | (D3 & ~D2 & ~D1))
     = EN & ~D2 & (D3 ^ D1)
```

不能直接使用普通编码器的 D3 | D2 和 D3 | D1，因为题目要求多个输入有效时输出 00。

## 功能仿真

工程已登记测试文件 `encoder.srcs/sim_1/new/tb_encoder.v`，仿真顶层为 `tb_encoder`。打开工程后运行 Run Behavioral Simulation，即可观察 EN、D、procedural_B、behavioral_B 和 expected。

测试每 10 ns 遍历一个输入组合，独立统计有效输入数量并计算预期编码，同时检查两种实现。Vivado 2015.2 XSim 实测结果：

```text
PASS: all 16 input combinations, both models
$finish called at time : 160 ns
```

命令行复现（PowerShell，在 encoder/verification 目录中执行）：

```powershell
& C:/Xilinx/Vivado/2015.2/bin/xvlog.bat ../encoder.srcs/sources_1/new/encoder.v ../encoder.srcs/sim_1/new/tb_encoder.v
& C:/Xilinx/Vivado/2015.2/bin/xelab.bat tb_encoder -s tb_encoder_sim
& C:/Xilinx/Vivado/2015.2/bin/xsim.bat tb_encoder_sim -runall
```

## 综合结果及原理图检查

已通过 `verify.tcl` 对过程性顶层进行独立综合，未运行布局布线或生成比特流。综合本身报告 0 errors、0 critical warnings、0 warnings。启动时另有旧版 Vivado Tcl Store 目录访问报错，未阻止综合、网表及检查点生成；仿真编译阶段 WebTalk 遥测也报错，但仿真已执行到全部用例通过。

输出位于 `verification`：

- `encoder_synth.v`：综合网表。
- `encoder_synth.dcp`：综合检查点。
- `utilization.txt`：资源报告。
- `synthesis.log`：综合日志。
- `xsim.log`：功能仿真日志。

网表有两个 LUT4、四个输入缓冲、两个输出缓冲，无锁存器和触发器。两个 LUT4 的 INIT 均为 16'h0060，即仅地址 5 和 6 输出 1。按地址 {I3,I2,I1,I0} 解码，其函数为：

```text
O = ~I3 & I2 & (I1 ^ I0)
```

连接关系如下：

| 输出 | I3 | I2 | I1 | I0 | 还原表达式 |
| --- | --- | --- | --- | --- | --- |
| B[1] | D1 | EN | D2 | D3 | EN & ~D1 & (D2 ^ D3) |
| B[0] | D2 | EN | D3 | D1 | EN & ~D2 & (D3 ^ D1) |

因此综合网表与手算表达式一致。这里实际检查的是网表，没有在 GUI 中查看或截图。

查看 RTL 原理图：在 Vivado 工程中选择 RTL Analysis → Open Elaborated Design → Schematic。case 可能显示成译码和多路选择结构，外观不一定是手画的异或门结构，但功能应相同。

查看本次已综合的原理图：在 Vivado Tcl Console 中执行：

```tcl
open_checkpoint E:/hdl/encoder/verification/encoder_synth.dcp
show_schematic [get_cells -hierarchical]
```

## 引脚及实验板验证

已写入 `encoder.srcs/constrs_1/new/encoder.xdc` 并加入工程，采用题图引脚：

| 信号 | 板上器件 | FPGA 引脚 |
| --- | --- | --- |
| EN | SW3 | W17 |
| D[2] / D3 | SW2 | W16 |
| D[1] / D2 | SW1 | V16 |
| D[0] / D1 | SW0 | V17 |
| B[1] | LD1 | E19 |
| B[0] | LD0 | U16 |

本次未生成比特流、未下载到实验板，也未实际拨动开关验证。遵守不运行完整构建的要求，上板步骤留待实验操作：

1. 打开 encoder.xpr，确认顶层为 encoder、器件为 xc7a35tcpg236-1，约束已启用。若工程之前已打开，请重新打开以加载文件登记变更。
2. 在需要上板时手动完成实现和 Generate Bitstream。
3. 接通实验板电源和 JTAG，打开 Hardware Manager，连接目标，使用生成的 encoder.bit 执行 Program Device。
4. SW3=0 时，任意切换 SW2～SW0，LD1、LD0 均应熄灭。
5. SW3=1 时，SW2～SW0 为 001、010、100，LD1～LD0 分别显示 01、10、11。
6. SW3=1 时，SW2～SW0 为 000、011、101、110、111，两个 LED 均应熄灭。