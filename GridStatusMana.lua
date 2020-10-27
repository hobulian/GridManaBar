local L = GridManaBarsLocale

local GridRoster = Grid:GetModule("GridRoster")
local GridStatus = Grid:GetModule("GridStatus")

GridMBStatus = GridStatus:NewModule("GridMBStatus")

GridMBStatus.menuName = "ManaBar"

GridMBStatus.defaultDB = {
	debug = false,
	hiderage = false,
	onlyhealer = true,
	hidepetbars = true,
	color = { r = 0, g = 0, b = 1.0, a = 1.0 },
	ecolor = { r = 1, g = 1, b = 0, a = 1.0 },
	rcolor = { r = 1, g = 0, b = 0, a = 1.0 },
    dcolor = { r = 0, g = 0.8, b = 0.8, a = 1.0 },
	ocolor = { r = 1, g = 0.5, b = 0, a = 1.0 },
    pcolor = { r = 1, g = 0, b = 0.8, a = 1.0 },
	mcolor = { r = 0, g = 0.6, b = 1, a = 1.0 },
	unit_mana = {
		color = { r=1, g=1, b=1, a=1 },
		text = "ManaBar",
		enable = true,
		priority = 30,
		range = false
	}
}

GridMBStatus.options = false

local manabar_options = {

	["Ignore Non-Mana"] = {
		type = "toggle",
		name = L["Ignore Non-Mana"],
		desc = L["Don't track power for non-mana users"],
		get = function()
			return GridMBStatus.db.profile.hiderage
		end,
		set = function(_, v)
			GridMBStatus.db.profile.hiderage = v
            GridMBStatus:UpdateAllUnits()
		end,
	},
	["Colours"] = {
		type = "group",
		name = L["Colours"],
		desc = L["Colours for the various powers"],
		args = {
		["Mana color"] = {
			type = "color",
			name = L["Mana color"],
			desc = L["Color for mana"],
			hasAlpha = true,
			get = function()
				local s = GridMBStatus.db.profile.color
				return s.r, s.g, s.b, s.a
			end,
			set = function(_, r,g,b,a)
				local s = GridMBStatus.db.profile.color
				s.r, s.g, s.b, s.a = r, g, b, a
                GridMBStatus:UpdateAllUnits()
			end
        },
		["Energy color"] = {
			type = "color",
			name = L["Energy color"],
			desc = L["Color for energy"],
			hasAlpha = true,
			get = function()
				local s = GridMBStatus.db.profile.ecolor
				return s.r, s.g, s.b, s.a
			end,
			set = function(_, r,g,b,a)
				local s = GridMBStatus.db.profile.ecolor
				s.r, s.g, s.b, s.a = r, g, b, a
                GridMBStatus:UpdateAllUnits()
			end
        },
		["Rage color"] = {
			type = "color",
			name = L["Rage color"],
			desc = L["Color for rage"],
			hasAlpha = true,
			get = function()
				local s = GridMBStatus.db.profile.rcolor
				return s.r, s.g, s.b, s.a
			end,
			set = function(_, r,g,b,a)
				local s = GridMBStatus.db.profile.rcolor
				s.r, s.g, s.b, s.a = r, g, b, a
                GridMBStatus:UpdateAllUnits()
			end
        },
        ["Runic Power color"] = {
            type = "color",
            name = L["Runic power color"],
            desc = L["Color for runic power"],
            hasAlpha = true,
            get = function()
                local s = GridMBStatus.db.profile.dcolor
                return s.r, s.g, s.b, s.a
            end,
            set = function(_, r,g,b,a)
                local s = GridMBStatus.db.profile.dcolor
                s.r, s.g, s.b, s.a = r, g, b, a
                GridMBStatus:UpdateAllUnits()
            end
        },
		["Focus color"] = {
            type = "color",
            name = L["Focus color"],
            desc = L["Color for Focus"],
            hasAlpha = true,
            get = function()
                local s = GridMBStatus.db.profile.ocolor
                return s.r, s.g, s.b, s.a
            end,
            set = function(_, r,g,b,a)
                local s = GridMBStatus.db.profile.ocolor
                s.r, s.g, s.b, s.a = r, g, b, a
                GridMBStatus:UpdateAllUnits()
            end
        },
		["Fury color"] = {
            type = "color",
            name = L["Fury color"],
            desc = L["Color for Fury"],
            hasAlpha = true,
            get = function()
                local s = GridMBStatus.db.profile.pcolor
                return s.r, s.g, s.b, s.a
            end,
            set = function(_, r,g,b,a)
                local s = GridMBStatus.db.profile.pcolor
                s.r, s.g, s.b, s.a = r, g, b, a
                GridMBStatus:UpdateAllUnits()
            end
        },
		["Maelstorm color"] = {
            type = "color",
            name = L["Maelstorm color"],
            desc = L["Color for Maelstorm"],
            hasAlpha = true,
            get = function()
                local s = GridMBStatus.db.profile.mcolor
                return s.r, s.g, s.b, s.a
            end,
            set = function(_, r,g,b,a)
                local s = GridMBStatus.db.profile.mcolor
                s.r, s.g, s.b, s.a = r, g, b, a
                GridMBStatus:UpdateAllUnits()
            end
        },
		}
	},
	["Ignore Pets"] = {
		type = "toggle",
		name = L["Ignore Pets"],
		desc = L["Don't track power for pets"],
		get = function()
			return GridMBStatus.db.profile.hidepetbars
		end,
		set = function(_, v)
			GridMBStatus.db.profile.hidepetbars=v
            GridMBStatus:UpdateAllUnits()
		end,
	},
	["Only Healer"] = {
		type = "toggle",
		name = L["Only Healer"],
		desc = L["Only track power for Healer"],
		get = function()
			return GridMBStatus.db.profile.onlyhealer
		end,
		set = function(_, v)
			GridMBStatus.db.profile.onlyhealer=v
            GridMBStatus:UpdateAllUnits()
		end,
	}
}

