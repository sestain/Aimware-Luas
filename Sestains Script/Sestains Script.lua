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

local SCRIPT_FILE_NAME = GetScriptName();
local SCRIPT_FILE_ADDR = "https://raw.githubusercontent.com/Sestain/Aimware-Luas/master/Sestains%20Script/Sestains%20Script.lua";
local VERSION_FILE_ADDR = "https://raw.githubusercontent.com/Sestain/Aimware-Luas/master/Sestains%20Script/version.txt";
local VERSION_NUMBER = "1.421";
local version_check_done = false;
local update_downloaded = false;
local update_available = false;
local up_to_date = false;
local updaterfont1 = draw.CreateFont("Bahnschrift", 18);
local updaterfont2 = draw.CreateFont("Bahnschrift", 14);
local updateframes = 0;
local fadeout = 0;
local spacing = 0;
local fadein = 0;

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


--Variables, Values and a function for fps
local w, h = draw.GetScreenSize();
local x = w/2;
local y = h/2;
local current_angle = 0;
local drawLeft = 0;
local drawBack = 0;
local drawRight = 0;
local stupidlagsync = 1;
local stupidlagsync = 1;
local stupidlagsync = 1;
local kek = 1;
local frame_rate = 0.0;
local next_tick_should_fakelag = true;
local saved = false;
local saved2 = false;
local overriden = false;
local manually_changing = false;
local old_lby_offset = gui.GetValue("rbot.antiaim.base.lby");
local old_rotation_offset = gui.GetValue("rbot.antiaim.base.rotation");
local tbl = {}
cache = {}

local get_abs_fps = function()
	frame_rate = 0.9 * frame_rate + (1.0 - 0.9) * globals.AbsoluteFrameTime();
	return math.floor((1.0 / frame_rate) + 0.5);
end

local saved_values = {
   	["rbot.antiaim.base"] = gui.GetValue("rbot.antiaim.base"),
    ["rbot.antiaim.advanced.autodir.edges"] = gui.GetValue("rbot.antiaim.advanced.autodir.edges"),
    ["rbot.antiaim.advanced.autodir.targets"] = gui.GetValue("rbot.antiaim.advanced.autodir"),
    ["rbot.antiaim.advanced.pitch"] = gui.GetValue("rbot.antiaim.advanced.pitch"),
    ["rbot.antiaim.condition.use"] = gui.GetValue("rbot.antiaim.condition.use")
}

local saved_values2 = {
	["misc.fakelag.enable"] = gui.GetValue("misc.fakelag.enable")
}

--Menu Related/Gui
local rb_ref = gui.Reference("Ragebot");
local tab = gui.Tab(rb_ref, "sestain", "Sestain's Script");
local gb_r = gui.Groupbox(tab, "Anti-Aim", 15, 15, 250, 400);
local gb_r2 = gui.Groupbox(tab, "Indicators & Other", 280, 15, 335, 400);

--Right Side
local safe_revolver = gui.Checkbox(gb_r2, "safe_revolver", "Safe Revolver", false);
local antionshot = gui.Checkbox(gb_r2, "antionshot", "Anti Onshot", false);
local disablefl = gui.Checkbox(gb_r2, "disablefl", "Disable Fakelag on DT/HS", false);
local idealtick = gui.Checkbox(gb_r2, "idealtick", "Ideal Tick", false)
local desync_indicator = gui.Checkbox(gb_r2, "desync_indicator", "Desync Indicator", 1);
local desync_indicator_rgb = gui.Checkbox(desync_indicator, "rgb", "rgb", 0);
local desync_position_z = gui.Slider(gb_r2, "desync_z", "Desync Indicator's Z Position", y, 0, h);
local desync_bgcp = gui.ColorPicker(desync_indicator, "desync_bgclr", "Desync Indicator's Background Color", 0,0,0,128);
local desync_icp = gui.ColorPicker(desync_indicator, "desync_iclr", "Desync Indicator's Indicator Color", 0,135,206,235);
local manual_indicator = gui.Checkbox(gb_r2, "manual_indicator", "Manual AA Indicator", 0);
local manual_indicator_rgb = gui.Checkbox(manual_indicator, "rgb", "rgb", 0);
local manual_position_z = gui.Slider(gb_r2, "manual_z", "Manual AA Indicator's Z Position", h/1.25, 0, h);
local manual_bgcp = gui.ColorPicker(manual_indicator, "manual_bgclr", "Manual AA Indicator's Background Color", 0,0,0,128);
local manual_icp = gui.ColorPicker(manual_indicator, "manual_iclr", "Manual AA Indicator's Indicator Color", 235,235,235,235);

