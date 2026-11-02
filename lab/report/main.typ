#let ink = rgb("23383e")
#let muted = rgb("637277")
#let accent = rgb("28696b")
#let rule = rgb("cbd7d8")
#let sans = ("Lato", "Noto Sans CJK SC")
#let title = "单层参数化码垛实验报告"
#let date = datetime.today()
#let id = "202400130242"
#let author = "彭靖轩"

#set document(title: title, author: author, date: date)
#set page(paper: "a4", margin: (x: 20mm, top: 18mm, bottom: 17mm))
#set text(font: ("Lato", "Noto Serif CJK SC"), size: 10.5pt, lang: "zh", fill: ink)
#set par(justify: true, leading: 0.6em, spacing: 0.9em)
#set heading(numbering: "1.")
#show heading: set text(font: sans, size: 12.5pt, weight: "bold", fill: accent)
#show heading: set block(above: 1.1em, below: 0.6em)
#show math.equation: set text(font: "Libertinus Math")
#show math.equation.where(block: true): set block(above: 0.5em, below: 0.5em)
#show raw: set text(font: ("Lato", "Noto Sans CJK SC"), size: 0.93em)
#show raw.where(block: true): set text(font: ("JetBrains Mono", "Noto Sans CJK SC"), size: 8.5pt)
#show raw.where(block: true): set par(leading: 0.5em)
#show raw.where(block: true): set block(
    fill: rgb("f3f7f7"),
    stroke: (left: 1.5pt + accent),
    radius: 3pt,
    inset: (x: 12pt, y: 10pt),
    above: 0.7em,
    below: 0.7em,
)
#set table(stroke: none, inset: (x: 8pt, y: 4pt), align: center)
#show table.cell.where(y: 0): set text(font: sans, weight: "bold")

#text(font: sans, size: 21pt, weight: "bold", title)
#v(6pt)
#text(font: sans, size: 9pt, fill: muted)[
    学号 #id #h(1fr) 姓名 #author #h(1fr) 日期 #date.display("[year]-[month]-[day]")
]
#v(5pt)
#line(length: 100%, stroke: 0.7pt + accent)

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

*执行* 程序检查行列数为正整数、多行或多列的对应间距非零，以及 $h > 0$；通过 `GetPose()` 保留当前用户坐标系、工具坐标系和末端转角。先关闭吸盘并移至搬运高度，再逐件执行“到取料点上方、下降吸附、抬升转移、下降释放、再次抬升”。`DO(9, ON)` 吸附，`DO(9, OFF)` 释放。

*控制* 全部运动使用 `MovL`，设置 `CP=0`、`SYNC=1`，使各段运动完成后再执行后续指令；`SpeedL=10`、`AccL=10` 为速度与加速度比例。吸附和释放后均调用 `Wait(1)`。@dobot

= 分析与结论

由参数可推得四组取放点及其执行顺序，末次释放后停在 $(230, 60, -25) thin "mm"$，吸盘关闭。点位生成与取放动作分离后，调整起点、间距及行列数即可改变阵列布局，无需逐点编写轨迹。

= 代码

#raw(lang: "lua", read("../src/src0.lua"), block: true)

#pagebreak()
#bibliography("ref.bib", title: [参考文献], style: "gb-7714-2015-numeric")
