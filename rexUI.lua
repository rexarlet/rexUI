-- General structure credits to Shagu, pfUI
function zPrint(txt)
	if( DEFAULT_CHAT_FRAME ) then
		--DEFAULT_CHAT_FRAME:AddMessage(fontBlue.."<|cffffd200r|cff808080exUI|r" .. fontBlue .. "> |r"..txt)
		DEFAULT_CHAT_FRAME:AddMessage("|cffffd200r|cff808080exUI|r - "..txt)
	end
end 

SLASH_RL1 = '/rl'
function SlashCmdList.RL( msg, editbox )
	ReloadUI();
end

SLASH_KEYBIND1 = '/kb'
function SlashCmdList.KEYBIND( msg, editbox )
	if zUI.zKeybind then zUI.zKeybind:Show() end
end

SLASH_REXUI1 = "/rexui" -- test stuff
function SlashCmdList.REXUI( msg, editbox )
	if zUI.gui and zUI.gui:IsShown() then
		zUI.gui:Hide()
	elseif zUI.gui then
		zUI.gui:Show()
	end
end

zUI = CreateFrame("Frame", nil, UIParent);
zUI:RegisterEvent("ADDON_LOADED");

-- Loading indicator
zUI.loading = true;

-- Init saved variables
zUI_playerDB = {}
zUI_config = {}
zUI_init = {}
zUI_profiles = {}
zUI_addon_profiles = {}
zUI_cache = {}

-- Localization
zUI_locale = {}
zUI_translation = {}

-- Init default variables
zUI.cache = {}
zUI.component = {}
zUI.components = {}
zUI.skin = {}
zUI.skins = {}
zUI.environment = {}
zUI.movables = {}
zUI.version = {}
zUI.hooks = {}
zUI.env = {}

local _, _, _, client = GetBuildInfo();
zUI.client = client or 11200;

-- Setup zUI namespace to not pollute environment
setmetatable(zUI.env, {__index = getfenv(0)})

function zUI:UpdateFonts()
 
  if not zUI_config or not zUI_config.global then return end

  local default, unit, combat
  if zUI_config.global.force_region == "1" and GetLocale() == "zhCN" then
    default = "Fonts\\FZXHLJW.TTF"
    combat = "Fonts\\FZXHLJW.TTF"
    unit = "Fonts\\FZXHLJW.TTF"
  elseif zUI_config.global.force_region == "1" and GetLocale() == "koKR" then
    default = "Fonts\\2002.TTF"
    combat = "Fonts\\2002.TTF"
    unit = "Fonts\\2002.TTF"
  else
    default = zUI_config.global.font_default
  end

  zUI.font_default = default

  STANDARD_TEXT_FONT = default
  DAMAGE_TEXT_FONT   = combat
  NAMEPLATE_FONT     = default
  UNIT_NAME_FONT     = default

end

