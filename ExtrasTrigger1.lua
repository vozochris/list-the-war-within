function(_, event)
    if event ~= "VOZ_FETCH_LINES" then
        return false
    end
    local order = 5

    local aura_env = aura_env
    local C_Map = C_Map
    local function addLines(entries, name)
        WeakAuras.ScanEvents("VOZ_ADD_LINES", entries, name, order)
        order = order + 0.01
    end

    local showOnlyCurrentZone = aura_env.config["show_only_current_zone"]
    local warbandMode = aura_env.config["warband_mode"]
    local showCompleted = aura_env.config["show_completed"]
    local bestMapForPlayer = showOnlyCurrentZone and C_Map.GetBestMapForUnit("player") or 0
    local function addZone(entries, zoneIds, nameSuffix)
        local inAnyZone = false
        local showAnyZone = false
        for _, zoneId in pairs(zoneIds) do
            local inZone = not showOnlyCurrentZone or bestMapForPlayer == zoneId
            inAnyZone = inAnyZone or inZone
            showAnyZone = showAnyZone or aura_env.config["show_" .. zoneId]

            if inAnyZone and showAnyZone then
                for _, entry in pairs(entries) do
                    entry.zoneId = zoneId
                    entry.warbandMode = warbandMode
                    entry.allowWarbandMode = true
                    entry.showCompleted = showCompleted
                end

                local name = C_Map.GetMapInfo(zoneId).name
                addLines(entries, name .. nameSuffix)
                break
            end
        end
    end

    if aura_env.config["show_reputation_quests"] then
        addZone(aura_env.azjKahet, {2255, 2256, 2213, 2216}, " Reputation Quests")
        addZone(aura_env.isleOfDorn, {2248}, " Reputation Quests")
        addZone(aura_env.ringingDeeps, {2214}, " Reputation Quests")
        addZone(aura_env.hallowfall, {2215}, " Reputation Quests")
    end
    if aura_env.config["show_lesser_keyflame"] then
        addZone(aura_env.hallowfall_lesser_keyflame, {2215}, " Lesser Keyflame")
    end
end