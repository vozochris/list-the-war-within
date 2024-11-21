function(_, event)
    if event ~= "VOZ_FETCH_LINES" then
        return false
    end
    local order = 1

    local aura_env = aura_env
    local showCompleted = aura_env.config["show_completed"]
    local warbandMode = aura_env.config["warband_mode"]
    local entries = aura_env.general
    for _, entry in pairs(entries) do
        entry.filtered = entry.id and aura_env.config["hide_" .. entry.id]
        entry.showCompleted = showCompleted
        entry.allowWarbandMode = true
        entry.warbandMode = warbandMode
    end
    WeakAuras.ScanEvents("VOZ_ADD_LINES", aura_env.general, "General - Khaz Algar", order)
end