#let ink = rgb("23383e")
#let muted = rgb("637277")
#let accent = rgb("28696b")
#let rule = rgb("cbd7d8")
#let title = "单层参数化码垛实验报告"
#let date = datetime.today()
#let id = "202400130242"
#let author = "彭靖轩"

#set document(title: title, author: author, date: date)
#set page(paper: "a4", margin: (x: 20mm, top: 18mm, bottom: 17mm))
#set text(
    font: ((name: "Lato", covers: "latin-in-cjk"), "Noto Serif CJK SC"),
    size: 11pt,
    lang: "zh",
    region: "cn",
    fill: ink,
)
#set par(justify: true, leading: 0.6em, spacing: 0.9em)
#set heading(numbering: "1.")
#show heading: set text(
    font: ((name: "Lato", covers: "latin-in-cjk"), "Noto Sans CJK SC"),
    size: 12pt,
    weight: "bold",
    fill: accent,
)
#show raw: set text(font: "JetBrains Mono")
#show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: .3em, y: 0em),
    outset: (x: 0em, y: .3em),
    radius: .2em,
)
#show raw.where(block: true): block.with(
    fill: rgb("f3f7f7"),
    stroke: (left: 1.5pt + accent),
    radius: 3pt,
    inset: (x: 12pt, y: 10pt),
    above: 0.7em,
    below: 0.7em,
)
#set table(stroke: none, inset: (x: 8pt, y: 4pt), align: center)
#show table.cell.where(y: 0): set text(
    font: ((name: "Lato", covers: "latin-in-cjk"), "Noto Sans CJK SC"),
    weight: "bold",
)

#text(font: ((name: "Lato", covers: "latin-in-cjk"), "Noto Sans CJK SC"), size: 22pt, weight: "bold", title)

#text(font: ((name: "Lato", covers: "latin-in-cjk"), "Noto Sans CJK SC"), size: 10pt, fill: muted)[
    学号 #id #h(1fr) 姓名 #author #h(1fr) 日期 #date.display("[year]-[month]-[day]")
]
#line(length: 100%, stroke: 0.7pt + accent)

= Slide

#table(
    columns: (1fr, 3fr),
    align: (left + horizon, left + horizon),
    table.hline(stroke: 0.6pt + accent),
    table.header([项目], [内容]),
    table.hline(stroke: 0.4pt + rule),
    [姓名 / 学号], [#author，#id],
    [实现内容],
    [任务：单层参数化码垛。在 DobotStudio Pro 中编写 Lua 程序驱动 MG400 完成 $N times M$ 阵列的全自动搬运；程序由取料阵列起点、放料阵列起点及行列间距自动推算每件工件的取、放坐标，经安全高度完成逐件吸附搬运。当前 $N = M = 2$，共执行 4 次取放。],
    [其他备注],
    [程序扩展性良好：修改顶部坐标、间距、行列数等参数即可适应不同阵列规格，无需逐点重新示教；运行前有完整参数校验，防止误操作。],
    table.hline(stroke: 0.6pt + accent),
)

= 任务与环境

项目要求由取料位置、托盘起点、行列数及间距自动生成 $N times M$ 个放置位置，减少逐点示教。@project

环境
- DOBOT MG400
- 气泵吸盘
- DobotStudio Pro 2.8.0
- Lua 5.3.5

= 点位生成

设行索引 $i = 0, dots, N - 1$，列索引 $j = 0, dots, M - 1$。取料阵列起点为 $(x_0, y_0, z_0)$，放料阵列起点为 $(x_p, y_p, z_p)$，则各工件的取、放位置为

$
    S_(i,j) & = (x_0 + j d_x, y_0 + i d_y, z_0), \
    T_(i,j) & = (x_p + j d_x, y_p + i d_y, z_p).
$

当前 $N = M = 2$，$d_x = d_y = -30 thin "mm"$，$z_0 = z_p = -125 thin "mm"$。

#table(
    columns: (0.6fr, 0.8fr, 1.4fr, 1.4fr),
    table.hline(stroke: 0.6pt + accent),
    table.header([顺序], [行、列], [取料 $(x, y)$ / mm], [放料 $(x, y)$ / mm]),
    table.hline(stroke: 0.4pt + rule),
    [1], [1，1], [$(290, -190)$], [$(260, 90)$],
    [2], [1，2], [$(260, -190)$], [$(230, 90)$],
    [3], [2，1], [$(290, -220)$], [$(260, 60)$],
    [4], [2，2], [$(260, -220)$], [$(230, 60)$],
    table.hline(stroke: 0.6pt + accent),
)

搬运平面高度取 $z_("safe") = max(z_0, z_p) + h$。设置 $h = 100 thin "mm"$，得到 $z_("safe") = -25 thin "mm"$；水平转移均在该高度进行，取放时垂直升降。

= 搬运流程

*准备* 电脑设为 `192.168.1.40`、子网掩码 `255.255.255.0`，连接 `192.168.1.6` 的机器人并使能，导入程序。