--Left Side
local enabled = gui.Checkbox(gb_r, "enabled", "Enable", true);
local legitaa = gui.Checkbox(gb_r, "legitaa", "Legit AA on E", false);
local lagsync = gui.Checkbox(gb_r, "lagsync", "Lagsync", false);
local invert_key = gui.Keybox(gb_r, "ikey", "Invert Key", 0);
local left_key = gui.Keybox(gb_r, "left", "Manual AA to Left", 37);
local back_key = gui.Keybox(gb_r, "back", "Manual AA to Backwards", 40);
local right_key = gui.Keybox(gb_r,"right","Manual AA to Right", 39);
local rotation_angle = gui.Slider(gb_r, "rotationangle", "Rotation Offset", old_rotation_offset, -58, 58);
local lby_angle = gui.Slider(gb_r, "lbyangle", "LBY Offset", old_lby_offset, -180, 180);


--Descriptions of the features
desync_indicator:SetDescription("Shows which side your anti-aim desync is with an arrow");
desync_position_z:SetDescription("Changes desync Indicator's height");
manual_indicator:SetDescription("Shows where Manual Anti-Aim is set with an arrow");
manual_position_z:SetDescription("Changes Manual AA Indicator's height");
safe_revolver:SetDescription("R8 shouldn't shoot ground anymore (Doesn't work with high ping)");
antionshot:SetDescription("Desyncs while shooting (Mainly for MM)");
invert_key:SetDescription("Key used to invert Anti-Aim");
disablefl:SetDescription("You must bind DT for every weapon to make this work correctly");
idealtick:SetDescription("IdealTick from nxzAA by naz");

--Used for AntiOnshot to get Event
local function Fire(Event)
	if gui.GetValue("rbot.master") == true then
		if enabled:GetValue() == true then
			if antionshot:GetValue() == true then
				if not entities.GetLocalPlayer() then return end
				if not entities.GetLocalPlayer():IsAlive() then return end
			
				local ent = entities.GetByUserID(Event:GetInt('userid'));
    			if (ent ~= entities.GetLocalPlayer()) then return end
    			next_tick_should_fakelag = false;
			end
		end
	end
end

--AntiOnshot (Not sure if this works 100%)
local function Antionshot()
	if gui.GetValue("rbot.master") == true then
		if enabled:GetValue() == true then
			if antionshot:GetValue() == true then
				if not entities.GetLocalPlayer() then return end
				if not entities.GetLocalPlayer():IsAlive() then return end

    			gui.SetValue("misc.fakelag.enable", true);
    			if not next_tick_should_fakelag then
    			    gui.SetValue("misc.fakelag.enable", false);
    			    next_tick_should_fakelag = true;
				end
			end
		end
	end
end

--Safe revolver does some magic
local function SafeRevolver()
	if gui.GetValue("rbot.master") == true then
		if enabled:GetValue() == true then
			if safe_revolver:GetValue() == true then
				if not entities.GetLocalPlayer() then return end
				if not entities.GetLocalPlayer():IsAlive() then return end
	
				local WeaponID = entities.GetLocalPlayer():GetWeaponID();
				local WeaponType = entities.GetLocalPlayer():GetWeaponType();

    			if (WeaponType == 0 and WeaponID == 36) then
    			    gui.SetValue("misc.fakelag.enable", math.floor(1 / Globals.Frametime()) < 65 == false or true)
    			else
    			    gui.SetValue("misc.fakelag.enable", true)
				end
			end
		end
	end
end