local playerName = UnitName("player")
local ignoreUnitsPower = {}

function GridMBStatus:OnInitialize()
	self.super.OnInitialize(self)

	self:RegisterStatus('unit_mana',L["Mana"], manabar_options, true)
	GridStatus.options.args['unit_mana'].args['color'] = nil
end

function GridMBStatus:OnStatusEnable(status)
    if status == "unit_mana" then
        self:RegisterMessage("Grid_UnitLeft")
        self:RegisterMessage("Grid_LeftParty")

        self:RegisterMessage("Grid_UnitJoined")
        self:RegisterEvent("UNIT_DISPLAYPOWER")

		self:RegisterEvent("PLAYER_ROLES_ASSIGNED", "UpdateAllUnits")

        self:RegisterEvent("UNIT_POWER_UPDATE","UpdateUnit")
        self:RegisterEvent("UNIT_MAXPOWER","UpdateUnit")
        
        self:UpdateAllUnits()
    end
end

function GridMBStatus:OnStatusDisable(status)
    if status == "unit_mana" then
        ignoreUnitsPower = {}
        for guid, unitid in GridRoster:IterateRoster() do
            self.core:SendStatusLost(guid, "unit_mana")
        end
        
        self:UnregisterMessage("Grid_UnitLeft")
        self:UnregisterMessage("Grid_LeftParty")

        self:UnregisterMessage("Grid_UnitJoined")
        self:UnregisterEvent("UNIT_DISPLAYPOWER")

		self:UnregisterEvent("PLAYER_ROLES_ASSIGNED", "UpdateAllUnits")
		
        self:UnregisterEvent("UNIT_POWER_UPDATE","UpdateUnit")
        self:UnregisterEvent("UNIT_MAXPOWER","UpdateUnit")
    end
end

function GridMBStatus:Reset()
	self.super.Reset(self)
	self:UpdateAllUnits()
end

function GridMBStatus:UpdateAllUnits()
	for guid, unitid in GridRoster:IterateRoster() do
		self:UpdateUnitPowerType(unitid)
	end
end

--[[free the leaving units entry in ignoreUnitsPower-table]]
function GridMBStatus:Grid_UnitLeft(_, unitGUID)
	ignoreUnitsPower[unitGUID] = nil
end

--[[wipe own-heals-table clean]]
function GridMBStatus:Grid_LeftParty()
	ignoreUnitsPower = {}
    self:UpdateUnitPowerType("player")
end

function GridMBStatus:Grid_UnitJoined(_, unitGUID, unitid)
    self:UpdateUnitPowerType(unitid)
end

function GridMBStatus:UNIT_DISPLAYPOWER(_, unitid)
    self:UpdateUnitPowerType(unitid)
end

function GridMBStatus:UpdateUnit(_, unitid)
    local unitGUID = UnitGUID(unitid)
    --print("UU("..unitid..")")

    if ignoreUnitsPower[unitGUID] == false then
        self:UpdateUnitPower(unitid)
    end
end

function GridMBStatus:UpdateAllUnits()
    --print("MB:UpdateAllUnits()")
    for guid, id in GridRoster:IterateRoster() do
        self:UpdateUnitPowerType(id)
    end
end


function GridMBStatus:UpdateUnitPowerType(unitid)
    if not unitid then return end

    local unitGUID = UnitGUID(unitid)
    if not unitGUID then return end
    --print("MB:UpdateUnitPowerType("..unitid..")")

    local ignoreUnit = false

    if petbars and GridMBStatus.db.profile.hidepetbars and (not UnitIsPlayer(unitid)) then
        ignoreUnit = true
	elseif GridMBStatus.db.profile.onlyhealer then
		local UnitRole = UnitGroupRolesAssigned(unitid)

		ignoreUnit = UnitRole~= "HEALER"
	elseif GridMBStatus.db.profile.hiderage then
		local powerType = UnitPowerType(unitid)

		ignoreUnit = powerType ~= 0
	end

    ignoreUnitsPower[unitGUID] = ignoreUnit

    if ignoreUnit then
        self.core:SendStatusLost(unitGUID, "unit_mana")
    else
        self:UpdateUnitPower(unitid)
    end
end

function GridMBStatus:UpdateUnitPower(unitid)

	local cur, max = UnitPower(unitid), UnitPowerMax(unitid)
	local priority = GridMBStatus.db.profile.unit_mana.priority

	if cur==max then
		priority=1
	end

	local powerType = UnitPowerType(unitid)
	local col = nil

	if powerType == 1 then
		col = GridMBStatus.db.profile.rcolor
	elseif powerType == 2 or powerType == 18 then
		col = GridMBStatus.db.profile.ocolor
	elseif powerType == 3 then
		col = GridMBStatus.db.profile.ecolor
	elseif powerType == 6 then
		col = GridMBStatus.db.profile.dcolor
	elseif powerType == 8 or powerType == 11 then
		col = GridMBStatus.db.profile.mcolor
	elseif powerType == 13 or powerType == 17 then
		col = GridMBStatus.db.profile.pcolor
	else
		col = GridMBStatus.db.profile.color
	end

    local unitGUID = UnitGUID(unitid)

--DEFAULT_CHAT_FRAME:AddMessage("UU("..unitid..")")

	self.core:SendStatusGained(
        unitGUID, "unit_mana",
        priority,
        nil,
		col,
        nil,
        cur,max,
        nil
    )
end

