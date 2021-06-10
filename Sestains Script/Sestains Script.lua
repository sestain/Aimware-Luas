--[[
	# DON'T BE A DICK PUBLIC LICENSE

	> Version 1.1, December 2016

	> Copyright (C) [2021] [Sestain]

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
local VERSION_NUMBER = "1.47";
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
			updateframes = updateframes + globals.AbsoluteFrameTime();
			if updateframes > 5 then
				fadeout = ((updateframes - 5) * 510);
			end
			if updateframes > 0.1 and updateframes < 0.25 then
				fadein = (updateframes - 0.1) * 4500;
			end
			if fadein < 0 then fadein = 0 end
			if fadein > 650 then fadein = 650 end
			if fadeout < 0 then fadeout = 0 end
			if fadeout > 255 then fadeout = 255 end
		end
		if updateframes >= 0.25 then fadein = 650 end
		for i = 0, 600 do
			local alpha = 200-i/3 - fadeout;
			if alpha < 0 then alpha = 0 end
			draw.Color(15,15,15,alpha);
			draw.FilledRect(i - 650 + fadein, 0, i+1 - 650 + fadein, 30);
			draw.Color(255, 150, 75,alpha);
			draw.FilledRect(i - 650 + fadein, 30, i+1 - 650 + fadein, 31);
		end
		draw.SetFont(updaterfont1);
		draw.Color(255,150,75,255 - fadeout);
		draw.Text(7 - 650 + fadein, 7, "Sestain's");
		draw.Color(225,225,225,255 - fadeout);
		draw.Text(7 + draw.GetTextSize("Sestain's ") - 650 + fadein, 7, "Script");
		draw.Color(255,150,75,255 - fadeout);
		draw.Text(7 + draw.GetTextSize("Sestain's Script  ") - 650 + fadein, 7, "\\");
		spacing = draw.GetTextSize("Sestain's Script  \\  ");
		draw.SetFont(updaterfont2);
		draw.Color(225,225,225,255 - fadeout);
	end

    if (update_available and not update_downloaded) then
		draw.Text(7 + spacing - 650 + fadein, 9, "Downloading latest version.");
        local new_version_content = http.Get(SCRIPT_FILE_ADDR);
        local old_script = file.Open(SCRIPT_FILE_NAME, "w");
        old_script:Write(new_version_content);
        old_script:Close();
        update_available = false;
        update_downloaded = true;
	end
	
    if (update_downloaded) and updateframes < 5.5 then
		draw.Text(7 + spacing - 650 + fadein, 9, "Update available, please reload the script.");
    end

    if (not version_check_done) then
        version_check_done = true;
		local version = http.Get(VERSION_FILE_ADDR);
		version = string.gsub(version, "\n", "");
		if (version ~= VERSION_NUMBER) then
            update_available = true;
		else 
			up_to_date = true;
		end
	end
	
	if up_to_date and updateframes < 5.5 then
		draw.Text(7 + spacing - 650 + fadein, 9, "Successfully loaded latest version: v" .. VERSION_NUMBER);
	end
end)

--Variables, Values and functions
ffi.cdef[[
    typedef int(__fastcall* clantag_t)(const char*, const char*);
	void* GetProcAddress(void* hModule, const char* lpProcName);
    void* GetModuleHandleA(const char* lpModuleName);
    
    typedef struct {
        uint8_t r;
        uint8_t g;
        uint8_t b;
        uint8_t a;
    } color_struct_t;

    typedef void (*console_color_print)(const color_struct_t&, const char*, ...);
    typedef void* (__thiscall* get_client_entity_t)(void*, int);
]]

local c_hud_chat =
    ffi.cast("unsigned long(__thiscall*)(void*, const char*)", mem.FindPattern("client.dll", "55 8B EC 53 8B 5D 08 56 57 8B F9 33 F6 39 77 28"))(
    ffi.cast("unsigned long**", ffi.cast("uintptr_t", mem.FindPattern("client.dll", "B9 ?? ?? ?? ?? E8 ?? ?? ?? ?? 8B 5D 08")) + 1)[0],
    "CHudChat"
)

local fn_change_clantag = mem.FindPattern("engine.dll", "53 56 57 8B DA 8B F9 FF 15")
local set_clantag = ffi.cast("clantag_t", fn_change_clantag)
local ffi_log = ffi.cast("console_color_print", ffi.C.GetProcAddress(ffi.C.GetModuleHandleA("tier0.dll"), "?ConColorMsg@@YAXABVColor@@PBDZZ"))
local ffi_print_chat = ffi.cast("void(__cdecl*)(int, int, int, const char*, ...)", ffi.cast("void***", c_hud_chat)[0][27])
local w, h = draw.GetScreenSize();
local x = w/2;
local y = h/2;
local current_angle = 0;
local drawLeft = 0;
local drawRight = 0;
local drawBack = 0;
local stupidlagsync = 1;
local stupidlagsync2 = 1;
local stupidlagsync3 = 1;
local kek = 1;
local gaben = 1;
local clantagset = 0;
local old_time = 0;
local saved = false;
local overriden = false;
local manually_changing = false;
local old_lby_offset = gui.GetValue("rbot.antiaim.base.lby");
local old_rotation_offset = gui.GetValue("rbot.antiaim.base.rotation");
local sv_maxusrcmdprocessticks = gui.Reference("Misc", "General", "Server", "sv_maxusrcmdprocessticks")
local tbl = {};
cache = {};

local saved_values = {
   	["rbot.antiaim.base"] = gui.GetValue("rbot.antiaim.base"),
    ["rbot.antiaim.advanced.autodir.edges"] = gui.GetValue("rbot.antiaim.advanced.autodir.edges"),
    ["rbot.antiaim.advanced.autodir.targets"] = gui.GetValue("rbot.antiaim.advanced.autodir"),
    ["rbot.antiaim.advanced.pitch"] = gui.GetValue("rbot.antiaim.advanced.pitch"),
    ["rbot.antiaim.condition.use"] = gui.GetValue("rbot.antiaim.condition.use")
}

local animation = {
    "                  ",
    "                 s",
    "                se",
    "               ses",
    "              sess",
    "             sessu",
    "            sessuh",
    "           sessuho",
    "          sessuhoo",
    "         sessuhook",
    "        sessuhook ",
    "       sessuhook  ",
    "      sessuhook   ",
    "     sessuhook    ",
    "    sessuhook     ",
    "   sessuhook      ",
    "  sessuhook       ",
    " sessuhook        ",
    "sessuhook         ",
    "essuhook          ",
    "ssuhook           ",
    "suhook            ",
    "uhook             ",
    "hook              ",
    "ook               ",
    "ok                ",
    "k                 "
}

function client.color_log(r, g, b, msg, ...)
    for k, v in pairs({...}) do
        msg = tostring(msg .. v)
    end
    local clr = ffi.new("color_struct_t")
    clr.r, clr.g, clr.b, clr.a = r, g, b, 255
    ffi_log(clr, msg)
end

function client.PrintChat(msg)
    ffi_print_chat(c_hud_chat, 0, 0, " " .. msg)
end

--Menu Related/Gui
local rb_ref = gui.Reference("Ragebot");
local tab = gui.Tab(rb_ref, "sestain", ("Sestain's Script " .. VERSION_NUMBER));
local gb_r = gui.Groupbox(tab, "Anti-Aim", 15, 15, 250, 400);
local gb_r2 = gui.Groupbox(tab, "Other", 280, 15, 335, 400);

--Right Side
local logOptions = gui.Multibox( gb_r2, "Logs")
local autodisconnect = gui.Checkbox(gb_r2, "autodisconnect", "Auto Disconnect", false);
local lowdelta = gui.Checkbox(gb_r2, "lowdelta", "Low Delta on DT & Shift on Shot", true);
local legitaa = gui.Checkbox(gb_r2, "legitaa", "Legit AA on Use", true);
local idealtick = gui.Checkbox(gb_r2, "idealtick", "Ideal Tick", false);
local attarget = gui.Checkbox(gb_r2, "attarget", "At-Targets", true);
local lagsync = gui.Checkbox(gb_r2, "lagsync", "Lagsync", false);
local clantag = gui.Checkbox(gb_r2, "clantag", "Clantag", true);
local desync_indicator = gui.Checkbox(gb_r2, "desync_indicator", "Desync Indicator", true);
local desync_indicator_rgb = gui.Checkbox(desync_indicator, "rgb", "rgb", 0);
local desync_bgcp = gui.ColorPicker(desync_indicator, "desync_bgclr", "Desync Indicator's Background Color", 0,0,0,128);
local desync_icp = gui.ColorPicker(desync_indicator, "desync_iclr", "Desync Indicator's Color", 0,135,206,235);
local manual_indicator = gui.Checkbox(gb_r2, "manual_indicator", "Manual AA Indicator", true);
local manual_indicator_rgb = gui.Checkbox(manual_indicator, "rgb", "rgb", 0);
local manual_bgcp = gui.ColorPicker(manual_indicator, "manual_bgclr", "Manual AA Indicator's Background Color", 0,0,0,128);
local manual_icp = gui.ColorPicker(manual_indicator, "manual_iclr", "Manual AA Indicator's Color", 235,235,235,235);

local logHits = gui.Checkbox( logOptions, "hit.enable", "Hits", true)
local logMiss = gui.Checkbox( logOptions, "miss.enable", "Misses", true)
local logHurt = gui.Checkbox( logOptions, "hurt.enable", "Hurt", true)
local logOther = gui.Checkbox( logOptions, "other.enable", "Other", true)
local printchat = gui.Checkbox( logOptions, "logs.chat", "Chat", true)
local printconsole = gui.Checkbox( logOptions, "logs.console", "Console", true)

--Left Side
local enabled = gui.Checkbox(gb_r, "enabled", "Enable", true);
local invert_key = gui.Keybox(gb_r, "ikey", "Invert Key", 6);
local left_key = gui.Keybox(gb_r, "left", "Manual AA to Left", 37);
local back_key = gui.Keybox(gb_r,"back","Manual AA to Back", 40);
local right_key = gui.Keybox(gb_r,"right","Manual AA to Right", 39);
local yaw_angle = gui.Slider(gb_r, "yawangle", "Yaw Offset", 0, -180, 180);
local jitter_amount = gui.Slider(gb_r, "jitteramount", "Jitter Amount", 0, -180, 180);
local rotation_angle = gui.Slider(gb_r, "rotationangle", "Rotation Offset", old_rotation_offset, -58, 58);
local lby_angle = gui.Slider(gb_r, "lbyangle", "LBY Offset", old_lby_offset, -180, 180);

--Descriptions of the features
desync_indicator:SetDescription("Shows which side your anti-aim desync is with a line.");
manual_indicator:SetDescription("Shows where Manual Anti-Aim is set with an arrow.");
idealtick:SetDescription("IdealTick from nxzAA by naz.");
lowdelta:SetDescription("Sets AA Type to Micro from Lower when DT or Shift on Shots is on.");

local function NormalizeYaw(yaw)
    while yaw > 180 do yaw = yaw - 360 end
    while yaw < -180 do yaw = yaw + 360 end
    return yaw
end

--Some AntiAim stuff like invert key, manual aa & lagsync
local function Antiaim()
	if gui.GetValue("rbot.master") == true and enabled:GetValue() == true then
		if invert_key:GetValue() ~= 0 then
			if input.IsButtonPressed(invert_key:GetValue()) then
				current_angle = current_angle == 0 and 1 or 0;
			end
		end

		if lowdelta:GetValue() == true then
			if not kek and
				gui.GetValue("rbot.accuracy.weapon.pistol.doublefire" ) == 2 or gui.GetValue("rbot.accuracy.weapon.hpistol.doublefire") == 2 or
				gui.GetValue("rbot.accuracy.weapon.smg.doublefire"    ) == 2 or gui.GetValue("rbot.accuracy.weapon.rifle.doublefire"  ) == 2 or
				gui.GetValue("rbot.accuracy.weapon.shotgun.doublefire") == 2 or gui.GetValue("rbot.accuracy.weapon.asniper.doublefire") == 2 or
				gui.GetValue("rbot.accuracy.weapon.lmg.doublefire"    ) == 2 or gui.GetValue("rbot.accuracy.weapon.pistol.doublefire" ) == 1 or
				gui.GetValue("rbot.accuracy.weapon.hpistol.doublefire") == 1 or gui.GetValue("rbot.accuracy.weapon.smg.doublefire"    ) == 1 or
				gui.GetValue("rbot.accuracy.weapon.rifle.doublefire"  ) == 1 or gui.GetValue("rbot.accuracy.weapon.shotgun.doublefire") == 1 or
				gui.GetValue("rbot.accuracy.weapon.asniper.doublefire") == 1 or gui.GetValue("rbot.accuracy.weapon.lmg.doublefire"    ) == 1 or
				gui.GetValue("rbot.antiaim.condition.shiftonshot") == true then
				gui.SetValue("rbot.antiaim.advanced.antialign", 1)
			else
				gui.SetValue("rbot.antiaim.advanced.antialign", 0)
			end
		end

		if lagsync:GetValue() == true then
			if gaben == 1 then
				if left_key:GetValue() ~= 0 then
					if input.IsButtonPressed(left_key:GetValue()) then
						drawLeft = drawLeft == 0 and 1 or 0;
						drawRight = 0;
						if drawLeft == 0 then
							gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 1 );
						elseif drawLeft == 1 then
							gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 0 );
						end
					end
					if drawLeft == 0 then
						stupidlagsync = 1;
					elseif drawLeft == 1 then
						stupidlagsync = 0;
						if globals.TickCount() % 3 == 0 then
							gui.SetValue("rbot.antiaim.base", 104);
						end
					
						if globals.TickCount() % 5 == 0 then
							gui.SetValue("rbot.antiaim.base", 72);
						end
					end
				end
			
				if right_key:GetValue() ~= 0 then
					if input.IsButtonPressed(right_key:GetValue()) then
						drawLeft = 0;
						drawRight = drawRight == 0 and 1 or 0;
						if drawRight == 0 then
							gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 1 );
						elseif drawRight == 1 then
							gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 0 );
						end
					end
					if drawRight == 0 then
						stupidlagsync3 = 1;
					elseif drawRight == 1 then
						stupidlagsync3 = 0;
						if globals.TickCount() % 3 == 0 then
							gui.SetValue("rbot.antiaim.base", -104);
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
						gui.SetValue("rbot.antiaim.base", -166);
					end
				end
			end
			if kek == 1 then
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
		else
			if left_key:GetValue() ~= 0 then
				if input.IsButtonPressed(left_key:GetValue()) then
					drawLeft = drawLeft == 0 and 1 or 0;
					drawRight = 0;
					drawBack = 0;
					if drawLeft == 0 then
						gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 1 );
					elseif drawLeft == 1 then
						gui.SetValue("rbot.antiaim.base", 90)
						gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 0 );
					end
				end
			end
			
			if right_key:GetValue() ~= 0 then
				if input.IsButtonPressed(right_key:GetValue()) then
					drawLeft = 0;
					drawRight = drawRight == 0 and 1 or 0;
					drawBack = 0;
					if drawRight == 0 then
						gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 1 );
					elseif drawRight == 1 then
						gui.SetValue("rbot.antiaim.base", -90)
						gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 0 );
					end
				end
			end

			if back_key:GetValue() ~= 0 then
				if input.IsButtonPressed(back_key:GetValue()) then
					drawLeft = 0;
					drawBack = drawBack == 0 and 1 or 0;
					drawRight = 0;
					if drawBack == 0 then
						gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 1 );
					elseif drawBack == 1 then
						gui.SetValue("rbot.antiaim.base", 180)
						gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 0 );
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

				if drawRight == 0 and drawLeft == 0 and drawBack == 0 then
					local customyaw = gui.GetValue("rbot.sestain.yawangle");
					local customjitter = gui.GetValue("rbot.sestain.jitteramount");
					local wellumm = NormalizeYaw(180 - customyaw + customjitter);
					local wellumm2 = NormalizeYaw(180 - customyaw - customjitter);

					if globals.TickCount() % 2 == 0 then
						gui.SetValue("rbot.antiaim.base", wellumm2);
					end
				
					if globals.TickCount() % 4 == 0 then
						gui.SetValue("rbot.antiaim.base", wellumm);
					end

					if attarget:GetValue() == true then 
						gui.SetValue( "rbot.antiaim.advanced.autodir.targets", 1 );
					end
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