--Some AntiAim stuff like invert key, manual aa & lagsync
local function Antiaim()
	if gui.GetValue("rbot.master") == true then
		if enabled:GetValue() == true then
			if invert_key:GetValue() ~= 0 then
				if input.IsButtonPressed(invert_key:GetValue()) then
					current_angle = current_angle == 0 and 1 or 0;
				end
			end
			
			if lagsync:GetValue() == true then
				if left_key:GetValue() ~= 0 then
					if input.IsButtonPressed(left_key:GetValue()) then
						drawLeft = drawLeft == 0 and 1 or 0;
						drawBack = 0;
						drawRight = 0;
						if drawLeft == 0 then
							gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 1 )
						elseif drawLeft == 1 then
							gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 0 )
						end
					end
					if drawLeft == 0 then
						stupidlagsync = 1;
					elseif drawLeft == 1 then
						stupidlagsync = 0;
						if globals.TickCount() % 3 == 0 then
							gui.SetValue("rbot.antiaim.base", 108);
						end
				
						if globals.TickCount() % 5 == 0 then
							gui.SetValue("rbot.antiaim.base", 72);
						end
					end
				end
	
				if back_key:GetValue() ~= 0 then
					if input.IsButtonPressed(back_key:GetValue()) then
						drawLeft = 0;
						drawBack = drawBack == 0 and 1 or 0;
						drawRight = 0;
						if drawBack == 0 then
							gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 1 )
						elseif drawBack == 1 then
							gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 0 )
						end
					end
					if drawBack == 0 then
						stupidlagsync2 = 1;
					elseif drawBack == 1 then
						stupidlagsync2 = 1;
					end
				end
	
				if right_key:GetValue() ~= 0 then
					if input.IsButtonPressed(right_key:GetValue()) then
						drawLeft = 0;
						drawBack = 0;
						drawRight = drawRight == 0 and 1 or 0;
						if drawRight == 0 then
							gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 1 )
						elseif drawRight == 1 then
							gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 0 )
						end
					end
					if drawRight == 0 then
						stupidlagsync3 = 1;
					elseif drawRight == 1 then
						stupidlagsync3 = 0;
						if globals.TickCount() % 3 == 0 then
							gui.SetValue("rbot.antiaim.base", -108);
						end
				
						if globals.TickCount() % 5 == 0 then
							gui.SetValue("rbot.antiaim.base", -72);
						end
					end
				end


				if stupidlagsync == 1 and stupidlagsync2 == 1 and stupidlagsync3 == 1 then
					if globals.TickCount() % 3 == 0 then
						gui.SetValue("rbot.antiaim.base", 162);
					end
			
					if globals.TickCount() % 5 == 0 then
						gui.SetValue("rbot.antiaim.base", -162);
					end
				end

				if current_angle ~= 2 then
					local lby = current_angle == 0 and -math.random(25, 32) or math.random(25, 32);
					local rotation = current_angle == 0 and -42 or 42;
					lby = 0 and -lby or lby;
					rotation = 0 and -rotation or rotation;
					gui.SetValue("rbot.antiaim.base.lby", lby);
					gui.SetValue("rbot.antiaim.base.rotation", -rotation);
				else
					gui.SetValue("rbot.antiaim.base.lby", -lby);
					gui.SetValue("rbot.antiaim.base.rotation", rotation);
				end
			else
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
				
				if kek == 1 then
					if current_angle ~= 2 then
						local lby = current_angle == 0 and -lby_angle:GetValue() or lby_angle:GetValue();
						local rotation = current_angle == 0 and -rotation_angle:GetValue() or rotation_angle:GetValue();
						lby = 0 and -lby or lby;
						rotation = 0 and -rotation or rotation;
						gui.SetValue("rbot.antiaim.base.lby", lby);
						gui.SetValue("rbot.antiaim.base.rotation", rotation);
					else
						gui.SetValue("rbot.antiaim.base.lby", -lby);
						gui.SetValue("rbot.antiaim.base.rotation", -rotation);
					end
				else
					if current_angle ~= 2 then
						local lby = current_angle == 0 and -lby_angle:GetValue() or lby_angle:GetValue();
						local rotation = current_angle == 0 and -rotation_angle:GetValue() or rotation_angle:GetValue();
						lby = 0 and -lby or lby;
						rotation = 0 and -rotation or rotation;
						gui.SetValue("rbot.antiaim.base.lby", -lby);
						gui.SetValue("rbot.antiaim.base.rotation", -rotation);
					else
						gui.SetValue("rbot.antiaim.base.lby", lby);
						gui.SetValue("rbot.antiaim.base.rotation", rotation);
					end
				end
			end
		end
	end
