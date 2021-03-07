--[[
# DON'T BE A DICK PUBLIC LICENSE

> Version 1.1, December 2016

> Copyright (C) [2020] [Sestain]

Everyone is permitted to copy and distribute verbatim or modified
copies of this license document.

> DON'T BE A DICK PUBLIC LICENSE
> TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

1. Do whatever you like with the original work, just don't be a dick.

   Being a dick includes - but is not limited to - the following instances:

 1a. Outright copyright infringement - Don't just copy this and change the name.
 1b. Selling the unmodified original with no work done what-so-ever, that's REALLY being a dick.
 1c. Modifying the original work to contain hidden harmful content. That would make you a PROPER dick.

2. If you become rich through modifications, related works/services, or supporting the original work,
share the love. Only a dick would make loads off this work and not buy the original work's
creator(s) a pint.

3. Code is provided with no warranty. Using somebody else's code and bitching when it goes wrong makes
you a DONKEY dick. Fix the problem yourself. A non-dick would submit the fix back.
]]

local SCRIPT_FILE_NAME = GetScriptName()
local SCRIPT_FILE_ADDR = "https://raw.githubusercontent.com/Sestain/Aimware-Luas/master/Sestains%20Script/Sestains%20Script.lua"
local VERSION_FILE_ADDR = "https://raw.githubusercontent.com/sestain/Aimware-Luas/master/Sestains%20Script/version.txt"
local VERSION_NUMBER = "1.3"
local version_check_done = false
local update_downloaded = false
local update_available = false
local up_to_date = false
local updaterfont1 = draw.CreateFont("Bahnschrift", 18)
local updaterfont2 = draw.CreateFont("Bahnschrift", 14)
local updateframes = 0
local fadeout = 0
local spacing = 0
local fadein = 0

callbacks.Register( "Draw", "handleUpdates", function()
	if updateframes < 5.5 then
		if up_to_date or updateframes < 0.25 then
			updateframes = updateframes + globals.AbsoluteFrameTime()
			if updateframes > 5 then
				fadeout = ((updateframes - 5) * 510)
			end
			if updateframes > 0.1 and updateframes < 0.25 then
				fadein = (updateframes - 0.1) * 4500
			end
			if fadein < 0 then fadein = 0 end
			if fadein > 650 then fadein = 650 end
			if fadeout < 0 then fadeout = 0 end
			if fadeout > 255 then fadeout = 255 end
		end
		if updateframes >= 0.25 then fadein = 650 end
		for i = 0, 600 do
			local alpha = 200-i/3 - fadeout
			if alpha < 0 then alpha = 0 end
			draw.Color(15,15,15,alpha)
			draw.FilledRect(i - 650 + fadein, 0, i+1 - 650 + fadein, 30)
			draw.Color(255, 150, 75,alpha)
			draw.FilledRect(i - 650 + fadein, 30, i+1 - 650 + fadein, 31)
		end
		draw.SetFont(updaterfont1)
		draw.Color(255,150,75,255 - fadeout)
		draw.Text(7 - 650 + fadein, 7, "Sestain's")
		draw.Color(225,225,225,255 - fadeout)
		draw.Text(7 + draw.GetTextSize("Sestain's ") - 650 + fadein, 7, "Script")
		draw.Color(255,150,75,255 - fadeout)
		draw.Text(7 + draw.GetTextSize("Sestain's Script  ") - 650 + fadein, 7, "\\")
		spacing = draw.GetTextSize("Sestain's Script  \\  ")
		draw.SetFont(updaterfont2)
		draw.Color(225,225,225,255 - fadeout)
	end

    if (update_available and not update_downloaded) then
		draw.Text(7 + spacing - 650 + fadein, 9, "Downloading latest version.")
        local new_version_content = http.Get(SCRIPT_FILE_ADDR);
        local old_script = file.Open(SCRIPT_FILE_NAME, "w");
        old_script:Write(new_version_content);
        old_script:Close();
        update_available = false
        update_downloaded = true
	end
	
    if (update_downloaded) and updateframes < 5.5 then
		draw.Text(7 + spacing - 650 + fadein, 9, "Update available, please reload the script.")
    end

    if (not version_check_done) then
        version_check_done = true
		local version = http.Get(VERSION_FILE_ADDR)
		version = string.gsub(version, "\n", "")
		if (version ~= VERSION_NUMBER) then
            update_available = true
		else 
			up_to_date = true
		end
	end
	
	if up_to_date and updateframes < 5.5 then
		draw.Text(7 + spacing - 650 + fadein, 9, "Successfully loaded latest version: v" .. VERSION_NUMBER)
	end
end)



