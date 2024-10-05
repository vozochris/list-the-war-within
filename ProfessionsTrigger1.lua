function(_, event)
    if event ~= "VOZ_FETCH_LINES" then
        return false
    end
    local order = 2

    local aura_env = aura_env
    local C_Map = C_Map
    local C_MajorFactions = C_MajorFactions
    local GetProfessionInfo = GetProfessionInfo
    local prof1, prof2, _, fishing = GetProfessions()
    local skillLine1 = ""
    local skillLevel1 = 0
    local skillLine2 = ""
    local skillLevel2 = 0
    if prof1 then
        local _, _, skillLevel, _, _, _, skillLine = GetProfessionInfo(prof1)
        skillLine1 = skillLine
        skillLevel1 = skillLevel
    end
    if prof2 then
        local _, _, skillLevel, _, _, _, skillLine = GetProfessionInfo(prof2)
        skillLine2 = skillLine
        skillLevel2 = skillLevel
    end

    local function AddLines(entries, name)
        WeakAuras.ScanEvents("VOZ_ADD_LINES", entries, name, order)
        order = order + 0.01
    end

    local function HasRenown(renown)
        if not renown then
            return true
        end

        local level = C_MajorFactions.GetCurrentRenownLevel(renown.id) or 0
        return level >= renown.level
    end

    local showCompleted = aura_env.config["show_completed"]
    local showOnlyCurrentZone = aura_env.config["show_only_current_zone"]
    local showCatchup = aura_env.config["show_catchup"]
    local bestMapForPlayer = showOnlyCurrentZone and C_Map.GetBestMapForUnit("player") or 0
    local function AddZone(entries, name)
        for _, entry in pairs(entries) do
            local zoneIds = entry.zoneIds
            local inAnyZone = not zoneIds
            local showAnyZone = not zoneIds
            if zoneIds then
                for _, zoneId in pairs(zoneIds) do
                    local inZone = not showOnlyCurrentZone or bestMapForPlayer == zoneId
                    inAnyZone = inAnyZone or inZone
                    showAnyZone = showAnyZone or aura_env.config["show_" .. zoneId]
                end
            end
            local eventCheck = not entry.event or aura_env["event_" .. entry.event]
            local catchupCheck = not entry.currency or showCatchup
            entry.filtered = not (inAnyZone and showAnyZone) or not HasRenown(entry.renown) or not eventCheck or not catchupCheck
            entry.showCompleted = showCompleted
        end
        AddLines(entries, name)
    end

    local function AddProfession(entries, skillLine, name)
        local requiredSkill = 1
        if skillLine1 == skillLine and skillLevel1 >= requiredSkill or skillLine2 == skillLine and skillLevel2 >= requiredSkill then
            AddZone(entries, name)
        end
    end

    AddProfession(aura_env.inscription, 773, "Inscription")
    AddProfession(aura_env.mining, 186, "Mining")
    AddProfession(aura_env.herbalism, 182, "Herbalism")
    AddProfession(aura_env.alchemy, 171, "Alchemy")
    AddProfession(aura_env.blacksmithing, 164, "Blacksmithing")
    AddProfession(aura_env.enchanting, 333, "Enchanting")
    AddProfession(aura_env.engineering, 202, "Engineering")
    AddProfession(aura_env.jewelcrafting, 755, "Jewelcrafting")
    AddProfession(aura_env.leatherworking, 165, "Leatherworking")
    AddProfession(aura_env.skinning, 393, "Skinning")
    AddProfession(aura_env.tailoring, 197, "Tailoring")

    if aura_env.event_hallowfallFishing and fishing and aura_env.config["show_fishing"] then
        AddZone(aura_env.fishing, "Fishing")
    end
end