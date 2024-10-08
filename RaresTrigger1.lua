function(_, event)
    if event ~= "VOZ_FETCH_LINES" then
        return false
    end
    local order = 3

    local aura_env = aura_env
    local C_Map = C_Map
    local function AddLines(entries, name)
        WeakAuras.ScanEvents("VOZ_ADD_LINES", entries, name, order)
        order = order + 0.01
    end

    local warbandMode = aura_env.config["warband_mode"]
    local reputationMode = aura_env.config["reputation_mode"]
    local showCompleted = aura_env.config["show_completed"]
    local showOnlyCurrentZone = aura_env.config["show_only_current_zone"]
    local bestMapForPlayer = showOnlyCurrentZone and C_Map.GetBestMapForUnit("player") or 0
    local function AddZone(entries, zoneIds)
        local inAnyZone = false
        local showAnyZone = false
        for _, zoneId in pairs(zoneIds) do
            local inZone = not showOnlyCurrentZone or bestMapForPlayer == zoneId
            inAnyZone = inAnyZone or inZone
            showAnyZone = showAnyZone or aura_env.config["show_" .. zoneId]

            if inAnyZone and showAnyZone then
                for _, entry in pairs(entries) do
                    entry.zoneId = zoneId
                    if entry.rep then
                        entry.info = entry.info and (entry.info .. " - ") or ""
                        entry.info = ("Rep: %s"):format(entry.rep)
                    elseif aura_env.config["show_only_rep"] then
                        entry.filtered = true
                    end
                    entry.warbandMode = warbandMode
                    entry.allowWarbandMode = true
                    if entry.repQuests then
                        entry.reputationMode = reputationMode
                    end
                    entry.filtered = entry.filtered or entry.npcId and not aura_env.config["show_npc_" .. entry.npcId]
                    entry.showCompleted = showCompleted
                end

                local name = C_Map.GetMapInfo(zoneId).name
                AddLines(entries, name .. " Rares")
                break
            end
        end
    end

    AddZone(aura_env.azjKahet, {2255, 2256, 2213, 2216})
    AddZone(aura_env.isleOfDorn, {2248})
    AddZone(aura_env.ringingDeeps, {2214})
    AddZone(aura_env.hallowfall, {2215})
end