#let ink = rgb("23383e")
#let muted = rgb("637277")
#let accent = rgb("28696b")
#let rule = rgb("cbd7d8")
#let id = "202400130242"
#let author = "彭靖轩"

#set document(title: "单层参数化码垛", author: author)
#set page(
    paper: "presentation-16-9",
    margin: (x: 36pt, top: 28pt, bottom: 24pt),
    fill: white,
)
#set text(
    font: ((name: "Lato", covers: "latin-in-cjk"), "Noto Sans CJK SC"),
    size: 15pt,
    lang: "zh",
    region: "cn",
    fill: ink,
)
#set par(leading: 0.55em, spacing: 0.75em)

#block(width: 100%)[
    #text(size: 22pt, weight: "bold", fill: accent)[单层参数化码垛]
    #h(1fr)
    #text(size: 13pt, fill: muted)[#id #h(0.6em) #author]
]
#line(length: 100%, stroke: 1pt + accent)
#v(6pt)

#grid(
    columns: (1fr, 1.6fr, 1fr),
    column-gutter: 22pt,

    [
        #text(weight: "bold", fill: accent)[姓名 / 学号]
        #v(4pt)
        #text(fill: muted, size: 13pt)[
            #author \
            #id
        ]
    ],

    [
        #text(weight: "bold", fill: accent)[实现内容]
        #v(4pt)
        #text(size: 13pt)[
            任务：单层参数化码垛
        ]
        #v(3pt)
        #text(size: 12.5pt)[
            在 DobotStudio Pro 中编写 Lua 程序，驱动 MG400 完成
            $N times M$ 阵列的全自动搬运。程序从取料阵列起点
            $(x_0, y_0, z_0)$ 和放料阵列起点 $(x_p, y_p, z_p)$
            按行列间距 $(d_x, d_y)$ 自动推算每件工件的取、放坐标，
            经由安全高度 $z_"safe" = max(z_0, z_p) + h$ 完成逐件吸附搬运。
            当前 $N = M = 2$，共执行 4 次取放，最终实现 2 × 2 阵列从取料区到放料区的搬运。
        ]
    ],

    [
        #text(weight: "bold", fill: accent)[其他备注]
        #v(4pt)
        #text(size: 12.5pt)[
            程序具备良好扩展性：修改顶部的 `x0`、`y0`、`z0`、`xp`、`yp`、`zp`、`dx`、`dy`、`N`、`M`
            六组参数即可适应不同阵列规格，无需逐点重新示教。
            运行前有完整参数校验（行列数为正整数、间距非零、安全高度合法），防止误操作。
        ]
    ],
)
