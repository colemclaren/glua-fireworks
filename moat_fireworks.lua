moat_fireworks = {}
local mf = moat_fireworks
mf.fireworks = {}
mf.peak = {min = 2, max = 5}
mf.particlepeak = {min = -40, max = 40}
mf.fireworkamt = {min = 70, max = 100}
mf.speed = 4
mf.particlespeed = 10
mf.color = Color(255, 255, 255)
mf.size = 6
mf.particlesize = 2
mf.explosionsize = 150

function mf.newfirework(p, x, y)
    local firework = {}
    firework.pos = {x, y, {}}
    firework.peak = math.Rand(mf.peak.min, mf.peak.max)
    firework.particlesize = math.random(40, mf.explosionsize)
    firework.particlenum = firework.particlesize
    firework.particles = {}
    firework.color = HSVToColor(math.random(360), 1, 1)
    firework.peaked = false
    table.insert(mf.fireworks, firework)
end

function mf.newparticle(f, x, y)
    local particle = {}
    local a = math.rad(math.random(360))
    particle.pos = {x, y, math.sin(a) * math.random(10, f.particlesize), math.cos(a) * math.random(10, f.particlesize)}
    particle.peaked = false
    table.insert(f.particles, particle)
end

mf.frame = vgui.Create("DFrame")
mf.frame:SetSize(1000, 800)
mf.frame:Center()
mf.frame:MakePopup()
mf.frame:SetTitle("Firework Test")
mf.panel = vgui.Create("DPanel", mf.frame)
mf.panel:Dock(FILL)
mf.panel.tall = mf.panel:GetTall()
mf.panel.wide = mf.panel:GetWide()

mf.panel.Paint = function(s, w, h)
    surface.SetDrawColor(51, 51, 51)
    surface.DrawRect(0, 0, w, h)

    for k, v in pairs(mf.fireworks) do
        if (not v.peaked) then
            draw.RoundedBox(mf.size / 2, v.pos[1], v.pos[2], mf.size, mf.size, v.color)
        else
            local part = v.particles

            for i = 1, #part do
                draw.RoundedBox(mf.particlesize/2, part[i].pos[1], part[i].pos[2], mf.particlesize, mf.particlesize, v.color)
            end
        end
    end
end

mf.panel.Think = function(s)
    if (math.random(0, 100) < 0.01 and #mf.fireworks <= 5) then
        mf.newfirework(s, math.random(0, s:GetWide()), s:GetTall() + 5)
    end

    for k, v in pairs(mf.fireworks) do
        if (v.color.a < 0) then
            table.remove(mf.fireworks, k)
            continue
        end

        if (not v.peaked) then
            v.pos[2] = Lerp(mf.speed * FrameTime(), v.pos[2], s:GetTall() / v.peak)
        else
            if (v.particlenum ~= #v.particles) then
                for i = 1, v.particlenum do
                    mf.newparticle(v, v.pos[1], v.pos[2])
                end
            else
                local part = v.particles

                for i = 1, v.particlenum do
                    if (part[i].peaked) then
                        part[i].pos[2] = part[i].pos[4] + v.pos[2]
                        part[i].pos[1] = part[i].pos[3] + v.pos[1]
                    else
                        if (part[i].pos[1] >= part[i].pos[3] + v.pos[1]) and (part[i].pos[2] >= part[i].pos[4] + v.pos[2]) then
                            part[i].peaked = true
                        else
                            part[i].pos[2] = Lerp(mf.particlespeed * FrameTime(), part[i].pos[2], part[i].pos[4] + v.pos[2])
                            part[i].pos[1] = Lerp(mf.particlespeed * FrameTime(), part[i].pos[1], part[i].pos[3] + v.pos[1])
                        end
                    end
                end
            end

            v.color.a = v.color.a - 2
            v.pos[2] = v.pos[2] + 0.5
        end

        if (v.pos[2] <= ((s:GetTall() / v.peak) + 5)) then
            v.peaked = true
        end
    end
end