end

--Indicator for Desync
local function DesyncIndicator()
	if gui.GetValue("rbot.master") == true then
		if enabled:GetValue() == true then
			if desync_indicator:GetValue() == true then
				if not entities.GetLocalPlayer() then return end
				local desync_bgr, desync_bgg, desync_bgb, desync_bga = desync_bgcp:GetValue()
				local desync_ir, desync_ig, desync_ib, desync_ia = desync_icp:GetValue()
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
	end
end

--Indicator for Manual AA
local function ManualIndicator()
	if gui.GetValue("rbot.master") == true then
		if enabled:GetValue() == true then
			if manual_indicator:GetValue() == true then
				if not entities.GetLocalPlayer() then return end
				local manual_bgr, manual_bgg, manual_bgb, manual_bga = manual_bgcp:GetValue()
				local manual_ir, manual_ig, manual_ib, manual_ia = manual_icp:GetValue()

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
	end
end

--LegitAA on E
local function LegitAA(cmd)
	if gui.GetValue("rbot.master") == true then
		if enabled:GetValue() == true then
			if legitaa:GetValue() == true then
				if not legitaa:GetValue() or bit.band(cmd.buttons, bit.lshift(1, 5)) == 0 then
					if saved then
						for i, v in next, saved_values do
							gui.SetValue(i, v);
						end
						saved = false;
						kek = 1;
					end
				return end
				
				if not cmd.sendpacket then return end
				
				if not saved then
					for i, v in next, saved_values do
						saved_values[i] = gui.GetValue(i);
					end
					saved = true;
				end
				
				kek = 0;
    			gui.SetValue("rbot.antiaim.condition.use", 0);
    			gui.SetValue("rbot.antiaim.advanced.pitch", 0);
    			gui.SetValue("rbot.antiaim.advanced.autodir.edges", 0);
    			gui.SetValue("rbot.antiaim.advanced.autodir.targets", 0);
    			gui.SetValue("rbot.antiaim.base", [[0 "Desync"]]);
			end
		end
	end
end