--Indicators
local function Indicators()
	if gui.GetValue("rbot.master") == true and enabled:GetValue() == true then
		if not entities.GetLocalPlayer() then return end
		local desync_bgr, desync_bgg, desync_bgb, desync_bga = desync_bgcp:GetValue();
		local desync_ir, desync_ig, desync_ib, desync_ia = desync_icp:GetValue();
		local manual_bgr, manual_bgg, manual_bgb, manual_bga = manual_bgcp:GetValue();
		local manual_ir, manual_ig, manual_ib, manual_ia = manual_icp:GetValue();
		
		if desync_indicator:GetValue() == true then
			if current_angle == 0 then
				draw.Color(desync_ir, desync_ig, desync_ib, desync_ia);
				draw.FilledRect( x + 40, y - 10, x + 36, y + 10 );
				draw.Color(desync_bgr, desync_bgg, desync_bgb, desync_bga);
				draw.FilledRect( x - 40, y - 10, x - 36, y + 10 );
			elseif current_angle == 1 then
				draw.Color(desync_bgr, desync_bgg, desync_bgb, desync_bga);
				draw.FilledRect( x + 40, y - 10, x + 36, y + 10 );
				draw.Color(desync_ir, desync_ig, desync_ib, desync_ia);
				draw.FilledRect( x - 40, y - 10, x - 36, y + 10 );
			end
		end

		if manual_indicator:GetValue() == true then
			if drawLeft == 0 then
				draw.Color(manual_bgr, manual_bgg, manual_bgb, manual_bga);
				draw.Triangle(x - 50, y + 10, x - 70, y, x - 50, y - 10);
			elseif drawLeft == 1 then
				draw.Color(manual_ir, manual_ig, manual_ib, manual_ia);
				draw.Triangle(x - 50, y + 10, x - 70, y, x - 50, y - 10);
			end
			
			if drawRight == 0 then
				draw.Color(manual_bgr, manual_bgg, manual_bgb, manual_bga);
				draw.Triangle(x + 50, y - 10, x + 70, y, x + 50, y + 10);
			elseif drawRight == 1 then
				draw.Color(manual_ir, manual_ig, manual_ib, manual_ia);
				draw.Triangle(x + 50, y - 10, x + 70, y, x + 50, y + 10);
			end

			if drawBack == 0 then
				draw.Color(manual_bgr, manual_bgg, manual_bgb, manual_bga);
				draw.Triangle(x - 10, y + 50, x + 10, y + 50, x, y + 70);
			elseif drawBack == 1 then
				draw.Color(manual_ir, manual_ig, manual_ib, manual_ia);
				draw.Triangle(x - 10, y + 50, x + 10, y + 50, x, y + 70);
			end
		end
	end