*执行* 程序检查行列数为正整数、多行或多列的对应间距非零，以及 $h > 0$；通过 ```lua GetPose()``` 保留当前用户坐标系、工具坐标系和末端转角。先关闭吸盘并移至搬运高度，再逐件执行“到取料点上方、下降吸附、抬升转移、下降释放、再次抬升”。```lua DO(9, ON)``` 吸附，```lua DO(9, OFF)``` 释放。

*控制* 全部运动使用 ```lua MovL```，设置 ```lua CP=0```、```lua SYNC=1```，使各段运动完成后再执行后续指令；```lua SpeedL=10```、```lua AccL=10``` 为速度与加速度比例。吸附和释放后均调用 ```lua Wait(1)```。@dobot

= 分析与结论

由参数可推得四组取放点及其执行顺序，末次释放后停在 $(230, 60, -25) thin "mm"$，吸盘关闭。点位生成与取放动作分离后，调整起点、间距及行列数即可改变阵列布局，无需逐点编写轨迹。

= 程序

== 代码

#raw(lang: "lua", read("../src/src0.lua"), block: true)

== 解释

=== 参数区

```lua
local x0, y0, z0 = 290, -190, -125
local xp, yp, zp = 260, 90, -125
local dx, dy = -30, -30
local N, M = 2, 2
local h = 100
```

集中声明所有可调参数：$(x_0, y_0, z_0)$ 为取料阵列首件坐标，$(x_p, y_p, z_p)$ 为放料阵列首件坐标，$d_x, d_y$ 为列、行方向间距，$N, M$ 为行数与列数，$h$ 为安全高度裕量。

=== 初始化与安全高度

```lua
local start = GetPose()
local r = start.coordinate[4]
local zSafe = math.max(z0, zp) + h
local function move(x, y, z)
    MovL({ coordinate = { x, y, z, r }, user = start.user, tool = start.tool },
         { CP = 0, SpeedL = 10, AccL = 10, SYNC = 1 })
end
```

`GetPose()` 读取机器人当前末端姿态，保留用户坐标系（`user`）、工具坐标系（`tool`）和末端绕 $z$ 轴的旋转角 `r`，之后所有运动沿用这三项，确保搬运全程保持固定姿态。`zSafe` 取两阵列 $z$ 坐标的较大值再加裕量 $h$，使水平移动时末端始终高于两侧工件顶面。内部函数 `move` 封装 `MovL`，`CP=0` 要求到点后速度降为零，`SYNC=1` 阻塞至动作完成再返回。

=== 运动控制与 IO

```lua
DO(9, OFF)
move(start.coordinate[1], start.coordinate[2], zSafe)
for row = 0, N - 1 do
    for col = 0, M - 1 do
        local sx, sy = x0 + col * dx, y0 + row * dy
        local tx, ty = xp + col * dx, yp + row * dy
        move(sx, sy, zSafe)
        move(sx, sy, z0)
        DO(9, ON)
        Wait(1)
        move(sx, sy, zSafe)
        move(tx, ty, zSafe)
        move(tx, ty, zp)
        DO(9, OFF)
        Wait(1)
        move(tx, ty, zSafe)
    end
end
```

启动前先关闭吸盘并升至安全高度。双层循环按行优先顺序遍历 $N times M$ 个工件，每次由起点坐标加偏移量计算当前件的取料点 $(s_x, s_y)$ 和放料点 $(t_x, t_y)$。单件搬运序列：移至取料点正上方 $arrow.r$ 下降至 $z_0$ $arrow.r$ 吸附并等待 $1 thin "s"$ $arrow.r$ 抬升至安全高度 $arrow.r$ 平移至放料点正上方 $arrow.r$ 下降至 $z_p$ $arrow.r$ 释放并等待 $1 thin "s"$ $arrow.r$ 抬升。等待时间用于让气压稳定、确认吸附/释放完成。

= 实现效果

实验在 DobotStudio Pro 中运行程序，机器人 MG400 在正确 IP 和使能状态下完成了全部 4 次搬运。程序按行优先顺序依次执行，取放坐标与预期完全一致；吸盘在每次取放后均稳定吸附和释放，工件未发生掉落或偏移。搬运全程在安全高度以上进行水平移动，各路径之间无碰撞。末次搬运完成后机器人悬停在放料区最后一件正上方，吸盘关闭，控制台打印"搬运完成"。

= 思考

*机器人型号与自由度* DOBOT MG400 为四自由度串联机械臂，具有三个旋转关节和一个末端旋转关节（SCARA 构型），适合平面取放作业；气泵吸盘作为末端执行器，通过数字输出口 DO\_09 控制。

*涉及的知识点* 任务综合运用了运动学正逆解（`MovL` 直线插补）、坐标变换（阵列点位由起点和偏移量推算）、末端执行器控制（IO 控制吸盘）、运动参数设置（速度、加速度、同步模式）以及程序结构（循环、函数封装、参数校验）等内容。

*扩展性* 参数化设计使程序与具体阵列配置解耦：只需修改顶部六组数值即可适应不同尺寸的码垛任务，行列数 $N, M$ 可任意扩展，间距支持正负方向，安全高度可按实际工件高度调整。若需支持多层码垛，只需在外层增加一层 $z$ 偏移的循环，核心运动逻辑无需改动。

#pagebreak()
#bibliography("ref.bib", title: [参考文献], style: "gb-7714-2015-numeric")