local w, h = draw.GetScreenSize()
local x = w/2
local y = h/2
local current_angle = 0
local drawLeft = 0
local drawRight = 0
local drawBack = 0
local in_act_sr = false;
local next_tick_should_fakelag = true;

local old_lby_offset = gui.GetValue("rbot.antiaim.base.lby")
local old_rotation_offset = gui.GetValue("rbot.antiaim.base.rotation")

local rb_ref = gui.Reference("Ragebot")
local tab = gui.Tab(rb_ref, "sestain", "Sestain's Script")
local gb_r = gui.Groupbox(tab, "Anti-Aim", 15, 15, 250, 400)
local gb_r2 = gui.Groupbox(tab, "Indicators & Other", 280, 15, 335, 400)

local safe_revolver = gui.Checkbox(gb_r2, "safe_revolver", "Safe Revolver", false)
local antionshot = gui.Checkbox(gb_r2, "antionshot", "Anti Onshot", false)
local desync_indicator = gui.Checkbox(gb_r2, "desync_indicator", "Desync Indicator", 1)
local desync_indicator_rgb = gui.Checkbox(desync_indicator, "rgb", "rgb", 0)
local desync_position_z = gui.Slider(gb_r2, "desync_z", "Desync Indicator's Z Position", y, 0, h)
local desync_bgcp = gui.ColorPicker(desync_indicator, "desync_bgclr", "Desync Indicator's Background Color", 0,0,0,128)
local desync_icp = gui.ColorPicker(desync_indicator, "desync_iclr", "Desync Indicator's Indicator Color", 0,135,206,235)
local manual_indicator = gui.Checkbox(gb_r2, "manual_indicator", "Manual AA Indicator", 0)
local manual_indicator_rgb = gui.Checkbox(manual_indicator, "rgb", "rgb", 0)
local manual_position_z = gui.Slider(gb_r2, "manual_z", "Manual AA Indicator's Z Position", h/1.25, 0, h)
local manual_bgcp = gui.ColorPicker(manual_indicator, "manual_bgclr", "Manual AA Indicator's Background Color", 0,0,0,128)
local manual_icp = gui.ColorPicker(manual_indicator, "manual_iclr", "Manual AA Indicator's Indicator Color", 235,235,235,235)

local enabled = gui.Checkbox(gb_r, "enabled", "Enable", true)
local legitaa = gui.Checkbox(gb_r, "legitaa", "Legit AA on E", false)
local invert_key = gui.Keybox(gb_r, "ikey", "Invert Key", 0)
local left_key = gui.Keybox(gb_r, "left", "Manual AA to Left", 37)
local back_key = gui.Keybox(gb_r, "back", "Manual AA to Backwards", 40)
local right_key = gui.Keybox(gb_r,"right","Manual AA to Right", 39)
local rotation_angle = gui.Slider(gb_r, "rotationangle", "Rotation Offset", old_rotation_offset, -58, 58)
local lby_angle = gui.Slider(gb_r, "lbyangle", "LBY Offset", old_lby_offset, -180, 180)

desync_indicator:SetDescription("Shows which side your anti-aim desync is with an arrow")
desync_position_z:SetDescription("Changes desync Indicator's height")
manual_indicator:SetDescription("Shows where Manual Anti-Aim is set with an arrow")
manual_position_z:SetDescription("Changes Manual AA Indicator's height")
safe_revolver:SetDescription("R8 Revolver shouldn't shoot ground anymore")
antionshot:SetDescription("This is useful in MM (Desyncs while shooting)")
invert_key:SetDescription("Key used to invert Anti-Aim")