end

--LegitAA on Use
local function LegitAA(cmd)
	if gui.GetValue("rbot.master") == true and enabled:GetValue() == true and legitaa:GetValue() == true then
		if bit.band(cmd.buttons, bit.lshift(1, 5)) == 0 then
			if saved then
				for i, v in next, saved_values do
					gui.SetValue(i, v);
				end
				saved = false;
				kek = 1;
				gaben = 1;
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
		gaben = 0;
    	gui.SetValue("rbot.antiaim.condition.use", 0);
    	gui.SetValue("rbot.antiaim.advanced.pitch", 0);
    	gui.SetValue("rbot.antiaim.advanced.autodir.edges", 0);
    	gui.SetValue("rbot.antiaim.advanced.autodir.targets", 0);
    	gui.SetValue("rbot.antiaim.base", [[0 "Desync"]]);
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

	desync_indicator_rgb:SetInvisible(true);
	manual_indicator_rgb:SetInvisible(true);
end

local function gui_set_disabled()
	local tradition = enabled:GetValue() == false;
	desync_indicator:SetDisabled(tradition);
	desync_indicator_rgb:SetDisabled(tradition);
	desync_bgcp:SetDisabled(tradition);
	desync_icp:SetDisabled(tradition);
	manual_indicator:SetDisabled(tradition);
	manual_indicator_rgb:SetDisabled(tradition);
	manual_bgcp:SetDisabled(tradition);
	manual_icp:SetDisabled(tradition);
	invert_key:SetDisabled(tradition);
	left_key:SetDisabled(tradition);
	right_key:SetDisabled(tradition);
	rotation_angle:SetDisabled(tradition);
	lby_angle:SetDisabled(tradition);
	legitaa:SetDisabled(tradition);
	lagsync:SetDisabled(tradition);
	idealtick:SetDisabled(tradition);
	autodisconnect:SetDisabled(tradition);
	back_key:SetDisabled(tradition);
	yaw_angle:SetDisabled(tradition);
	jitter_amount:SetDisabled(tradition);
	lowdelta:SetDisabled(tradition);
	attarget:SetDisabled(tradition);
	clantag:SetDisabled(tradition);
