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
local VERSION_NUMBER = "1.5";
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

--Variables
ffi.cdef[[
	typedef void* (__cdecl* tCreateInterface)(const char* name, int* returnCode);
    typedef int(__fastcall* clantag_t)(const char*, const char*);
	void* GetProcAddress(void* hModule, const char* lpProcName);
    void* GetModuleHandleA(const char* lpModuleName);
]]

local function GetInterface(dll_name, interface_name)
    local CreateInterface = ffi.cast("tCreateInterface", ffi.C.GetProcAddress(ffi.C.GetModuleHandleA(dll_name), "CreateInterface"))
    local interface = CreateInterface(interface_name, ffi.new("int*"))
    return interface
end

local fn_change_clantag = mem.FindPattern("engine.dll", "53 56 57 8B DA 8B F9 FF 15")
local set_clantag = ffi.cast("clantag_t", fn_change_clantag)
local GameClientExports = ffi.cast("void***", GetInterface("client.dll", "GameClientExports001"))[0];
local IsPlayerGameVoiceMuted = ffi.cast("bool(__thiscall*)(void*, int playerIndex)", GameClientExports[1]);
local MutePlayerGameVoice = ffi.cast("void(__thiscall*)(void*, int playerIndex)", GameClientExports[2]);
local UnmutePlayerGameVoice = ffi.cast("void(__thiscall*)(void*, int playerIndex)", GameClientExports[3]);
local fileSystem = ffi.cast("int*", GetInterface("filesystem_stdio.dll", "VFileSystem017"))


local w, h = draw.GetScreenSize();
local x = w/2;
local y = h/2;
local old_time = 0
local kek = 1;
local gaben = 1;
local current_angle = 0;
local drawLeft = 0;
local drawRight = 0;
local drawBack = 0;
local stupidlagsync = 1;
local stupidlagsync2 = 1;
local stupidlagsync3 = 1;
local clantagset = 0;
local storedTick = 0
local saved = false;
local overriden = false;
local manually_changing = false;
local old_lby_offset = gui.GetValue("rbot.antiaim.base.lby");
local old_rotation_offset = gui.GetValue("rbot.antiaim.base.rotation");
local calibri = draw.CreateFont("Calibri", 22, 1000)
local tbl = {};
local crouched_ticks = {};
cache = {};
cacheAA = {};

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

local phrases = {
    "1'd by Sessuhook",
    "Sessuhook on top",
    "Get good get Sessuhook",
    "Tapping NNs since 2018",
    "Get owned by Sessuhook",
    "Haist vittu - Sessuhook"
}

--Menu Related/Gui
local rb_ref = gui.Reference("Ragebot");
local tab = gui.Tab(rb_ref, "sestain", ("Sestain's Script " .. VERSION_NUMBER));
local gb_main = gui.Groupbox(tab, "Main", 15, 15, 250, 400);
local enabled = gui.Checkbox(gb_main, "enabled", "Enabled", 1);
local category = gui.Combobox(gb_main, "category", "Category", "Anti-Aim", "Visuals", "Misc");

--AntiAim Tab
local aa = gui.Groupbox(tab, "Anti-Aim", 15, 175, 250, 400);
local lagsync = gui.Checkbox(aa, "lagsync", "Lagsync", 0);
local legitaa = gui.Checkbox(aa, "legitaa", "Legit AA on Use", 1);
local aa2 = gui.Groupbox(tab, "Anti-Aim (Binds/Sliders)", 280, 15, 335, 400);
local invert_key = gui.Keybox(aa2, "ikey", "Invert Key", 6);
local left_key = gui.Keybox(aa2, "left", "Manual AA to Left", 37);
local back_key = gui.Keybox(aa2,"back","Manual AA to Back", 40);
local right_key = gui.Keybox(aa2,"right","Manual AA to Right", 39);
local yaw_angle = gui.Slider(aa2, "yawangle", "Yaw Offset", 0, -180, 180);
local jitter_amount = gui.Slider(aa2, "jitteramount", "Jitter Amount", 0, -180, 180);
local rotation_angle = gui.Slider(aa2, "rotationangle", "Rotation Offset", old_rotation_offset, -58, 58);
local lby_angle = gui.Slider(aa2, "lbyangle", "LBY Offset", old_lby_offset, -180, 180);

--Visuals Tab
local sb = gui.Groupbox(tab, "Visuals", 15, 175, 250, 400);
local hudweapon_enable = gui.Checkbox(sb, "hudweapon.enabled", "Equipment on scoreboard", 0)
local menu = {filter = gui.Multibox(sb, "Weapon filter")}
local itemList = {"Primary", "Secondary", "Knife/Taser", "Grenades", "C4", "Defuser", "Armor", "Other"}
for index, value in ipairs(itemList) do
	menu["item_" .. index] = gui.Checkbox(menu.filter, "hudweapon.item_" .. index, value, false)
end
local hudweapon_color = gui.ColorPicker(hudweapon_enable, "hudweapon.color", "Blur color", 136, 71, 255, 255)
local player_weapons = {}
for i = 0, 64 do
	player_weapons[i] = {}
end
local clear_equip = gui.Button(sb, "Clear equipments data", function()
	for i = 0, 64 do
		player_weapons[i] = {}
	end
end)

local visual = gui.Groupbox(tab, "Visuals", 280, 15, 335, 400);
local desync_indicator = gui.Checkbox(visual, "desync_indicator", "Desync Indicator", 1);
local desync_bgcp = gui.ColorPicker(desync_indicator, "desync_bgclr", "Desync Indicator's Background Color", 0,0,0,128);
local desync_icp = gui.ColorPicker(desync_indicator, "desync_iclr", "Desync Indicator's Color", 0,135,206,235);
local manual_indicator = gui.Checkbox(visual, "manual_indicator", "Manual AA Indicator", 1);
local manual_bgcp = gui.ColorPicker(manual_indicator, "manual_bgclr", "Manual AA Indicator's Background Color", 0,0,0,128);
local manual_icp = gui.ColorPicker(manual_indicator, "manual_iclr", "Manual AA Indicator's Color", 235,235,235,235);
local info = gui.Checkbox( visual, "info", "Info bar", 0 );

local extraesp = gui.Multibox(visual, "ESP");
local flags_fakeduck = gui.Checkbox(extraesp, "fdflag", "Fakeduck Flag", 1)
local enemy_ammo = gui.Checkbox(extraesp, "enemyammo", "Enemy Ammo ESP", 1)