--Disable Fakelag on DT or HideShots (Shift On Shot)
local function Fakelag()
	if gui.GetValue("rbot.master") == true then
		if enabled:GetValue() == true then
			if disablefl:GetValue() == true then
				if not entities.GetLocalPlayer() then return end
				local wid = entities.GetLocalPlayer():GetWeaponID();

				if (wid == 1 or wid == 64) and gui.GetValue("rbot.accuracy.weapon.hpistol.doublefire") ~= 0 or gui.GetValue("rbot.antiaim.condition.shiftonshot") then
					if not saved2 then
						for i, v in next, saved_values2 do
							saved_values2[i] = gui.GetValue(i);
						end
						saved2 = true;
					end
					gui.SetValue("misc.fakelag.enable", false)
				elseif (wid == 2 or wid == 3 or wid == 4 or wid == 30 or wid == 32 or wid == 36 or wid == 61 or wid == 63) and gui.GetValue("rbot.accuracy.weapon.pistol.doublefire") ~= 0 or gui.GetValue("rbot.antiaim.condition.shiftonshot") then
					if not saved2 then
						for i, v in next, saved_values2 do
							saved_values2[i] = gui.GetValue(i);
						end
						saved2 = true;
					end
					gui.SetValue("misc.fakelag.enable", false)
				elseif (wid == 7 or wid == 8 or wid == 10 or wid == 13 or wid == 16 or wid == 39 or wid == 60) and gui.GetValue("rbot.accuracy.weapon.rifle.doublefire") ~= 0 or gui.GetValue("rbot.antiaim.condition.shiftonshot") then
					if not saved2 then
						for i, v in next, saved_values2 do
							saved_values2[i] = gui.GetValue(i);
						end
						saved2 = true;
					end
					gui.SetValue("misc.fakelag.enable", false)
				elseif (wid == 11 or wid == 38) and gui.GetValue("rbot.accuracy.weapon.asniper.doublefire") ~= 0 or gui.GetValue("rbot.antiaim.condition.shiftonshot") then
					if not saved2 then
						for i, v in next, saved_values2 do
							saved_values2[i] = gui.GetValue(i);
						end
						saved2 = true;
					end
					gui.SetValue("misc.fakelag.enable", false)
				elseif (wid == 17 or wid == 19 or wid == 23 or wid == 24 or wid == 26 or wid == 33 or wid == 34) and gui.GetValue("rbot.accuracy.weapon.smg.doublefire") ~= 0 or gui.GetValue("rbot.antiaim.condition.shiftonshot") then
					if not saved2 then
						for i, v in next, saved_values2 do
							saved_values2[i] = gui.GetValue(i);
						end
						saved2 = true;
					end
					gui.SetValue("misc.fakelag.enable", false)
				elseif (wid == 14 or wid == 28) and gui.GetValue("rbot.accuracy.weapon.lmg.doublefire") ~= 0 or gui.GetValue("rbot.antiaim.condition.shiftonshot") then
					if not saved2 then
						for i, v in next, saved_values2 do
							saved_values2[i] = gui.GetValue(i);
						end
						saved2 = true;
					end
					gui.SetValue("misc.fakelag.enable", false)
				elseif (wid == 25 or wid == 27 or wid == 29 or wid == 35) and gui.GetValue("rbot.accuracy.weapon.shotgun.doublefire") ~= 0 or gui.GetValue("rbot.antiaim.condition.shiftonshot") then
					if not saved2 then
						for i, v in next, saved_values2 do
							saved_values2[i] = gui.GetValue(i);
						end
						saved2 = true;
					end
					gui.SetValue("misc.fakelag.enable", false)
				else
					if saved2 then
						for i, v in next, saved_values2 do
							gui.SetValue(i, v);
						end
						saved2 = false;
					end
				end
			end
		end
	end
end

--Set some gui items invisible & disabled
local function gui_set_invisible()
    local desync_indicator = desync_indicator:GetValue();
    local manual_indicator = manual_indicator:GetValue();

    desync_bgcp:SetInvisible(not desync_indicator);
	desync_icp:SetInvisible(not desync_indicator);
	
    manual_bgcp:SetInvisible(not manual_indicator);
	manual_icp:SetInvisible(not manual_indicator);

	desync_position_z:SetInvisible(desync_indicator == false);
	manual_position_z:SetInvisible(manual_indicator == false);

	desync_indicator_rgb:SetInvisible(true);
	manual_indicator_rgb:SetInvisible(true);
end

local function gui_set_disabled()
	if gui.GetValue("rbot.sestain.enabled") == false then
		safe_revolver:SetDisabled(true);
		antionshot:SetDisabled(true);
		desync_indicator:SetDisabled(true);
		desync_indicator_rgb:SetDisabled(true);
		desync_position_z:SetDisabled(true);
		desync_bgcp:SetDisabled(true);
		desync_icp:SetDisabled(true);
		manual_indicator:SetDisabled(true);
		manual_indicator_rgb:SetDisabled(true);
		manual_position_z:SetDisabled(true);
		manual_bgcp:SetDisabled(true);
		manual_icp:SetDisabled(true);
		invert_key:SetDisabled(true);
		left_key:SetDisabled(true);
		back_key:SetDisabled(true);
		right_key:SetDisabled(true);
		rotation_angle:SetDisabled(true);
		lby_angle:SetDisabled(true);
		legitaa:SetDisabled(true);
		disablefl:SetDisabled(true);
		lagsync:SetDisabled(true);
		idealtick:SetDisabled(true);
	else
		safe_revolver:SetDisabled(false);
		antionshot:SetDisabled(false);
		desync_indicator:SetDisabled(false);
		desync_indicator_rgb:SetDisabled(false);
		desync_position_z:SetDisabled(false);
		desync_bgcp:SetDisabled(false);
		desync_icp:SetDisabled(false);
		manual_indicator:SetDisabled(false);
		manual_indicator_rgb:SetDisabled(false);
		manual_position_z:SetDisabled(false);
		manual_bgcp:SetDisabled(false);
		manual_icp:SetDisabled(false);
		invert_key:SetDisabled(false);
		left_key:SetDisabled(false);
		back_key:SetDisabled(false);
		right_key:SetDisabled(false);
		rotation_angle:SetDisabled(false);
		lby_angle:SetDisabled(false);
		legitaa:SetDisabled(false);
		disablefl:SetDisabled(false);
		lagsync:SetDisabled(false);
		idealtick:SetDisabled(false);
	end
