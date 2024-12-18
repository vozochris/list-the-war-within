function(_, event)
    if event ~= "VOZ_FETCH_LINES" then
        return false
    end
    local order = 8

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

    FixEntries(aura_env.siren_isle)
    FixEntries(aura_env.siren_isle_rares)
    FixEntries(aura_env.siren_isle_forgotten_vault)

    if aura_env.config["show_siren_isle"] then
        WeakAuras.ScanEvents("VOZ_ADD_LINES", aura_env.siren_isle, "Siren Isle", order)
    end

    if aura_env.config["show_siren_isle_rares"] then
        order = order + 0.01
        WeakAuras.ScanEvents("VOZ_ADD_LINES", aura_env.siren_isle_rares, "Siren Isle Rares", order)
    end

    if aura_env.config["show_siren_isle_forgotten_vault"] then
        order = order + 0.01
        WeakAuras.ScanEvents("VOZ_ADD_LINES", aura_env.siren_isle_forgotten_vault, "Siren Isle - Forgotten Vault", order)
    end
end