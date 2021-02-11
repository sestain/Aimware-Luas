local rb_ref = gui.Reference("VISUALS")
local tab = gui.Tab(rb_ref, "thirdperson", "Thirdperson")
local gb_r = gui.Groupbox(tab, "Thirdperson", 15, 15, 250, 400)
local thirdperson_slider = gui.Slider(gb_r, "thirdperson_slider", "Thirdperson distance", 150, 0, 500)
local thirdperson = gui.GetValue("esp.local.thirdperson")
local thirdperson_dist = gui.GetValue("esp.local.thirdpersondist")
local distance = 0

function on_paint()
    local screen_width, screen_height = draw.GetScreenSize()
    local scx, scy = screen_width * 0.5, screen_height * 0.5
 
    local_player = entities.GetLocalPlayer()

    if local_player == nil then 
        return
    end
     
    if not entities.GetLocalPlayer():IsAlive() then
        return
    end

    local multiplier = (1.0 / 0.2) * globals.FrameTime()

    if gui.GetValue("esp.local.thirdperson") then
        if distance < 1.0 then
            distance = ( distance + ( multiplier * ( 1 - distance ) ) )
        end
    else
        distance = 0
    end

    if distance >= 1.0 then
        distance = 1
    end

    if gui.GetValue("esp.local.thirdperson") then
        gui.SetValue("esp.local.thirdpersondist", (gui.GetValue("esp.thirdperson.thirdperson_slider") * distance))
    end
end

callbacks.Register("Draw", on_paint)