desync_indicator_rgb:SetInvisible(true)
manual_indicator_rgb:SetInvisible(true)

callbacks.Register( "weapon_fire", "fire", function()
	if gui.GetValue("rbot.sestain.enabled") == true then
		if not entities.GetLocalPlayer() then return end
		if not entities.GetLocalPlayer():IsAlive() then return end
		
		local ent = Entity.GetEntityFromUserID(Event.GetInt("userid"))
    	if (ent ~= Entity.GetLocalPlayer()) then return end
    	next_tick_should_fakelag = false
	end
end)

callbacks.Register( "CreateMove", "cM", function()
	if gui.GetValue("rbot.sestain.enabled") == true then
		if not entities.GetLocalPlayer() then return end
		if not entities.GetLocalPlayer():IsAlive() then return end

		if gui.GetValue("rbot.sestain.antionshot") == true then
			if gui.GetValue("rbot.master") == true then
    			gui.SetValue("misc.fakelag.enable", true)
    			if not (next_tick_should_fakelag) then
    			    gui.SetValue("misc.fakelag.enable", false)
    			    next_tick_should_fakelag = true
				end
			end
		end
	end
end)

callbacks.Register( "CreateMove", "create_move", function()
	if gui.GetValue("rbot.sestain.enabled") == true then
		if not entities.GetLocalPlayer() then return end
		if not entities.GetLocalPlayer():IsAlive() then return end

		local WeaponID = entities.GetLocalPlayer():GetWeaponID();

		if gui.GetValue("rbot.sestain.safe_revolver") == true then
			if gui.GetValue("rbot.master") == true then
    			if (WeaponType == 0 and WeaponID == 36) then
    			    in_act_sr = Math.round(1 / Globals.Frametime()) < 65 == true or false
    			    gui.SetValue("misc.fakelag.enable", Math.round(1 / Globals.Frametime()) < 65 == false or true)
    			else
    			    in_act_sr = false
    			    gui.SetValue("misc.fakelag.enable", true)
				end
			end
		end
	end
end)

callbacks.Register( "Draw", "Antiaim", function()
	if gui.GetValue("rbot.sestain.enabled") == true then
		if invert_key:GetValue() ~= 0 then
			if input.IsButtonPressed(invert_key:GetValue()) then
				current_angle = current_angle == 0 and 1 or 0;
			end
		end

		if left_key:GetValue() ~= 0 then
			if input.IsButtonPressed(left_key:GetValue()) then
				drawLeft = drawLeft == 0 and 1 or 0;
				drawBack = 0
				drawRight = 0
				if drawLeft == 0 then
					gui.SetValue("rbot.antiaim.base", 180)
				elseif drawLeft == 1 then
					gui.SetValue("rbot.antiaim.base", 90)
				end
			end
		end

		if back_key:GetValue() ~= 0 then
			if input.IsButtonPressed(back_key:GetValue()) then
				drawLeft = 0
				drawBack = drawBack == 0 and 1 or 0;
				drawRight = 0
				if drawBack == 0 then
					gui.SetValue("rbot.antiaim.base", 180)
				elseif drawBack == 1 then
					gui.SetValue("rbot.antiaim.base", 180)
				end
			end
		end

		if right_key:GetValue() ~= 0 then
			if input.IsButtonPressed(right_key:GetValue()) then
				drawLeft = 0
				drawBack = 0
				drawRight = drawRight == 0 and 1 or 0;
				if drawRight == 0 then
					gui.SetValue("rbot.antiaim.base", 180)
				elseif drawRight == 1 then
					gui.SetValue("rbot.antiaim.base", -90)
				end
			end
		end

		if current_angle ~= 2 then
			local lby = current_angle == 0 and -lby_angle:GetValue() or lby_angle:GetValue()
			local rotation = current_angle == 0 and -rotation_angle:GetValue() or rotation_angle:GetValue()
			lby = 0 and -lby or lby
			rotation = 0 and -rotation or rotation
			gui.SetValue("rbot.antiaim.base.lby", lby)
			gui.SetValue("rbot.antiaim.base.rotation", rotation)
		else
			gui.SetValue("rbot.antiaim.base.lby", -lby)
			gui.SetValue("rbot.antiaim.base.rotation", -rotation)
		end
	end
end)

