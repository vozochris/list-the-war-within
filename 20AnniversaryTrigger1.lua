function(_, event)
    if event ~= "VOZ_FETCH_LINES" then
        return false
    end
    local order = 7

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

    FixEntries(aura_env.tanaris)
    FixEntries(aura_env.tww)
    FixEntries(aura_env.pvp)

    if aura_env.config["show_tanaris"] then
        WeakAuras.ScanEvents("VOZ_ADD_LINES", aura_env.tanaris, "Tanaris - Anniversary", order)
    end
    if aura_env.config["show_tww"] then
        order = order + 0.01
        WeakAuras.ScanEvents("VOZ_ADD_LINES", aura_env.tww, "The War Within - Anniversary", order)
    end
    if aura_env.config["show_pvp"] then
        order = order + 0.01
        WeakAuras.ScanEvents("VOZ_ADD_LINES", aura_env.pvp, "PvP - Anniversary", order)
    end
end