end

local function GuiStuff()
    gui_set_invisible();
	gui_set_disabled();
end

--Saves values
local function cache_fn()
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
	if gui.GetValue("rbot.master") == true and enabled:GetValue() == true then
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
end

--Auto Disconnects from game when it finishes.
local function AutoDisconnect(event)
	if gui.GetValue("rbot.master") == true and enabled:GetValue() == true and autodisconnect:GetValue() == true then
		if event:GetName() and event:GetName() == "cs_win_panel_match" then
    	    client.Command("disconnect", true);
		end
	end
end

--EngineRadar shows enemies on ingame radar.
local function EngineRadar()
	if gui.GetValue("rbot.master") == true and enabled:GetValue() == true then
    	for index, Player in pairs(entities.FindByClass("CCSPlayer")) do
    	    Player:SetProp("m_bSpotted", 1);
    	end
	end
end

--Draws gaben's face to console when unloading script.
local function OnUnload()
	client.Command("toggleconsole", true);
	client.Command("echo \";   ..:,.;;;L;L;F...:,;;L;L;FyjjEhK5hKOO8S8SESpObb8OBOpb88bbpO8bb8BbQBQBQQgQQBQBQBQBQbbGpOGnzLrL;,  ,,:.... ..:L;;,;;;;,;;;\"", true);
	client.Command("echo \";      .;;;;;;;;L:;;;rzyyZFFZGOpG8OQ8Bbb8QBB8bBQBgg8OBbBOBBQBQQGGGGGG@G@G@G@@@@@@@@@@@G@GGQb5yL;;;:. .         ,zc;;;L;;;;;\"", true);
	client.Command("echo \",     . ;;;;;;;;,;;;cLFzjFzyh3hKShS5OGES88bpGEOhGGGnGhEEOE8bQQQBQBQQgQgQgQQQgQQBQQgQgQQQQBQbOyL:: .,:.  ,;;;;   ;:;;;;;;;,;\"", true);
	client.Command("echo \",      . ..,:::,,;;L;rLLF7cyZE5SSGoE5GE8pbbBSGEOpGhOp85O8BBgQgQgggQgQgggQgQgQQQgQQQgQQQQQQQQQBKr;:   .;cz5ShSL ...;L,;;;;;;\"", true);
	client.Command("echo \";       ....,;;,;;;;LLrrzrzLyyZK55OE5hp8bBQpG5hOOhGE8bBbQQQBQQgQgQgggggggQgQgQQQgQgQQQgQQQQBgQQpn;;.  .,.:rF7y,   .;;;;;;;;\"", true);
	client.Command("echo \";.   . .   ..,;;,;,;;LLz;7zcznZhoOGOE8bBbQQBEEKOGOE88QQBBBbQBgQgggQgggQgQgQgQgQgQgggBQQQBQBQBQQgB5LL;;.. . :;;;c;L;;:;;;;;,\"", true);
	client.Command("echo \"L.    .   ..,,;,;,;;;;;;L;cLjnhK558OGEBbBQQQbGpEOO8pbQQOBbQQgggggg@ggQgQgBQQggggQQgQQBQQQQQBQBQQgQby,,7  .   ;z8@g@h.:;;;;;\"", true);
	client.Command("echo \";;   .   ..::;;;,;,;;;;;,;;rzZKEhEObG8pbbQQgb8ObOGpBbQb8pbpQQgg@ggggQQ8BBB8QQQQQBQQgQQQQBQQQQQQg@@gO  :      3j;;LE@7.,;;;;\"", true);
	client.Command("echo \";L,   .   ..,,;;;;;;;;L;;;;;zzZoS5O8b8bEbbQgQGpOB8SOOS5j5nh5ych53SpGOGESOSEoOOO5O8BbQBQQgQgg@@@gS::;K8G,,;L,nQQoy. Sg:,,;;;\"", true);
	client.Command("echo \";;;       .,:,,;,;;;;;;L;LLLLyoESOOp8bO8bbBg83SpGB5ncr;;;;;L:,;,,;,,,;rnnpphnKKS5OOpQgQgg@@@b7   ;p@BQbKLjQbQgQb8Z.c@L:;;;;\"", true);
	client.Command("echo \";;L,      ..,:,,;,;;;;;;LLrLzcyZhGOEp5hpb8QBOcKEOE5;LLL;L,,;;,:.,:,:;,;;;ro8gQgBQQQQgg@gQZ.   rb@ggQBOQbObQggQgBBO;,@F:;;;;\"", true);
	client.Command("echo \";;;r:      ::,.,:,,L;L;L;;;;,;;;;;;j3oy3KOGBn;yOO8pSz7LFryjL;zKGE88BBgg@@@B8EB@@BQg@QG;   .ng@@@QQBB8pBQBg@@ggggB8;L@c.;;;;\"", true);
	client.Command("echo \";;;;L.    ..:::.::,;;,;;;,:....   .:,;;;Ljhn;,yhBQ@ggbGzZ3Lnb88OpG88BBQggg@gg3yKppF.   ,8@@g@gQBQbB88ObQgoy8BBQBQBzOb.,,;,;\"", true);
	client.Command("echo \";;;;;L     .:::,:. ....,.. ..,:,,;,:...;;c;:,LzSb@@@g@bp7.jSKSKF      ;. ,,;;yc;oE.:Lb@@@@QQBQBQbBbb888QE .zSb8BQgGgL.,;;;;\"", true);
	client.Command("echo \";;;;LL.     :,,,,.      .,LFhOb8BQQO8h3z7;;..,L,;;;FOphByhy,;:.       ;:;FZEbBQ8QBQQ@ggQQQgBBbQBQBb8B88bbz:;noOOBgQQ,.;,;;;\"", true);
	client.Command("echo \";;;;,,:.     .:,;,.....;LFjKZ5SShjLF7zrL;. c.  ,r7KBB8LLr8S7;;;;LcLcrjSQg@@@gQ8bpbbbQgQgQQQQBbbBBBbBbB88Q@bz;LyohQQQ::,;;;;\"", true);
	client.Command("echo \";;;;: ......    :::.. ;,;;;:      y.:       . .ZbE8Q@@g.,y38BhjyyFZZES8p8pB8bbQbbQQQQQQQQQQBQbbbQBQbBbbO8g@g5L7ZOQgQ;.;,;;;\"", true);
	client.Command("echo \";;;L.    . . :.      :,;;;;      .zLcr;;;:... :yKEbQQ@@B.p5,3bOOSGhOOOSOGppbQgBBQgQQQQBQQQQQbb8BQQBBbBbbhBg8c;zObgBg,,,;,;,\"", true);
	client.Command("echo \";;;;;      ...,::..  ,czyn3oZnczzyn3oZnc;.... ,;ypbQQg@gg;Go3ZohOEO5OOO8b8ObQBBQQBQQQQQQQBQBB8bpQBQQQBBb8SShppQQQpgS.:;;;;;\"", true);
	client.Command("echo \";;;;;;.    ...:::,,;:.K;.,,;Lz7yyyzyrrLL;;....;;jbBgggg@@@8ggbhEhhK5ZEGOSKySGb8bbBbQQgQgQQQQbQBBpQQQQQBB8phbQgQQpB@z.,;;,;;\"", true);
	client.Command("echo \";;;;;;r;.   ....:,;;;:;OF.:,;;LrrLr;L;L;;::::;;;GBgggggggg@@@ggbbOOEEhhoh5OObbBBQQQQQQgQQQQQQQQBBBQQQBB8BpOQgBQbQg8c;,;;;;;\"", true);
	client.Command("echo \";;;;;;;LL;.......:,;;r;;hG7L;L;rLLLc;r;;,,,;;;,;nbQgggQgggg@g@QQ8B88p8O8OBbbbBBQQgggQgQQQQQQBQQQbQbQQQbQbBEbQQQQQ8;,;;;;;;;\"", true);
	client.Command("echo \";;;;;;;;;;r:  ...:;,;;;;;75hKFyzyFzLc;;;L;L;;;;;yGbQgQgQgQgggQQOo3ESSG8O8pb8QBQBgQgQgQgBQBQBQBQBbBQBQQQbBBbOQbbbgn .;;;;;;;\"", true);
	client.Command("echo \";;;;;;;;;;;L.. ..::;:;;L;L;LcjyZyZFyzFzzL;,,;;,rjEpQQgQQBgQQBBBQ5r;;LFnK5OOb8bbQBQQgggQQBQBQQQQQbBBQbQQQBB8p8BbQ@O .;;;;;;;\"", true);
	client.Command("echo \";;;;;;;;;;;;;...:.::;,;;LLyZShGGESEKKjz;,..:;;;;ZSbQgQQQQQQ8bbQQQn;,::;;7ySEppbbBQgQQBQQQbQQQQQQQbBQQBQBQbBObg@@@.::;;;;;;;\"", true);
	client.Command("echo \",;;;;;;;;;;;;,...:.::;,;;zF535oEo5jycL,.  :;,;,;yppQQgQgQQQQQgggQ8GGy;::,;roS8p88QQQQQBBBQ8QQQBQQQ8QQQBQBB8bObEc  ;;;;;;;;;\"", true);
	client.Command("echo \";;;;;;;;;;;;;;,.:...::;;L7zj5K5K5ZyrL,.   L;;;;;ch8bQggQgQgggQbObBQBbEj;;:;;ynEE88BBQBQBQQBBQQQBQbQBQBQBBbB8B;    :,LLL;;;;\"", true);
	client.Command("echo \";;;;;;;;;;;;;L;..:...::;;z7jZ5noK5Zz;;.  :;;;;;zFS8BQgg@QgBbOEnOQgQgBBpOycLL;c7yKGO88BbQBQBQBQQQQQBQBQbQBQbbbO,    ..::,;L;\"", true);
	client.Command("echo \";,;,;;;;;;;;;;;.......,,LLz7Z333oKEnz;;:;,,:::;LKSp8QggggBbQQQQbQQgQQ8b8b53nc7KK3opOBBQBQBQbBBQBQBQQQBQbQbB8bpby        ;;;\"", true);
	client.Command("echo \",;,;;;;;;;;;;;;: :.,.::;;LLyy5ZKKh5oFF;;;;;;.. .;ynhObBBZ3SOpBbQQQQQbB8bBQ8QE3KO88ObBQQQBQB8BQQgBQQQbBbBBB8b8pOQO.       ;;\"", true);
	client.Command("echo \";;;,;,;;;,;;;;L, ..::..:;;rFZZo3ESh3ncrLL;;;;.....,;znhz;zny5O8bQQQBQQQBQQgB8ozy55nhQBQBQBQbBBQQQBQBBb88b8b8bpEOB8.       ;\"", true);
	client.Command("echo \",;,;;;,;;;;;;;;L...::...:;;cLjZ5oSo53F;;;;,;,;;;;LLyyh5SS5nEOBbgg@@@@@@@Q8Sy7y7y;;LSBQbQBQQQbQBQQQBB8bpB8Bbb88SEGbb;      .\"", true);
	client.Command("echo \";,;;;;;;;;;,;;;;; ..:....,;;zjSo5KoZ5jL;;;;;;;L;zFE8BQQBQBb88p8OGo3jz;;;73EKno8EF;38QQQBQQQQB8BBQbQbb8bbb8b8bpEKGObBL     .\"", true);
	client.Command("echo \",;;;;;,;,;;;,;;;;. ..:...,,;rno3j3ZKjzL;;;;;;r7jn35G5Oh5KKjZL; ,...::LhQggggbbO5y5GBBQQQQQBQBQbQBB8b8b8B8B8bpbSEGOGbQ;    .\"", true);
	client.Command("echo \";,;;;;;;;;;;;;;;L,........,;FFLLnjjynFL,,,;;L;;;;;        ,LjnKGBQgg@@@gQQQQQBbhoEbBQBQBQBBBQBQBB8bpb888bbb888S58EpO8pL.  .\"", true);
	client.Command("echo \",;,;,;,;;;;;;;;;;L. ...:...;zS;LnonK3KL;:......        jcFZpbQg@ggggQgQQbQQQQQbbG88BBQBQBBbQbBbB8bO8pb8BbB888boSpOOpO8cL: .\"", true);
	client.Command("echo \";,;,;,;,;;;,;;;;;;;. ...,. :7nZzohpGOE5y;,......;;;;;;888O88BBQQQQQBQQQbQbQQQQQBB8B8bpB8BBB8Q8b8bOp8b8BbBbbO8Ohh8O8ObEz;; .\"", true);
	client.Command("echo \",;,;,;,;,;;;;;;;;;;; ...:;. :LjyrSObpGhSzL;L;;;,.,;FjooEhOE5KEG8bQBQQQQQBBQQQgQQBQbb8b88bQ888Bp8O88bpb8b88O88OnGE8EOOEL;: .\"", true);
	client.Command("echo \";,;,;,;,;;;,;,;;;;;;,  ..:;. .Lz77SpbpOZF7c;L;,...:,LcnzLLKn3n5OBBQBQQgBQBBbQQgQQBQ8b8QbBBB8b8bO888pb8b88pb8853EOOOGOK;.. .\"", true);
	client.Command("echo \",,,;,;;;,;,;;;,;;;;;;:   .,;. .;;LyhhphS7Lr7LL;;,,:;;jK5zyKOEGS88bBQBBbb8BbQBQBQQQQQbbbb8bbbp8p8O8Ob8bpb88ObGSKEGpSpSj.   .\"", true);
	client.Command("echo \";,;,;,;,;,;,;,;,;;;;;L.   .:;.  ,;7y35Go5;Lc7L7;L;Lco5Go53EEShOG88bO8OppbbQbBQQBQQQbBbB8B8b888b88Ob8B8b8pp8GpSS5pGOGS;.   .\"", true);
	client.Command("echo \",;,;,;,;,;,;,;;;;;,;;;;.   ..,.. .,LLFzyyF;rLrcyzyz3nKojFF7yjKoEObGESpO88QBQQQBQQQBBbBbBbb88Ob8b8b8B88pbObGOOGEOOGoOy.    .\"", true);
	client.Command("echo \";,;,;,;,;,;,;,;;;,;,;,;;. .   ... .:::;;L;rcz;nZ33on7;;;LLnKSSpG8p88b8BbQBQQQBQBQBB8bpb8b88Ob8b8bbBpb8b88G888GOGOEG3;     .\"", true);
	client.Command("echo \",;,;,;,;,;,;,;,;,;;;,;;L;. .   ........:,;;rLcz3h5rL;;;Fzo5OS8Ep8bpBBBBQBQBQBBbB8b8b8bpbO88b8B8b8b8bOb88O8O8pGG8SG3L     ..\"", true);
	client.Command("echo \",,;,;,,,;,;,;,;,;;;,;,;;;;. . . ..... . .:;;L;LLycL;LLynSSOEEhO8B8bbQBQBQQQBQ8bppO88b8b8b8B88pb88pBpbO8O8p8O8E8hE57.     ..\"", true);
	client.Command("echo \",,,;,;,;,;,;,;,;,;,;,;,;;;;. ... . ..... ..,,;;;;cL;;7nhZOEEEpO8bB8BbQQQQQbQb8EpO88bO8p88B8b88p8p8pbpbpbp8O8O8OpEj.    . . \"", true);
	client.Command("echo \",:,,;,;,;,,,;,;,;,;,;,;,;;c;  ... . ....  ..,,;;;;L;LLyjoEOhSOpObOb8BbQbBbbpphGO8pB8b8pb8bbp8O8O8O8p888p8Opp8ObOo.    . . .\"", true);
	client.Command("echo \":,:,,,,,,;,;,;,,,;,;,;,;;LL   .. ... . ...  .::;,;;L;LLzyOK5oGSOGOpb8bO8GOGhASDADSDSDSDASDSDASDASDASVXVEWETJ%676.    . . ..\"", true);
	set_clantag("", "");