local extraind = gui.Multibox(visual, "Extra Indicators");
local circleind = gui.Checkbox(extraind, "extra_circle", "AA Circle", 1);
local shiftind = gui.Checkbox(extraind, "extra_shift", "Shift on Shot", 1);
local dtind = gui.Checkbox(extraind, "extra_dt", "Doubletap", 1);
local fdtind = gui.Checkbox(extraind, "extra_fd", "Fake Duck", 1);
local extra_icp = gui.ColorPicker(visual, "extra_iclr", "Extra Indicator's Color", 255,75,15,255);
local extra_bgcp = gui.ColorPicker(visual, "extra_bgclr", "Extra Indicator's Background Color", 0,0,0,128);
local radiusaa = gui.Slider(visual, "extra_rad", "AA Circle Radius", 30, 10, 100);
local thicknessaa = gui.Slider(visual, "extra_thickness", "AA Circle Thickness", 3, 1, 50);

--Misc Tab
local misc = gui.Groupbox(tab, "Misc", 280, 15, 335, 400);
local autodisconnect = gui.Checkbox(misc, "autodisconnect", "Auto Disconnect", 0);
local autounmute = gui.Checkbox(misc, "autounmute", "Auto Unmute", 0);
local clantag = gui.Checkbox(misc, "clantag", "Clantag", 0);
local idealtick = gui.Checkbox(misc, "idealtick", "Ideal Tick", 0);
local killsay = gui.Checkbox(misc, "killsay", "Killsay", 0);

--Descriptions
hudweapon_enable:SetDescription("Made by thekorol.");
idealtick:SetDescription("From nxzAA by naz.");

--Saves values for later
local function Cache_fn()
	cache.scoutDT = gui.GetValue("rbot.accuracy.weapon.scout.doublefire");
    cache.awpDT = gui.GetValue("rbot.accuracy.weapon.sniper.doublefire");
    cache.hpistolDT = gui.GetValue("rbot.accuracy.weapon.hpistol.doublefire");
    cache.fakeLatency = gui.GetValue("misc.fakelatency.enable");
    cache.fakeLatencyAmount = gui.GetValue("misc.fakelatency.amount");
    cache.fakeLag = gui.GetValue("misc.fakelag.enable");
    cache.fakeLagAmount = gui.GetValue("misc.fakelag.factor");
end

local function Cache_AA()
	cacheAA.Base = gui.GetValue("rbot.antiaim.base");
	cacheAA.Edges = gui.GetValue("rbot.antiaim.advanced.autodir.edges");
	cacheAA.Targets = gui.GetValue("rbot.antiaim.advanced.autodir.targets");
	cacheAA.Pitch = gui.GetValue("rbot.antiaim.advanced.pitch");
	cacheAA.Use = gui.GetValue("rbot.antiaim.condition.use");
end

--Function for AntiAim Yaw Slider + Jitter
local function NormalizeYaw(yaw)
    while yaw > 180 do yaw = yaw - 360 end
    while yaw < -180 do yaw = yaw + 360 end
    return yaw
end

--Unmutes people who has automute
local function Unmute()
    for idx = 1, globals.MaxClients() do
        if (idx ~= entities.GetLocalPlayer()) then
			-- You can make this to auto mute everyone but you can do whatever you want with this.
            --if (not IsPlayerGameVoiceMuted(GameClientExports, idx) and not entities.GetLocalPlayer()) then
            --    MutePlayerGameVoice(GameClientExports, idx)
            --end
            
            if (IsPlayerGameVoiceMuted(GameClientExports, idx)) then
                UnmutePlayerGameVoice(GameClientExports, idx)
            end
        end
    end
end