function zUI:UpdateColors()

	RAID_CLASS_COLORS = {
		["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43, colorStr = "ffc79c6e" },
		["MAGE"]    = { r = 0.41, g = 0.8,  b = 0.94, colorStr = "ff69ccf0" },
		["ROGUE"]   = { r = 1,    g = 0.96, b = 0.41, colorStr = "fffff569" },
		["DRUID"]   = { r = 1,    g = 0.49, b = 0.04, colorStr = "ffff7d0a" },
		["HUNTER"]  = { r = 0.67, g = 0.83, b = 0.45, colorStr = "ffabd473" },
		["SHAMAN"]  = { r = 0.14, g = 0.35, b = 1.0,  colorStr = "ff0070de" },
		["PRIEST"]  = { r = 1,    g = 1,    b = 1,    colorStr = "ffffffff" },
		["WARLOCK"] = { r = 0.58, g = 0.51, b = 0.79, colorStr = "ff9482c9" },
		["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73, colorStr = "fff58cba" },
	}

	RAID_CLASS_COLORS = setmetatable(RAID_CLASS_COLORS, { __index = function(tab,key)
		return { r = 0.6,  g = 0.6,  b = 0.6,  colorStr = "ff999999" }
	end})
end

function zUI:GetEnvironment()
	-- Load API into environment

	for n, func in pairs(zUI.api or {}) do
		zUI.env[n] = func
	end

	local lang = zUI_config.global and zUI_translation[zUI_config.global.language] and zUI_config.global.language or GetLocale()
	local T =  setmetatable(zUI_translation[lang] or {}, {__index = function(tab,key)
		local value = tostring(key)
		rawset(tab,key,value)
		return value
	end})

	zUI.env._G = getfenv(0)
	zUI.env.T = T
	zUI.env.C = zUI_config
	zUI.env.L = (zUI_locale[GetLocale()] or zUI_locale["enUS"])

	return zUI.env
end
-- component
function zUI:RegisterComponent(n, f)
	if zUI.component[n] then return end
	zUI.component[n] = f
	table.insert(zUI.components, n)
	if not zUI.loading then
		zUI:LoadComponent(n)
	end
end

function zUI:RegisterSkin(s, f)
	if zUI.skin[s] then return end
		zUI.skin[s] = f
		table.insert(zUI.skins, s)
	if not zUI.loading then
		zUI:LoadSkin(s)
	end
end

function zUI:LoadComponent(c)
	setfenv(zUI.component[c], zUI:GetEnvironment())
	--zPrint(fontOrange.. c .."|r component " ..fontGreen.. "Loaded.") --nice little load msg 
	zUI.component[c]()
end

function zUI:LoadSkin(s)
	setfenv(zUI.skin[s], zUI:GetEnvironment())
	--zPrint(fontLightBlue.. s .."|r skin " ..fontGreen.. "Loaded.") --nice little load msg 
	zUI.skin[s]()
end

zUI:SetScript("OnEvent", function()
	zUI:UpdateColors();
	
	if arg1 == "rexUI" then

		-- ADDON LOADED, READY FOR ACTION
		--zPrint("Core initiating component load sequence.")
		zPrint("Thank's for using rexUI, type /rexui for options.");
		zPrint("/kb to bind your keys.");

		local major, minor, fix = zUI.api.strsplit(".", tostring(GetAddOnMetadata("rexUI", "Version")))
		zUI.version.major = tonumber(major) or 1
		zUI.version.minor = tonumber(minor) or 0
		zUI.version.fix   = tonumber(fix)   or 0
		zUI.version.string = zUI.version.major .. "." .. zUI.version.minor .. "." .. zUI.version.fix

		-- load config
		zUI:LoadConfig()

		-- load components
		for _, c in pairs(this.components) do
			if not ( zUI_config["disabled"] and zUI_config["disabled"][c]  == "1" ) then
				zUI:LoadComponent(c)
			end
		end

		-- load skins
		for _, s in pairs(this.skins) do
			if not ( zUI_config["disabled"] and zUI_config["disabled"]["skin_" .. s]  == "1" ) then
				zUI:LoadSkin(s)
			end
		end

		zUI.loading = nil;
	end
end)

zUI.backdrop = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = false, tileSize = 0,
	edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 1,
	insets = {left = -1, right = -1, top = -1, bottom = -1},
}

zUI.backdrop_no_top = zUI.backdrop

zUI.backdrop_hover = {
	edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 24,
	insets = {left = -1, right = -1, top = -1, bottom = -1},
}

--ZUI_FLAT_TEXTURE   = [[Interface\\AddOns\\rexUI\\img\name]]
ZUI_FLAT_TEXTURE   = [[Interface\BUTTONS\WHITE8X8]]
ZUI_ORIG_TEXTURE   = [[Interface\TargetingFrame\UI-StatusBar.blp]]

fontLightBlue = "|cff00e0ff"
fontLightGreen = "|cff60ff60"
fontLightRed = "|cffff8080"
fontRed = "|cffff0000"
fontOrange = "|cffff7000"
fontWhite = "|cffffffff"
fontGreen = "|cff00ff00"
fontBlue = "|cff068fff"