end

local function GuiStuff()
    gui_set_invisible();
	gui_set_disabled();
end

--Saves values
local function cache_fn()
    cache.scoutMinDmg = gui.GetValue("rbot.accuracy.weapon.scout.mindmg");
    cache.awpMinDmg = gui.GetValue("rbot.accuracy.weapon.sniper.mindmg");
    cache.hpistolMinDmg = gui.GetValue("rbot.accuracy.weapon.hpistol.mindmg");
	cache.scoutDT = gui.GetValue("rbot.accuracy.weapon.scout.doublefire");
    cache.awpDT = gui.GetValue("rbot.accuracy.weapon.sniper.doublefire");
    cache.hpistolDT = gui.GetValue("rbot.accuracy.weapon.hpistol.doublefire");
    cache.fakeLatency = gui.GetValue("misc.fakelatency.enable");
    cache.fakeLatencyAmount = gui.GetValue("misc.fakelatency.amount");
    cache.fakeLag = gui.GetValue("misc.fakelag.enable");
    cache.fakeLagAmount = gui.GetValue("misc.fakelag.factor");
end

cache_fn();

--IdealTick from nxzAA by naz
local function idealTick()
    local quickPeakKey = gui.GetValue("rbot.accuracy.movement.autopeekkey")
	if quickPeakKey ~= 0 and input.IsButtonDown(quickPeakKey) and not overriden and idealtick:GetValue() then
        gui.SetValue("misc.fakelatency.enable", true);
        gui.SetValue("misc.fakelatency.amount", 120);
        gui.SetValue("misc.fakelag.enable", false);
        gui.SetValue("misc.fakelag.factor", 1);
        gui.SetValue("rbot.accuracy.weapon.sniper.doublefire", 2);
        gui.SetValue("rbot.accuracy.weapon.scout.doublefire", 2);
        gui.SetValue("rbot.accuracy.weapon.hpistol.doublefire", 2);
        overriden = true;
		manually_changing = true;
		if not tbl["IT"] then
			tbl["IT"] = "IT";
		end
	end
	
	if quickPeakKey ~= 0 and input.IsButtonReleased(quickPeakKey) and overriden then
        gui.SetValue("misc.fakelatency.enable", cache.fakeLatency);
        gui.SetValue("misc.fakelatency.amount", cache.fakeLatencyAmount);
        gui.SetValue("misc.fakelag.enable", cache.fakeLag);
        gui.SetValue("misc.fakelag.factor", cache.fakeLagAmount);
        gui.SetValue("rbot.accuracy.weapon.sniper.doublefire", cache.scoutDT);
        gui.SetValue("rbot.accuracy.weapon.scout.doublefire", cache.awpDT);
        gui.SetValue("rbot.accuracy.weapon.hpistol.doublefire", cache.hpistolDT);
		overriden = false;
		manually_changing = false;
        tbl["IT"] = nil;
	end
	
	if not manually_changing then
		cache_fn();
	end
	
end

callbacks.Register( "FireGameEvent", Fire);
callbacks.Register( "Draw", idealTick);
callbacks.Register( "Draw", Antionshot);
callbacks.Register( "Draw", SafeRevolver);
callbacks.Register( "Draw", Antiaim);
callbacks.Register( "Draw", DesyncIndicator);
callbacks.Register( "Draw", ManualIndicator);
callbacks.Register( "Draw", Fakelag);
callbacks.Register( "Draw", GuiStuff);
callbacks.Register( "CreateMove", LegitAA);