end

local function Clantag()
	if gui.GetValue("rbot.master") == true and enabled:GetValue() == true and clantag:GetValue() == true then
		local curtime = math.floor(globals.CurTime() * 2.3);
    	if old_time ~= curtime then
    	    set_clantag(animation[curtime % #animation+1], animation[curtime % #animation+1]);
    	end
    	old_time = curtime;
		clantagset = 1;
	else
		if clantagset == 1 then
            clantagset = 0;
            set_clantag("", "");
        end
	end
end

local shot_print_chat = (function()
    --[[
        YOU CAN CUSTOMIZE MESSAGES MORE HERE
    ]]
    local function formatHitMessage(name, damage, hitbox, remaining)
        local msg = string.format("\04%s damage to %s %s (%s hp left) ", damage, name, hitbox, remaining)
        return msg
    end

    local function formatHitMessage2(name, damage, hitbox, remaining)
        local msg = string.format("\09%s damage to %s %s (%s hp left) ", damage, name, hitbox, remaining)
        return msg
    end

    local function formatLocalHit(name, damage, hitbox, remaining, victim)
        local msg = string.format("\11%s did %s damage to %s %s (%s hp left) ", name, damage, victim, hitbox, remaining)
        return msg
    end

    --[[
        Important script vars 
    ]]
    local local_player = entities.GetLocalPlayer()

    local Hit_Groups = {"GENERIC", "HEAD", "CHEST", "STOMACH", "LEFT ARM", "RIGHT ARM", "LEFT LEG", "RIGHT LEG", "NECK"}

    local Cache = {
        current_target = nil,
        mouse_pressed = false,
        weapon_name = "",
        bullet_impact = {},
        player_hurt = {},
        view_angles = {
            [1] = nil,
            [2] = nil
        }
    }

    local Event_Table = {}
    --[[ 
        Helpers
    ]]
    local function ClearCache()
        Cache.weapon_name = ""
        Cache.bullet_impact = {}
        Cache.player_hurt = {}
        Cache.mouse_pressed = false
    end

    local function IsGrenade(weapon_name)
        for i, str in ipairs({"grenade", "flash", "decoy", "molotov", "mine", "charge"}) do
            if string.find(weapon_name, str) then return true end
        end

        return false
    end

    local function CalculateSpread(view_angles, src, dst)
        local dst_wish = src + view_angles:Forward() * 1000

        local AB = src - dst
        local AC = src - dst_wish

        local deg = math.deg(math.acos(AB:Dot(AC) / (AB:Length() * AC:Length())))

        return deg
    end

    local function DisplayShot(shot)
        local msg = "nil"
        local hit_target = false

        -- log each hit in path and mark unintended ones as yellow
        if logOther:GetValue() or logHits:GetValue() then
            for i, hurt in ipairs(shot.hurts) do 
                if not entities.GetLocalPlayer():IsAlive() then return end
                local hurt_name = entities.GetByIndex( hurt.index ):GetName()
                local hurt_where = Hit_Groups[hurt.hitgroup]

                -- keep track if we hit target so we can log a miss is we hit someone else but not target
                hit_target = shot.target:GetIndex() == hurt.index or hit_target

                if shot.target:GetIndex() == hurt.index then
                    msg = formatHitMessage(hurt_name, hurt.damage, hurt_where, hurt.health)
                    if printchat:GetValue() == true then
                        client.PrintChat("\01[\02AIMWARE\01] " .. msg .. "\n")
                    end
                    if printconsole:GetValue() == true then
                        client.color_log(252,252,252, "[")
                        client.color_log(255,0,0, "AIMWARE")
                        client.color_log(252,252,252, "] ")
                        client.color_log(64,255,64, msg .. "\n")
                    end
                else
                    msg = formatHitMessage2(hurt_name, hurt.damage, hurt_where, hurt.health)
                    if printchat:GetValue() == true then
                        client.PrintChat("\01[\02AIMWARE\01] " .. msg .. "\n")
                    end
                    if printconsole:GetValue() == true then
                        client.color_log(252,252,252, "[")
                        client.color_log(255,0,0, "AIMWARE")
                        client.color_log(252,252,252, "] ")
                        client.color_log(237,228,122, msg .. "\n")
                    end
                end
            end
        end

        -- if we didnt hit target
        -- or it was a manual shot
        if logMiss:GetValue() and (shot.type == "aimbot" and shot.target and not hit_target) then 
            if shot.spread < "0.8" then
                if printchat:GetValue() == true then
                    client.PrintChat("\01[\02AIMWARE\01] \07Missed shot due to ? (" .. shot.spread .. ")\n")
                end
                if printconsole:GetValue() == true then
                    client.color_log(252,252,252, "[")
                    client.color_log(255,64,64, "AIMWARE")
                    client.color_log(252,252,252, "] ")
                    client.color_log(255,64,64, "Missed shot due to ? (" .. shot.spread .. ")\n")
                end
            end
        
            if shot.spread > "0.8" then
                if printchat:GetValue() == true then
                    client.PrintChat("\01[\02AIMWARE\01] \07Missed shot due to spread (" .. shot.spread .. ")\n")
                end
                if printconsole:GetValue() == true then
                    client.color_log(252,252,252, "[")
                    client.color_log(255,0,0, "AIMWARE")
                    client.color_log(252,252,252, "] ")
                    client.color_log(255,64,64, "Missed shot due to spread (" .. shot.spread .. ")\n")
                end
            end
        end
    end
    --[[
        Events
    ]]
    Event_Table['weapon_fire'] = function(weapon_fire)
        local player_index = entities.GetByUserID(weapon_fire:GetInt("userid")):GetIndex()

        if player_index ~= local_player:GetIndex() then return end

        local weapon = string.gsub(weapon_fire:GetString("weapon"), "weapon_", "")
        local eye_pos = local_player:GetAbsOrigin() + local_player:GetPropVector("localdata", "m_vecViewOffset[0]")

        table.insert(Cache.bullet_impact, eye_pos)

        Cache.weapon_name = weapon
    end

    Event_Table["bullet_impact"] = function(bullet_impact)
        local player_index = entities.GetByUserID(bullet_impact:GetInt("userid")):GetIndex()

        if player_index ~= local_player:GetIndex() then return end

        local x = bullet_impact:GetFloat("x")
        local y = bullet_impact:GetFloat("y")
        local z = bullet_impact:GetFloat("z")

        local position = Vector3(x,y,z)

        table.insert(Cache.bullet_impact, position)
    end

    Event_Table["player_hurt"] = function(player_hurt)
        local attacker_index = entities.GetByUserID(player_hurt:GetInt("attacker")):GetIndex()

        -- we are not attacker
        if attacker_index ~= local_player:GetIndex() then
            local attacker = entities.GetByUserID(player_hurt:GetInt("attacker"))
            local victim = entities.GetByUserID(player_hurt:GetInt("userid"))
    	    local victim_index = victim:GetIndex()
            local _damage = player_hurt:GetInt("dmg_health")
            local _health = player_hurt:GetInt("health")
            local _hitgroup = player_hurt:GetInt("hitgroup") + 1
            
            table.insert(Cache.player_hurt, {damage = _damage, health = _health, hitgroup = _hitgroup, index = victim_index})

            if victim_index == local_player:GetIndex() and logHurt:GetValue() then
                local msg = formatLocalHit(attacker:GetName(), _damage, Hit_Groups[_hitgroup], _health, victim:GetName())

                if printchat:GetValue() == true then
                    client.PrintChat("\01[\02AIMWARE\01] " .. msg .. "\n")
                end
                if printconsole:GetValue() == true then
                    client.color_log(252,252,252, "[")
                    client.color_log(255,0,0, "AIMWARE")
                    client.color_log(252,252,252, "] ")
                    client.color_log(94,152,217, msg .. "\n")
                end
            end
            ClearCache()
        return end

        local victim = entities.GetByUserID(player_hurt:GetInt("userid"))
    	local victim_index = victim:GetIndex()

        local _damage = player_hurt:GetInt("dmg_health")
        local _health = player_hurt:GetInt("health")
        local _hitgroup = player_hurt:GetInt("hitgroup") + 1

        -- anything but grenade and knife
        if _hitgroup ~= 1  or Cache.weapon_name == "taser" then
            table.insert(Cache.player_hurt, {damage = _damage, health = _health, hitgroup = _hitgroup, index = victim_index})
            return
        end

        -- nades and knife fix
        local msg = formatHitMessage(victim:GetName(), _damage, Hit_Groups[1], _health) 

        if printchat:GetValue() == true then
            client.PrintChat("\01[\02AIMWARE\01] " .. msg .. "\n")
        end
        if printconsole:GetValue() == true then
            client.color_log(252,252,252, "[")
            client.color_log(255,0,0, "AIMWARE")
            client.color_log(252,252,252, "] ")
            client.color_log(0,255,0, msg .. "\n")
        end
    end

    Event_Table["round_prestart"] = function(player_death)
        ClearCache()
    end

    local function handleEvents(event)
        local_player = entities.GetLocalPlayer()
        if event then
            local event_name = event:GetName()
            if Event_Table[event_name] then
                Event_Table[event_name](event);
            end
        end
    end

    --[[
        CreateMove
    ]]
    local function CompileShot(predicted_shot)
        if string.find(Cache.weapon_name, "knife") then return end
        if IsGrenade(Cache.weapon_name) then return end

        local shot_type = Cache.mouse_pressed and "manual" or "aimbot"
        local spread_amt = CalculateSpread(predicted_shot.ang, predicted_shot.pos, Cache.bullet_impact[#Cache.bullet_impact])

        if not predicted_shot.target and #Cache.player_hurt > 0 then
            predicted_shot.target = entities.GetByIndex( Cache.player_hurt[1].index )
        end

        local shot = {
            type = shot_type,
            target = predicted_shot.target,
            weapon = Cache.weapon_name,
            ang = predicted_shot.ang,
            pos = predicted_shot.pos,
            impacts = Cache.bullet_impact,
            hurts = Cache.player_hurt,
            tick = globals.TickCount(),
            spread = string.format("%.3f", spread_amt)
        }

        return shot
    end

    local function HandleViewAngles(cmd)
        Cache.mouse_pressed = input.IsButtonDown( 1 )

        local ping_in_seconds = entities.GetPlayerResources():GetPropInt("m_iPing", local_player:GetIndex()) / 1000
        local ping_in_ticks = math.ceil(ping_in_seconds / globals.TickInterval())
        local longest_lifetime = sv_maxusrcmdprocessticks:GetValue() + (ping_in_ticks * 2)

        -- remove old angles
        local i = 1 
        while i <= 2 do
            if Cache.view_angles[i] and globals.TickCount() - Cache.view_angles[i].tick >= longest_lifetime then
                Cache.view_angles[i] = nil
            end

            i = i + 1
        end

        -- In attack check for getting shot angles
        if bit.band(cmd.buttons, bit.lshift(1,0)) == nil then return end
        if bit.band(cmd.buttons, bit.lshift(1,0)) == bit.lshift(1,0) then
            local shot_pos = local_player:GetAbsOrigin() + local_player:GetPropVector("localdata", "m_vecViewOffset[0]")
            local recoil = local_player:GetPropVector("localdata", "m_Local", "m_aimPunchAngle") * 2
            local shot_angle =  cmd.viewangles

            -- account for recoil
            shot_angle.x = shot_angle.x + recoil.x
            shot_angle.y = shot_angle.y + recoil.y

            -- my best attempt at filtering the correct shot angles and positions
            -- actually works very well
            -- gets first and very last IN_ATTACK tick
            if Cache.view_angles[1] == nil then
                Cache.view_angles[1] = {ang = shot_angle, pos = shot_pos, tick = globals.TickCount(), target = Cache.current_target}
            else
                Cache.view_angles[2] = {ang = shot_angle, pos = shot_pos, tick = globals.TickCount(), target = Cache.current_target}
            end
        end
    end
    --[[
        Shot stuff
    ]]
    callbacks.Register("Draw", function()
        -- match angles to shots
        if Cache.weapon_name ~= "" then
            -- basic logic for deciding which angle to choose
            local shot_data = Cache.view_angles[1]
            Cache.view_angles[1] = nil

            if shot_data == nil then
                shot_data = Cache.view_angles[2]
                Cache.view_angles[2] = nil
            end

            -- the actual function of the script
            if shot_data then
                local shot = CompileShot(shot_data)

                if shot then
                    DisplayShot(shot)
                end
                -- clear cache shit
                ClearCache()
            end
        end
    end)

    --[[
        Target Stuff (BUGGY AS FUCK)
    ]]
    local function UpdateTarget(entity)
        if entity:GetName() then
            Cache.current_target = entity
        else
            Cache.current_target = nil
        end
    end
    --[[
        Boring Shit
    ]]
    callbacks.Register( "CreateMove", HandleViewAngles)
    callbacks.Register( "AimbotTarget", UpdateTarget)
    callbacks.Register( "FireGameEvent", handleEvents)

    for k, v in pairs(Event_Table) do
        client.AllowListener(k)
    end
end)()

client.AllowListener("cs_win_panel_match");
callbacks.Register( "CreateMove", LegitAA);
callbacks.Register( "Draw", EngineRadar);
callbacks.Register( "Draw", idealTick);
callbacks.Register( "Draw", Antiaim);
callbacks.Register( "Draw", Indicators);
callbacks.Register( "Draw", GuiStuff);
callbacks.Register( "Draw", Clantag);
callbacks.Register( "FireGameEvent", AutoDisconnect);
callbacks.Register( "Unload", OnUnload);