callbacks.Register( "Draw", "DesyncIndicator", function()
	if not entities.GetLocalPlayer() then return end
	
	local desync_bgr, desync_bgg, desync_bgb, desync_bga = desync_bgcp:GetValue()
	local desync_ir, desync_ig, desync_ib, desync_ia = desync_icp:GetValue()
	
	if gui.GetValue("rbot.sestain.desync_indicator") == true then
		if gui.GetValue("rbot.master") == true then
			if current_angle == 0 then 
				draw.Color(desync_ir, desync_ig, desync_ib, desync_ia)
				draw.Triangle(x + 55, desync_position_z:GetValue(), x + 35, desync_position_z:GetValue() + 10, x + 35, desync_position_z:GetValue() - 10)
				draw.Color(desync_bgr, desync_bgg, desync_bgb, desync_bga)
				draw.Triangle(x - 35, desync_position_z:GetValue() - 10, x - 35, desync_position_z:GetValue() + 10, x - 55, desync_position_z:GetValue())
			elseif current_angle == 1 then 
				draw.Color(desync_ir, desync_ig, desync_ib, desync_ia)
				draw.Triangle(x - 35, desync_position_z:GetValue() - 10, x - 35, desync_position_z:GetValue() + 10, x - 55, desync_position_z:GetValue())
				draw.Color(desync_bgr, desync_bgg, desync_bgb, desync_bga)
				draw.Triangle(x + 55, desync_position_z:GetValue(), x + 35, desync_position_z:GetValue() + 10, x + 35, desync_position_z:GetValue() - 10)
			end
		end
	end
end)

callbacks.Register( "Draw", "ManualIndicator", function()
	if not entities.GetLocalPlayer() then return end
	
	local manual_bgr, manual_bgg, manual_bgb, manual_bga = manual_bgcp:GetValue()
	local manual_ir, manual_ig, manual_ib, manual_ia = manual_icp:GetValue()
	
	if gui.GetValue("rbot.sestain.manual_indicator") == true then
		if gui.GetValue("rbot.master") == true then
			if drawLeft == 0 then
				draw.Color(manual_bgr, manual_bgg, manual_bgb, manual_bga)
				draw.Triangle(x - 50, manual_position_z:GetValue() + 10, x - 70, manual_position_z:GetValue(), x - 50, manual_position_z:GetValue() - 10)
			elseif drawLeft == 1 then
				draw.Color(manual_ir, manual_ig, manual_ib, manual_ia)
				draw.Triangle(x - 50, manual_position_z:GetValue() + 10, x - 70, manual_position_z:GetValue(), x - 50, manual_position_z:GetValue() - 10)
			end
		
			if drawBack == 0 then
				draw.Color(manual_bgr, manual_bgg, manual_bgb, manual_bga)
				draw.Triangle(x - 10, manual_position_z:GetValue() + 50, x + 10, manual_position_z:GetValue() + 50, x, manual_position_z:GetValue() + 70)
			elseif drawBack == 1 then
				draw.Color(manual_ir, manual_ig, manual_ib, manual_ia)
				draw.Triangle(x - 10, manual_position_z:GetValue() + 50, x + 10, manual_position_z:GetValue() + 50, x, manual_position_z:GetValue() + 70)
			end
			
			if drawRight == 0 then
				draw.Color(manual_bgr, manual_bgg, manual_bgb, manual_bga)
				draw.Triangle(x + 50, manual_position_z:GetValue() - 10, x + 70, manual_position_z:GetValue(), x + 50, manual_position_z:GetValue() + 10)
			elseif drawRight == 1 then
				draw.Color(manual_ir, manual_ig, manual_ib, manual_ia)
				draw.Triangle(x + 50, manual_position_z:GetValue() - 10, x + 70, manual_position_z:GetValue(), x + 50, manual_position_z:GetValue() + 10)
			end
		end
	end
end)

