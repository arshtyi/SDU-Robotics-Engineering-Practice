local x0, y0, z0 = 290, -190, -125
local xp, yp, zp = 260, 90, -125 -- 目前来看无所谓
local dx, dy = -30, -30 -- 需要进一步考虑，尤其在释放时可能造成碰撞
local N, M = 2, 2 -- 暂定
local h = 100

assert(x0 and y0 and z0 and xp and yp and zp and dx and dy and N and M, "请先填写顶部的坐标、间距和行列数")
assert(N >= 1 and N % 1 == 0 and M >= 1 and M % 1 == 0, "行数、列数必须为正整数")
assert((M == 1 or dx ~= 0) and (N == 1 or dy ~= 0) and h > 0, "多行/多列的间距不能为零，抬升高度必须大于零")

local start = GetPose()
local r = start.coordinate[4]
local zSafe = math.max(z0, zp) + h
local function move(x, y, z)
    MovL({ coordinate = { x, y, z, r }, user = start.user, tool = start.tool }, { CP = 0, SpeedL = 10, AccL = 10, SYNC = 1 })
end

DO(9, OFF)
move(start.coordinate[1], start.coordinate[2], zSafe)
for row = 0, N - 1 do
    for col = 0, M - 1 do
        local sx, sy = x0 + col * dx, y0 + row * dy
        local tx, ty = xp + col * dx, yp + row * dy
        print(string.format("搬运 %d/%d：第 %d 行，第 %d 列", row * M + col + 1, N * M, row + 1, col + 1))
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
print("搬运完成")
