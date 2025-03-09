function(_, event)
    if event ~= "VOZ_FETCH_LINES" then
        return false
    end
    local order = 6

    local aura_env = aura_env
    local C_Map = C_Map
    local function AddLines(entries, name)
        WeakAuras.ScanEvents("VOZ_ADD_LINES", entries, name, order)
        order = order + 0.01
    end

    local showOnlyCurrentZone = aura_env.config["show_only_current_zone"]
    local showOnlyInsideDelve = aura_env.config["show_only_inside_delve"]
    local warbandMode = aura_env.config["warband_mode"]
    local showCompleted = aura_env.config["show_completed"]
    local bestMapForPlayer = showOnlyCurrentZone and C_Map.GetBestMapForUnit("player") or 0
    local function AddZone(entries, delveZoneId)
        for _, entry in pairs(entries) do
            entry.filtered = bestMapForPlayer ~= delveZoneId
            if entry.filtered and not showOnlyInsideDelve then
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
                entry.filtered = not (inAnyZone and showAnyZone)
            end
            entry.warbandMode = warbandMode
            entry.allowWarbandMode = true
            entry.showCompleted = showCompleted
        end
        local name = C_Map.GetMapInfo(delveZoneId).name
        AddLines(entries, ("Delve: %s"):format(name))
    end

    for delveZoneId, delve in pairs(aura_env.delves) do
        AddZone(delve, delveZoneId)
    end

    if aura_env.config["show_general_delves"] then
        AddLines(aura_env.general_delves, "General - Delves")
    end

    if aura_env.config["show_bountiful_delves"] then
        local C_AreaPoiInfo = C_AreaPoiInfo
        for _, entry in pairs(aura_env.bountiful_delves) do
            local zoneIds = entry.zoneIds
            local inAnyZone = not zoneIds
            local showAnyZone = not zoneIds
            local poiInactive = false
            if zoneIds then
                for _, zoneId in pairs(zoneIds) do
                    local inZone = not showOnlyCurrentZone or bestMapForPlayer == zoneId
                    inAnyZone = inAnyZone or inZone
                    showAnyZone = showAnyZone or aura_env.config["show_" .. zoneId]
                    if entry.poi then
                        local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(zoneId, entry.poi)
                        poiInactive = poiInfo == nil
                    end
                end
            end
            entry.filtered = not (inAnyZone and showAnyZone) or poiInactive
        end
        AddLines(aura_env.bountiful_delves, "Bountiful Delves")
    end
end