--Gets phrases for killsay
local function get_phrase()
    return phrases[utils.RandomInt(1, #phrases)]:gsub('\"', '')
end

--Lagsync (idk what to type here...)
local function Lagsync()
	if lagsync:GetValue() then
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
				local lby = current_angle == 0 and -120 or 120;
				local rotation = current_angle == 0 and -58 or 58;
				lby = 0 and -lby or lby;
				rotation = 0 and -rotation or rotation;
				gui.SetValue("rbot.antiaim.base.lby", -lby);
				gui.SetValue("rbot.antiaim.base.rotation", rotation);
			else
				gui.SetValue("rbot.antiaim.base.lby", lby);
				gui.SetValue("rbot.antiaim.base.rotation", -rotation);
			end
		end
	end
end

--Normal AA features
local function Regular()
	if lagsync:GetValue() then return end

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
		end
	else
		if current_angle ~= 2 then
			local lby = current_angle == 0 and -120 or 120;
			local rotation = current_angle == 0 and -58 or 58;
			lby = 0 and -lby or lby;
			rotation = 0 and -rotation or rotation;
			gui.SetValue("rbot.antiaim.base.lby", -lby);
			gui.SetValue("rbot.antiaim.base.rotation", rotation);
		else
			gui.SetValue("rbot.antiaim.base.lby", lby);
			gui.SetValue("rbot.antiaim.base.rotation", -rotation);
		end
	end
end

--Umm fakeduck indicator stuff for math
local function toBits(num)
    local t = { }
    while num > 0 do
      rest = math.fmod(num,2)
      t[#t+1] = rest
      num = (num-rest) / 2
    end

    return t
end

local AmmoESP = function(esp)
	if gui.GetValue("rbot.master") and enabled:GetValue() and enemy_ammo:GetValue() then
		local e = esp:GetEntity();
    	if (e:IsPlayer() ~= true or entities.GetLocalPlayer():GetTeamNumber() == e:GetTeamNumber()) or not e:IsAlive() then return end
    	esp:Color(62, 214, 209, 255)
    	ActiveWeapon = e:GetPropEntity("m_hActiveWeapon")
    	esp:AddTextBottom(ActiveWeapon:GetProp("m_iClip1") .. "/" .. ActiveWeapon:GetProp("m_iPrimaryReserveAmmoCount") )
	end
end

--Antiaim (Invert key, Manual AA, Jitter, Lagsync)
local AntiAim = function()
	if gui.GetValue("rbot.master") and enabled:GetValue() then
		if invert_key:GetValue() ~= 0 then
			if input.IsButtonPressed(invert_key:GetValue()) then
				current_angle = current_angle == 0 and 1 or 0;
			end
		end

		Lagsync();
		Regular();
	end
end

--Auto Disconnects from game when it finishes.
local AutoDisconnect = function(event)
	if gui.GetValue("rbot.master") and enabled:GetValue() and autodisconnect:GetValue() then
		if event:GetName() and event:GetName() == "cs_win_panel_match" then
    	    client.Command("disconnect", true);
		end
	end
end

--Auto unmutes people who has automute
local AutoUnmute = function(event)
	if gui.GetValue("rbot.master") and enabled:GetValue() and autounmute:GetValue() then
		if event:GetName() and event:GetName() == "player_team" then
    	    Unmute();
		end
	end
end

--Sessuhook clantag
local Clantag = function()
	if gui.GetValue("rbot.master") and enabled:GetValue() and clantag:GetValue() then
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

--EngineRadar shows enemies on ingame radar.
local EngineRadar = function()
	if gui.GetValue("rbot.master") and enabled:GetValue() then
    	for index, Player in pairs(entities.FindByClass("CCSPlayer")) do
    	    Player:SetProp("m_bSpotted", 1);
    	end
	end
end

--Fakeduck flag on ESP
local FakeduckFlag = function(Builder)
	local g_Local = entities.GetLocalPlayer()
    local Entity = Builder:GetEntity()
    if gui.GetValue("rbot.master") and enabled:GetValue() and flags_fakeduck:GetValue() then
		if g_Local == nil or Entity == nil or not Entity:IsPlayer() or not Entity:IsAlive() or Entity:GetTeamNumber() == g_Local:GetTeamNumber() then return end
		local index = Entity:GetIndex()
		local m_flDuckAmount = Entity:GetProp("m_flDuckAmount")
		local m_flDuckSpeed = Entity:GetProp("m_flDuckSpeed")
		local m_fFlags = Entity:GetProp("m_fFlags")
		if crouched_ticks[index] == nil then 
			crouched_ticks[index] = 0
		end
		if m_flDuckSpeed ~= nil and m_flDuckAmount ~= nil then
			if m_flDuckSpeed == 8 and m_flDuckAmount <= 0.9 and m_flDuckAmount > 0.01 and toBits(m_fFlags)[1] == 1 then
				if storedTick ~= globals.TickCount() then
					crouched_ticks[index] = crouched_ticks[index] + 1
					storedTick = globals.TickCount()
				end
				if crouched_ticks[index] >= 5 then 
					Builder:Color(255, 255, 0, 255)
					Builder:AddTextRight("FD")
				end
			else
				crouched_ticks[index] = 0
			end
		end
	end
end

--Here is some gui stuff
local Gui = function()
	local tradition = enabled:GetValue() == false;
	category:SetDisabled(tradition);
	lagsync:SetDisabled(tradition);
	legitaa:SetDisabled(tradition);
	invert_key:SetDisabled(tradition);
	left_key:SetDisabled(tradition);
	back_key:SetDisabled(tradition);
	right_key:SetDisabled(tradition);
	yaw_angle:SetDisabled(tradition);
	jitter_amount:SetDisabled(tradition);
	rotation_angle:SetDisabled(tradition);
	lby_angle:SetDisabled(tradition);
	desync_indicator:SetDisabled(tradition);
	desync_bgcp:SetDisabled(tradition);
	desync_icp:SetDisabled(tradition);
	manual_indicator:SetDisabled(tradition);
	manual_bgcp:SetDisabled(tradition);
	manual_icp:SetDisabled(tradition);
	extraind:SetDisabled(tradition);
	extra_icp:SetDisabled(tradition);
	extra_bgcp:SetDisabled(tradition);
	radiusaa:SetDisabled(tradition);
	thicknessaa:SetDisabled(tradition);
	autodisconnect:SetDisabled(tradition);
	autounmute:SetDisabled(tradition);
	clantag:SetDisabled(tradition);
	idealtick:SetDisabled(tradition);
	killsay:SetDisabled(tradition);
	hudweapon_enable:SetDisabled(tradition);
	hudweapon_color:SetDisabled(tradition);
	clear_equip:SetDisabled(tradition);
	menu.filter:SetDisabled(tradition);
	extraesp:SetDisabled(tradition);

    desync_bgcp:SetInvisible(not desync_indicator:GetValue());
	desync_icp:SetInvisible(not desync_indicator:GetValue());
    manual_bgcp:SetInvisible(not manual_indicator:GetValue());
	manual_icp:SetInvisible(not manual_indicator:GetValue());
	radiusaa:SetInvisible(not circleind:GetValue());
	thicknessaa:SetInvisible(not circleind:GetValue());
    extra_icp:SetInvisible(not shiftind:GetValue() and not dtind:GetValue() and not fdtind:GetValue() and not circleind:GetValue());
    extra_bgcp:SetInvisible(not shiftind:GetValue() and not dtind:GetValue() and not fdtind:GetValue() and not circleind:GetValue());
	menu.filter:SetInvisible(not hudweapon_enable:GetValue());
	clear_equip:SetInvisible(not hudweapon_enable:GetValue());

	if category:GetValue() == 0 then
		aa:SetInvisible(false);
		aa2:SetInvisible(false);
		visual:SetInvisible(true);
		sb:SetInvisible(true);
		misc:SetInvisible(true);
	elseif category:GetValue() == 1 then
		aa:SetInvisible(true);
		aa2:SetInvisible(true);
		visual:SetInvisible(false);
		sb:SetInvisible(false);
		misc:SetInvisible(true);
	elseif category:GetValue() == 2 then
		aa:SetInvisible(true);
		aa2:SetInvisible(true);
		visual:SetInvisible(true);
		sb:SetInvisible(true);
		misc:SetInvisible(false);
	end
end

--IdealTick from nxzAA by naz
local IdealTick = function()
	if gui.GetValue("rbot.master") and enabled:GetValue() and idealtick:GetValue() then
    	local quickPeakKey = gui.GetValue("rbot.accuracy.movement.autopeekkey")
		if quickPeakKey ~= 0 and input.IsButtonDown(quickPeakKey) and not overriden then
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
			Cache_fn();
		end
	end
end

--Sessuhook Killsay.
local Killsay = function(event)
	if gui.GetValue("rbot.master") and enabled:GetValue() and killsay:GetValue() then
		if event:GetName() and event:GetName() == "player_death" then
    	    local me = entities.GetLocalPlayer()
    		local victim = entities.GetByUserID(event:GetInt("userid"))
    		local attacker = entities.GetByUserID(event:GetInt("attacker"))

    		if victim == attacker or attacker ~= me then return end

    		client.Command('say "' .. get_phrase() .. '"')
		end
	end
end

--LegitAA on Use.
local LegitAA = function(cmd)
	if gui.GetValue("rbot.master") == true and enabled:GetValue() == true and legitaa:GetValue() == true then
		if bit.band(cmd.buttons, bit.lshift(1, 5)) == 0 then
			if saved then
				gui.SetValue("rbot.antiaim.condition.use", cacheAA.Use);
    			gui.SetValue("rbot.antiaim.advanced.pitch", cacheAA.Pitch);
    			gui.SetValue("rbot.antiaim.advanced.autodir.edges", cacheAA.Edges);
    			gui.SetValue("rbot.antiaim.advanced.autodir.targets", cacheAA.Targets);
    			gui.SetValue("rbot.antiaim.base", cacheAA.Base);
				saved = false;
				kek = 1;
				gaben = 1;
			end
		return end
		
		if not cmd.sendpacket then return end
		
		if not saved then
			Cache_AA();
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

--Visuals for indicators.
local Visuals = function()
	if gui.GetValue("rbot.master") and enabled:GetValue() then
		if not entities.GetLocalPlayer() then return end
		if not entities.GetLocalPlayer():IsAlive() then return end
		local desync_bgr, desync_bgg, desync_bgb, desync_bga = desync_bgcp:GetValue();
		local desync_ir, desync_ig, desync_ib, desync_ia = desync_icp:GetValue();
		local manual_bgr, manual_bgg, manual_bgb, manual_bga = manual_bgcp:GetValue();
		local manual_ir, manual_ig, manual_ib, manual_ia = manual_icp:GetValue();
		local headpos = entities.GetLocalPlayer():GetHitboxPosition(0)
        local origin = entities.GetLocalPlayer():GetAbsOrigin()
        local angle = (headpos - origin):Angles()
        local cam_angle = engine.GetViewAngles()
        local diff = cam_angle.y - angle.y
        local radius = radiusaa:GetValue()
        local thickness = thicknessaa:GetValue()
        local bgr, bgg, bgb, bga = extra_bgcp:GetValue()
        local ir, ig, ib, ia = extra_icp:GetValue()
		local offset = 1.5
		if thickness > radius then
            thickness = radius
        end

        local ang = (diff * -1)/8
        if ang < 0 then ang = 22.5 + (22.5 - math.abs(ang)) end

		if desync_indicator:GetValue() then
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

		if manual_indicator:GetValue() then
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

		if circleind:GetValue() then
        	for steps = 1, 45, 1 do

        	    local sin_cur = math.sin(math.rad(steps * 8 + 180))
        	    local sin_old = math.sin(math.rad(steps * 8 - 8 + 180))
        	    local cos_cur = math.cos(math.rad(steps * 8 + 180))
        	    local cos_old = math.cos(math.rad(steps * 8 - 8 + 180))
			
        	    local cur_point = nil;
        	    local old_point = nil;

        	    cur_point = {x + sin_cur * radius, y + cos_cur * radius};    
        	    old_point = {x + sin_old * radius, y + cos_old * radius};

        	    local cur_point2 = nil;
        	    local old_point2 = nil;

        	    cur_point2 = {x + sin_cur * (radius - thickness), y + cos_cur * (radius - thickness)};    
        	    old_point2 = {x + sin_old * (radius - thickness), y + cos_old * (radius - thickness)};
			
        	    if steps >= ang - 2 and steps <= ang + 2 then
        	        draw.Color(ir, ig, ib, ia)
        	    else
        	        draw.Color(bgr, bgg, bgb, bga)
        	    end

        	    if ang - 2 < 0 and steps >= 45 + (ang - 2) then
        	        draw.Color(ir, ig, ib, ia)
        	    end
        	    if ang + 2 > 45 and steps <= (ang + 2) - 45 then
        	        draw.Color(ir, ig, ib, ia)
				end
			
        	    draw.Triangle(cur_point[1], cur_point[2], old_point[1], old_point[2], old_point2[1], old_point2[2])
        	    draw.Triangle(cur_point2[1], cur_point2[2], old_point2[1], old_point2[2], cur_point[1], cur_point[2])    
			
        	end
		end

		draw.SetFont(calibri)
        if shiftind:GetValue() then
            offset = offset + 1
            if gui.GetValue("rbot.antiaim.condition.shiftonshot") then
                draw.Color(ir, ig, ib, ia)
            else
                draw.Color(bgr, bgg, bgb, bga)
            end
            draw.TextShadow(x - draw.GetTextSize("HIDE SHOTS")/2, y + radius + offset * 18, "HIDE SHOTS")
        end

        if dtind:GetValue() then
            offset = offset + 1
            if gui.GetValue("rbot.accuracy.weapon.asniper.doublefire") ~= 0 then
                draw.Color(ir, ig, ib, ia)
            else
                draw.Color(bgr, bgg, bgb, bga)
            end
            draw.TextShadow(x - draw.GetTextSize("DOUBLE TAP")/2, y + radius + offset * 18, "DOUBLE TAP")
        end

        if fdtind:GetValue() then
            offset = offset + 1
            if gui.GetValue("rbot.antiaim.extra.fakecrouchkey") ~= 0 then
				if input.IsButtonDown(gui.GetValue("rbot.antiaim.extra.fakecrouchkey")) then
					draw.Color(ir, ig, ib, ia)
				else
					draw.Color(bgr, bgg, bgb, bga)
				end
			end
            draw.TextShadow(x - draw.GetTextSize("FAKE DUCK")/2, y + radius + offset * 18, "FAKE DUCK")
        end
	end
end

--Scoreboard Equipment by thekorol
local Score = (function() 
	--©thekorol
	local console_handlers = {}
	function string:split(sep)
		local sep, fields = sep or ":", {}
		local pattern = string.format("([^%s]+)", sep)
		self:gsub(pattern, function(c)
			fields[#fields + 1] = c
		end)
		return fields
	end
	local weapon_type_int = {
		1,
		1,
		1,
		1,
		[7] = 3,
		[8] = 3,
		[9] = 5,
		[10] = 3,
		[11] = 5,
		[13] = 3,
		[14] = 6,
		[16] = 3,
		[17] = 2,
		[19] = 2,
		[20] = 19,
		[23] = 2,
		[24] = 2,
		[25] = 4,
		[26] = 2,
		[27] = 4,
		[28] = 6,
		[29] = 4,
		[30] = 1,
		[31] = 0,
		[32] = 1,
		[33] = 2,
		[34] = 2,
		[35] = 4,
		[36] = 1,
		[37] = 19,
		[38] = 5,
		[39] = 3,
		[40] = 5,
		[41] = 0,
		[42] = 0,
		[43] = 9,
		[44] = 9,
		[45] = 9,
		[46] = 9,
		[47] = 9,
		[48] = 9,
		[49] = 7,
		[50] = 19,
		[51] = 19,
		[52] = 19,
		[55] = 19,
		[56] = 19,
		[57] = 11,
		[59] = 0,
		[60] = 3,
		[61] = 1,
		[63] = 1,
		[64] = 1,
		[68] = 9,
		[69] = 12,
		[70] = 13,
		[72] = 15,
		[74] = 16,
		[75] = 16,
		[76] = 16,
		[78] = 16,
		[80] = 0,
		[81] = 9,
		[82] = 9,
		[83] = 9,
		[84] = 9,
		[85] = 14,
		[500] = 0,
		[503] = 0,
		[505] = 0,
		[506] = 0,
		[507] = 0,
		[508] = 0,
		[509] = 0,
		[512] = 0,
		[514] = 0,
		[515] = 0,
		[516] = 0,
		[517] = 0,
		[518] = 0,
		[519] = 0,
		[520] = 0,
		[521] = 0,
		[522] = 0,
		[523] = 0,
		[525] = 0
	}
	local wep_type = {taser = 0, knife = 0, pistol = 1, smg = 2, rifle = 3, shotgun = 4, sniperrifle = 5, machinegun = 6, c4 = 7, grenade = 9, stackableitem = 11, fists = 12, breachcharge = 13, bumpmine = 14, tablet = 15, melee = 16, equipment = 19}
	local function getWeaponType(wepIdx)
		local typeInt = weapon_type_int[tonumber(wepIdx)]
		for index, value in pairs(wep_type) do
			if value == typeInt then
				return index ~= 0 and index or (tonumber(wepIdx) == 31 and "taser" or "knife")
			end
		end
	end

	local function register_console_handler(command, handler, force)
		if console_handlers[command] and not force then
			return false
		end
		console_handlers[command] = handler
		return true
	end
	-- Console input
	callbacks.Register("SendStringCmd", "lib_console_input", function(c)
		local raw_console_input = c:Get() -- Maximum 255 chars
		local parsed_console_input = raw_console_input:split(" ")
		local command = table.remove(parsed_console_input, 1)
		local str = ""
		for index, value in ipairs(parsed_console_input) do
			str = str .. value .. " "
		end
		if console_handlers[command] and console_handlers[command](str:sub(1, -2)) then
			c:Set("\0")
		end
	end)
	local main = [====[
		if (typeof(SClient) == 'undefined' && $.GetContextPanel().id == "CSGOHud") {
	        SClient = (function () {
	            $.Msg("Scoreboard Weapon injected successfully! Welcome : " + MyPersonaAPI.GetName())
	            var handlers = {}
	            let registerHandler = function (type, callback) {
	                handlers[type] = callback
	            }
	            let receivedHandler = function (message) {
	                if (handlers[message.type]) {
	                    handlers[message.type](message)
	                }
	            }
	            return {
	                register_handler: registerHandler,
	                receive: receivedHandler
	            }
	        })()
	    }
	    if ($.GetContextPanel().id == "CSGOHud") { $.Schedule(1, ()=>{GameInterfaceAPI.ConsoleCommand("!panoCall e_PanelWeaponLoaded")}) }
	    if (typeof(SImageManager) == 'undefined' && $.GetContextPanel().id == "CSGOHud") {
	        SImageManager = (function () {
	            var HashMap = function HashMap() {
	                var length = 0;
	                var obj = new Object();
	                this.isEmpty = function () {
	                    return length == 0;
	                };
	                this.containsKey = function (key) {
	                    return (key in obj);
	                };
	                this.containsValue = function (value) {
	                    for (var key in obj) {
	                        if (obj[key] == value) {
	                            return true;
	                        }
	                    }
	                    return false;
	                };
	                this.put = function (key, value) {
	                    if (!this.containsKey(key)) {
	                        length++;
	                    }
	                    obj[key] = value;
	                };
	                this.get = function (key) {
	                    return this.containsKey(key) ? obj[key] : null;
	                };
	                this.remove = function (key) {
	                    if (this.containsKey(key) && (delete obj[key])) {
	                        length--;
	                    }
	                };
	                this.values = function () {
	                    var _values = new Array();
	                    for (var key in obj) {
	                        _values.push(obj[key]);
	                    }
	                    return _values;
	                };
	                this.keySet = function () {
	                    var _keys = new Array();
	                    for (var key in obj) {
	                        _keys.push(key);
	                    }
	                    return _keys;
	                };
	                this.size = function () {
	                    return length;
	                };
	                this.clear = function () {
	                    length = 0;
	                    obj = new Object();
	                };
	            }
	            var ImagePool = new HashMap()
	            class ImageCell {
	                constructor(xuid) {
	                    var updating = false
	                    var lastUpdateWep = ""
	                    var lastUpdateHL = ""
	                    var lastColor = ""
	                    let primaryLut = ['smg', 'rifle', 'heavy']
	                    let partInit = "<root><styles><include src='file://{resources}/styles/csgostyles.css'/><include src='file://{resources}/styles/scoreboard.css'/><include src='file://{resources}/styles/hud/hudweaponselection.css' /></styles><Panel style='margin-right:0px;flow-children:right;horizontal-align:right;'></Panel></root>"
	                    this.getTargetXUID = () => {
	                        return xuid
	                    }
	                    this.getTargetPanel = () => {
	                        var panel
	                        var par = $.GetContextPanel().FindChildTraverse("player-" + xuid)
	                        if (!par)
	                            return
	                        var parent = par.FindChildTraverse("name")
	                        if (!parent)
	                            return
	                        panel = parent.FindChildTraverse("CustomImagePanel")
	                        if (!panel) {
	                            panel = $.CreatePanel("Panel", parent, "CustomImagePanel")
	                        }
	                        return panel
	                    }
	                    this.getState = () => {
	                        return updating
	                    }
	                    this.update = (color, equipments, alpha, hl) => {
	                        let colorRGBtoHex = (color) => {
	                            var rgb = color.split(',')
	                            var r = parseInt(rgb[0])
	                            var g = parseInt(rgb[1])
	                            var b = parseInt(rgb[2])
	                            var hex = "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)
	                            return hex
	                        }
	                        let targetColor = colorRGBtoHex(color)
	                        let panel = this.getTargetPanel()
	                        if (!panel) {return}
	                        if (GameStateAPI.GetPlayerStatus(xuid) == 1) {
	                            panel.RemoveAndDeleteChildren()
	                            return
	                        }
	                        if (lastUpdateHL != hl || lastUpdateWep != equipments.toString() || lastColor != color) {
	                            updating = true
	                            panel.RemoveAndDeleteChildren()
	                            panel.BLoadLayoutFromString(partInit, false, false)
	                            let sortedEQ = []
	                            let nades = []
	                            let others = []
	                            equipments.forEach((item)=>{
	                                let curType = InventoryAPI.GetSlot(InventoryAPI.GetFauxItemIDFromDefAndPaintIndex(parseInt(item), 0))
	                                if(curType == 'grenade'){
	                                    nades.push(item)
	                                } else if (curType == 'secondary') {
	                                    nades.unshift(item)
	                                } else if(primaryLut.includes(curType)) {
	                                    sortedEQ.push(item)
	                                } else {
	                                    others.push(item)
	                                }
	                            })
	                            sortedEQ.concat(nades).concat(others).forEach((item) => {
	                                let cellPanel = $.CreatePanel("Panel", panel, "CustomPanelCell", {
	                                    style: 'margin-right:3px; height:18px;'
	                                })
	                                let nameUnClipped = InventoryAPI.GetItemDefinitionName(InventoryAPI.GetFauxItemIDFromDefAndPaintIndex(parseInt(item), 0))
	                                if (!nameUnClipped)
	                                    return
	                                $.CreatePanel("Image", cellPanel, "CustomImageCell", {
	                                    scaling: 'stretch-to-fit-y-preserve-aspect',
	                                    src: 'file://{images}/icons/equipment/' + nameUnClipped.replace( 'weapon_', '' ).replace('item_defuser', 'defuser') + '.svg',
	                                    style: hl == item ? ('wash-color-fast: white;opacity:' + alpha + ';-s2-mix-blend-mode: normal;img-shadow: ' + targetColor + ' 1px 1px 1.5px 0.5;') : ('wash-color-fast: hsv-transform(#e8e8e8, 0, 0.96, 0.18);opacity:' + (alpha-0.02) + ';-s2-mix-blend-mode: normal;')
	                                })
	                            })
	                        }
	                        lastUpdateHL = hl
	                        lastUpdateWep = equipments.toString()
	                        lastColor = color
	                        updating = false
	                    }
	                }
	            }
	            return {
	                get_cache: (xuid) => {
	                    if (ImagePool.containsKey(xuid)) {
	                        return ImagePool.get(xuid)
	                    } else {
	                        return false
	                    }
	                },
	                dispatch: (entid, color, alpha, weapons, hl) => {
	                    let xuid = GameStateAPI.GetPlayerXuidStringFromEntIndex(entid)
	                    if (ImagePool.containsKey(xuid)) {
	                        var targetCell = ImagePool.get(xuid)
	                        var waitForUpdate = () => {
	                            if (targetCell.getState()){
	                                $.Schedule(0.05, waitForUpdate)
	                            } else {
	                                targetCell.update(color, weapons, alpha, hl)
	                            }
	                        }
	                        waitForUpdate()
	                        return true
	                    } else {
	                        ImagePool.put(xuid, new ImageCell(xuid))
	                        return false
	                    }
	                },
	                destroy: () => {
	                    ImagePool.clear()
	                }
	            }
	        })()
	        $.RegisterForUnhandledEvent("Scoreboard_OnEndOfMatch", SImageManager.destroy)
	        $.RegisterForUnhandledEvent('CSGOShowMainMenu', SImageManager.destroy)
	        $.RegisterForUnhandledEvent('OpenPlayMenu', SImageManager.destroy)
	        $.RegisterForUnhandledEvent('PanoramaComponent_Lobby_ReadyUpForMatch', SImageManager.destroy)
	        SClient.register_handler("updateWeapons", (message) => {
	            if (!SImageManager.dispatch(message.content.xuid, message.content.colorSet, message.content.alpha, message.content.weapons, message.content.highLightWep)) {
	                $.Schedule(0.5, () => {
	                    SImageManager.dispatch(message.content.xuid, message.content.colorSet, message.content.alpha, message.content.weapons, message.content.highLightWep)
	                })
	            }
	        }) 
	    }
	]====]
	-- Client
	local handlers = {}
	local pending = {}
	local Client = {
		updateWeapons = loadstring([=[
	        return function(entid, color, alpha, weapons, highLight)
	            if not weapons or #weapons == 0 then
	                return
	            end
	            alpha = string.format("%1.3f", alpha / 255)
	            local colorStr = "" .. tostring(color[1]) .. "," .. tostring(color[2]) .. "," .. tostring(color[3])
	            local weaponsStr = ""
	            for index, value in ipairs(weapons) do
	                weaponsStr = weaponsStr .. "\"" .. value .. "\"" .. ","
	            end
	            weaponsStr = weaponsStr:sub(1, -2)
	            local panoStr = string.format("if(typeof (SClient) != 'undefined') { SClient.receive(%s) }", string.format([[{type: "%s", content: %s}]], "updateWeapons", string.format([[{xuid: %s, colorSet: "%s", alpha: %s , weapons: [%s], highLightWep:"%s" }]], entid, colorStr, alpha, weaponsStr, highLight)))
	            panorama.RunScript(panoStr)
	        end
	    ]=])(),
		receive = function(message)
			for index, value in ipairs(handlers) do
				if value(message) then
					return
				end
			end
		end,
		register_handler = function(callback)
			table.insert(handlers, callback)
		end
	}
	register_console_handler("!panoCall", function(args)
		Client.receive(args)
		return true
	end, true)
	local last_check_sec = 0
	local loaded = false
	callbacks.Register("Draw", "AWStrangePanoramaFixer", function()
		if loaded then
			return
		end
		local cur = string.format("%1.0f", tostring(globals.RealTime()))
		if last_check_sec ~= cur then
			panorama.RunScript(main)
			last_check_sec = cur
		end
	end)
	Client.register_handler(function(msg)
		if msg == "e_PanelWeaponLoaded" then
			loaded = true
			callbacks.Unregister("Draw", "AWStrangePanoramaFixer") -- Credit: squid for api correction
			return true
		end
	end)
	for i = 0, 64 do
		player_weapons[i] = {}
	end
	local function filter_weapon(wepList)
		for index, value in ipairs(wepList) do
			local wepType = getWeaponType(value)
			if wepType == "smg" or wepType == "rifle" or wepType == "shotgun" or wepType == "sniperrifle" or wepType == "machinegun" then
				if not menu.item_1:GetValue() then
					table.remove(wepList, index)
				end
			elseif wepType == "pistol" then
				if not menu.item_2:GetValue() then
					table.remove(wepList, index)
				end
			elseif wepType == "taser" then
				if not menu.item_3:GetValue() then
					table.remove(wepList, index)
				end
			elseif wepType == "grenade" then
				if not menu.item_4:GetValue() then
					table.remove(wepList, index)
				end
			elseif wepType == "c4" then
				if not menu.item_5:GetValue() then
					table.remove(wepList, index)
				end
			elseif wepType == "defuser" then
				if not menu.item_6:GetValue() then
					table.remove(wepList, index)
				end
			elseif wepType == "armor" then
				if not menu.item_7:GetValue() then
					table.remove(wepList, index)
				end
			else
				if not menu.item_8:GetValue() then
					table.remove(wepList, index)
				end
			end
		end
		return wepList
	end

	local hl = {}
	local function add_weapon(idx, weapon)
		if player_weapons and player_weapons[idx] and #player_weapons[idx] > 0 then
			for i = 1, #player_weapons[idx] do
				if player_weapons[idx][i] == weapon then
					return
				end
			end
		end
		table.insert(player_weapons[idx], weapon)
	end

	local function remove_weapon(idx, weapon)
		if #player_weapons[idx] > 0 then
			for i = 1, #player_weapons[idx] do
				if player_weapons[idx][i] == weapon then
					table.remove(player_weapons[idx], i)
				end
			end
		end
	end

	local function deep_compare(tbl1, tbl2)
		for key1, value1 in pairs(tbl1) do
			local value2 = tbl2[key1]
			if value2 == nil then
				return false
			elseif value1 ~= value2 then
				if type(value1) == "table" and type(value2) == "table" then
					if not deep_compare(value1, value2) then
						return false
					end
				else
					return false
				end
			end
		end
		for key2, _ in pairs(tbl2) do
			if tbl1[key2] == nil then
				return false
			end
		end
		return true
	end

	local lastUpdate = 0
	callbacks.Register("Draw", "hud_weapon_render", function()
		if gui.GetValue("rbot.master") and enabled:GetValue() and hudweapon_enable:GetValue() and entities.GetLocalPlayer() then
			local player_resource = entities.GetPlayerResources()
			local currentUpdatePlayer = globals.FrameCount() % 16
			if currentUpdatePlayer ~= lastUpdate then
				local function updateIdx(currentUpdatePlayer)
					local r, g, b, a = hudweapon_color:GetValue()
					local forced_index = math.floor(currentUpdatePlayer)
					local playerInfo = client.GetPlayerInfo(forced_index)
					if playerInfo and not playerInfo.IsGOTV then
						local player_ent = entities.GetByIndex(forced_index)
						if player_ent and not player_ent:IsDormant() then
							local current_player_data = {}
							local active_weapon = player_ent:GetWeaponID()
							if active_weapon ~= nil then
								if player_ent:GetPropInt("m_bHasDefuser") == 1 then
									table.insert(current_player_data, "55")
								end
								for slot = 0, 63 do
									local weapon_ent = player_ent:GetPropEntity("m_hMyWeapons", string.format("%0.3d", slot))
									if weapon_ent ~= nil then
										local wep_id = weapon_ent:GetWeaponID()
										if wep_id then
											table.insert(current_player_data, tostring(wep_id))
										end
									end
								end
							end
							if player_resource:GetPropInt("m_iArmor", player_ent:GetIndex()) > 0 then
								if player_resource:GetPropInt("m_bHasHelmet", player_ent:GetIndex()) == 1 then
									table.insert(current_player_data, "51")
								else
									table.insert(current_player_data, "50")
								end
							end
							Client.updateWeapons(forced_index, {r, g, b}, a, filter_weapon(current_player_data), tostring(active_weapon))
							return
						elseif player_weapons[forced_index] and #player_weapons[forced_index] > 0 then
							Client.updateWeapons(forced_index, {r, g, b}, a, filter_weapon(player_weapons[forced_index]), hl[forced_index])
							return
						elseif player_weapons[forced_index] and #player_weapons[forced_index] == 0 then
							Client.updateWeapons(player_ent:GetIndex(), {r, g, b}, a, {"dead"}, "dead")
						end
						if not player_ent:IsAlive() then
							Client.updateWeapons(player_ent:GetIndex(), {r, g, b}, a, {"dead"}, "dead")
						end
					end
				end
				updateIdx(currentUpdatePlayer)
				updateIdx(currentUpdatePlayer * 2)
				updateIdx(currentUpdatePlayer * 4)
			end
			lastUpdate = currentUpdatePlayer
		end
	end)
	client.AllowListener("item_equip")
	client.AllowListener("item_pickup")
	client.AllowListener("item_remove")
	client.AllowListener("grenade_thrown")
	client.AllowListener("player_death")
	client.AllowListener("cs_game_disconnected")
	client.AllowListener("cs_match_end_restart")
	client.AllowListener("start_halftime")
	client.AllowListener("game_newmap")
	client.AllowListener("round_end")
	client.AllowListener("bomb_dropped")
	callbacks.Register("FireGameEvent", "hud_weapon_events", function(event)
		local eventName = event:GetName()
		if eventName then
			if eventName == "item_equip" then
				local entid = entities.GetByUserID(event:GetInt("userid")):GetIndex()
				local wepName = event:GetString("defindex")
				hl[entid] = wepName
			elseif eventName == "item_pickup" then
				add_weapon(entities.GetByUserID(event:GetInt("userid")):GetIndex(), event:GetString("defindex"))
			elseif eventName == "item_remove" then
				remove_weapon(entities.GetByUserID(event:GetInt("userid")):GetIndex(), event:GetString("defindex"))
			elseif eventName == "player_death" then
				if player_weapons then
					player_weapons[entities.GetByUserID(event:GetInt("userid")):GetIndex()] = {}
					Client.updateWeapons(entities.GetByUserID(event:GetInt("userid")):GetIndex(), {0, 0, 0}, 0, {"dead"}, "dead")
				end
			elseif eventName == "round_end" or eventName == "bomb_dropped" then
				for k, v in pairs(player_weapons) do
					remove_weapon(k, "49")
				end
			end
		end
	end)
	--©thekorol
end)()

local Info = (function()
	local frame_rate = 0.0

	local get_abs_fps = function()
		frame_rate = 0.9 * frame_rate + (1.0 - 0.9) * globals.AbsoluteFrameTime()
		return math.floor((1.0 / frame_rate) + 0.5)
	end
	
	local function setMath(int, max, declspec)
		local int = (int > max and max or int)
		local tmp = max / int;
		local i = (declspec / tmp)
		i = (i >= 0 and math.floor(i + 0.5) or math.ceil(i - 0.5))
		return i
	end
	
	function gradient(x1, y1, x2, y2, left)
		local w = x2 - x1
		local h = y2 - y1
	
		for i = 0, w do
			local a = (i / w) * 200
	
			draw.Color(0, 0, 0, a)
			if left then
				draw.FilledRect(x1 + i, y1, x1 + i + 1, y1 + h)
			else
				draw.FilledRect(x1 + w - i, y1, x1 + w - i + 1, y1 + h)
			end
		end
	end
	
	local function getColor(number, max)
		local r, g, b
		i = setMath(number, max, 10)
	
		if i <= 1 then r, g, b = 255, 0, 0
			elseif i == 2 then r, g, b = 237, 27, 3
			elseif i == 3 then r, g, b = 235, 63, 6
			elseif i == 4 then r, g, b = 229, 104, 8
			elseif i == 5 then r, g, b = 228, 126, 10
			elseif i == 6 then r, g, b = 220, 169, 16
			elseif i == 7 then r, g, b = 213, 201, 19
			elseif i == 8 then r, g, b = 176, 205, 10
			elseif i == 9 then r, g, b = 124, 195, 13
			elseif i == 10 then r, g, b = 102, 209, 21
		end
	
		return r, g, b
	end
	
	local function getColor2(number, max)
		local r, g, b
		i = setMath(number, max, 10)
	
		if i <= 1 then r, g, b = 102, 209, 21
			elseif i == 2 then r, g, b = 124, 195, 13
			elseif i == 3 then r, g, b = 176, 205, 10
			elseif i == 4 then r, g, b = 213, 201, 19
			elseif i == 5 then r, g, b = 220, 169, 16
			elseif i == 6 then r, g, b = 228, 126, 10
			elseif i == 7 then r, g, b = 229, 104, 8
			elseif i == 8 then r, g, b = 235, 63, 6
			elseif i == 9 then r, g, b = 237, 27, 3
			elseif i == 10 then r, g, b = 255, 0, 0
		end
	
		return r, g, b
	end
	
	local speed = 0
	
	function paint_traverse()
		if not entities.GetLocalPlayer() then return end
		
		if gui.GetValue("rbot.master") and enabled:GetValue() and info:GetValue() then
	
			local x, y = draw.GetScreenSize()
			local centerX = x / 2
			local latency = 0;
			
			if entities.FindByClass( "CBasePlayer" )[1] ~= nil then
				latency=entities.GetPlayerResources():GetPropInt( "m_iPing", client.GetLocalPlayerIndex() )
			end;
		
			local rw,rh
			gradient(centerX - 200, y - 30, centerX - 51, y, 0, true)
			gradient(centerX - 200, y - 30, centerX - 51, y - 29, true)
			draw.Color(0, 0, 0, 200)
			draw.FilledRect(centerX - 50, y - 30, centerX + 70, y)
			draw.Color(0, 0, 0, 255)
			draw.FilledRect(centerX - 50, y - 30, centerX + 70, y - 29)
			gradient(centerX + 70, y - 30, centerX + 200, y, false)
			gradient(centerX + 70, y - 30, centerX + 200, y - 29, false)
		
			local r, g, b = getColor(get_abs_fps(), 120)

			draw.Color(r, g, b, 255)
			rw,rh = draw.GetTextSize(get_abs_fps())
			draw.Text(centerX - 1 - (rw/2), y - 20, get_abs_fps()) 
			draw.Text(centerX + 1 + (rw/2), y - 20, "fps")
		
			r,g,b=getColor2(latency, 350)
			draw.Color(r, g, b, 255)
			rw,rh = draw.GetTextSize(latency)
			draw.Text(centerX - 80-(rw/2), y - 20, latency)
			draw.Text(centerX - 78+(rw/2), y - 20, "ping")
			draw.Color(255, 255, 255, 255)

			if entities.GetLocalPlayer() ~= nil then
				local Entity = entities.GetLocalPlayer();
				local Alive = Entity:IsAlive();
				local velocityX = Entity:GetPropFloat( "localdata", "m_vecVelocity[0]" );
				local velocityY = Entity:GetPropFloat( "localdata", "m_vecVelocity[1]" );
				local velocity = math.sqrt( velocityX^2 + velocityY^2 );
				local FinalVelocity = math.min( 9999, velocity ) + 0.2;
			
				draw.Color( 255, 255, 255, 255 );
				if ( Alive == true ) then
					speed= math.floor(FinalVelocity) ;
				else
					speed=0;
				end
			end
		
			rw,rh =draw.GetTextSize(speed)
			draw.Text(centerX + 73-(rw/2), y - 20, speed) 
			draw.Text(centerX + 75+(rw/2), y - 20, "speed")
		end
	end
	
	callbacks.Register("Draw", "paint_traverse", paint_traverse)
end)()

--Saves values on load for something.
Cache_fn();
Cache_AA();

--Executes every input update & allows us to do some things normally not possible.
local function OnCreateMove(cmd)
	LegitAA(cmd);
end

--Executes on every frame.
local function OnDraw()
    fileSystem[56] = 1

	Gui();
	AntiAim();
	Clantag();
	Visuals();
	IdealTick();
	EngineRadar();
end

--Executes on every frame for ESP (I think).
local function OnDrawESP(esp)
	FakeduckFlag(esp);
	AmmoESP(esp);
end

--Executes when certain event occures ingame.
local function OnFireGameEvent(event)
	AutoDisconnect(event);
	AutoUnmute(event);
	Killsay(event);
end

--Executes when script is unloaded.
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

client.AllowListener("player_death");
client.AllowListener("player_team");
client.AllowListener("cs_win_panel_match");
callbacks.Register( "CreateMove", OnCreateMove);
callbacks.Register( "Draw", OnDraw );
callbacks.Register( "DrawESP", OnDrawESP )
callbacks.Register( "FireGameEvent", OnFireGameEvent);
callbacks.Register( "Unload", OnUnload );