local saved = false
local saved_values = {
   	["rbot.antiaim.base"] = gui.GetValue("rbot.antiaim.base"),
    ["rbot.antiaim.advanced.autodir.edges"] = gui.GetValue("rbot.antiaim.advanced.autodir.edges"),
    ["rbot.antiaim.advanced.autodir.targets"] = gui.GetValue("rbot.antiaim.advanced.autodir"),
    ["rbot.antiaim.advanced.pitch"] = gui.GetValue("rbot.antiaim.advanced.pitch"),
    ["rbot.antiaim.condition.use"] = gui.GetValue("rbot.antiaim.condition.use")
}

callbacks.Register( "CreateMove", function(cmd)
	if gui.GetValue("rbot.sestain.enabled") == true then
		if not legitaa:GetValue() or bit.band(cmd.buttons, bit.lshift(1, 5)) == 0 then
			if saved then
				for i, v in next, saved_values do
					gui.SetValue(i, v)
				end
				saved = false
			end
		return end
	
		if not cmd.sendpacket then return end
	
		if not saved then
			for i, v in next, saved_values do
				saved_values[i] = gui.GetValue(i)
			end
			saved = true
		end

    	gui.SetValue("rbot.antiaim.condition.use", 0)
    	gui.SetValue("rbot.antiaim.advanced.pitch", 0)
    	gui.SetValue("rbot.antiaim.advanced.autodir.edges", 0)
    	gui.SetValue("rbot.antiaim.advanced.autodir.targets", 0)
    	gui.SetValue("rbot.antiaim.base", [[0 "Desync"]])
	end
end)



local function gui_set_invisible()
    local desync_indicator = desync_indicator:GetValue()
    local manual_indicator = manual_indicator:GetValue()

    desync_bgcp:SetInvisible(not desync_indicator)
	desync_icp:SetInvisible(not desync_indicator)
	
    manual_bgcp:SetInvisible(not manual_indicator)
	manual_icp:SetInvisible(not manual_indicator)

	desync_position_z:SetInvisible(desync_indicator == false)
	manual_position_z:SetInvisible(manual_indicator == false)
end

local function gui_set_disabled()
	if gui.GetValue("rbot.sestain.enabled") == false then
		safe_revolver:SetDisabled(true)
		antionshot:SetDisabled(true)
		desync_indicator:SetDisabled(true)
		desync_indicator_rgb:SetDisabled(true)
		desync_position_z:SetDisabled(true)
		desync_bgcp:SetDisabled(true)
		desync_icp:SetDisabled(true)
		manual_indicator:SetDisabled(true)
		manual_indicator_rgb:SetDisabled(true)
		manual_position_z:SetDisabled(true)
		manual_bgcp:SetDisabled(true)
		manual_icp:SetDisabled(true)
		invert_key:SetDisabled(true)
		left_key:SetDisabled(true)
		back_key:SetDisabled(true)
		right_key:SetDisabled(true)
		rotation_angle:SetDisabled(true)
		lby_angle:SetDisabled(true)
		legitaa:SetDisabled(true)
	else
		safe_revolver:SetDisabled(false)
		antionshot:SetDisabled(false)
		desync_indicator:SetDisabled(false)
		desync_indicator_rgb:SetDisabled(false)
		desync_position_z:SetDisabled(false)
		desync_bgcp:SetDisabled(false)
		desync_icp:SetDisabled(false)
		manual_indicator:SetDisabled(false)
		manual_indicator_rgb:SetDisabled(false)
		manual_position_z:SetDisabled(false)
		manual_bgcp:SetDisabled(false)
		manual_icp:SetDisabled(false)
		invert_key:SetDisabled(false)
		left_key:SetDisabled(false)
		back_key:SetDisabled(false)
		right_key:SetDisabled(false)
		rotation_angle:SetDisabled(false)
		lby_angle:SetDisabled(false)
		legitaa:SetDisabled(false)
	end
end

callbacks.Register("Draw", function()
    gui_set_invisible()
	gui_set_disabled()
end)