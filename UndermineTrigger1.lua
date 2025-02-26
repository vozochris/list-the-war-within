function(_, event)
    if event ~= "VOZ_FETCH_LINES" then
        return false
    end
    local order = 9

    local aura_env = aura_env
    local showCompleted = aura_env.config["show_completed"]

    local function FixEntries(entries)
        for _, entry in pairs(entries) do
            entry.filtered = entry.id and aura_env.config["hide_" .. entry.id]
            entry.showCompleted = showCompleted
            entry.allowWarbandMode = true
            entry.warbandMode = true
        end
    end
    
    FixEntries(aura_env.undermine_rares)
    FixEntries(aura_env.undermine_treasures)

    if aura_env.config["show_undermine_rares"] then
        WeakAuras.ScanEvents("VOZ_ADD_LINES", aura_env.undermine_rares, "Undermine Rares", order)
    end

    if aura_env.config["show_undermine_treasures"] then
        order = order + 0.01
        WeakAuras.ScanEvents("VOZ_ADD_LINES", aura_env.undermine_treasures, "Undermine Treasures", order)
    end
end