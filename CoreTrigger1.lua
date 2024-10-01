function(states, event, ...)
    local aura_env = aura_env
    if event == "VOZ_ADD_LINES" then
        aura_env.OnAddLines(states, event, ...)
    elseif event == "VOZ_REFRESH_LINES" then
        aura_env.requestedRefreshes = aura_env.requestedRefreshes - 1
        if aura_env.requestedRefreshes <= 0 then
            aura_env.requestedRefreshes = 0
            for _, state in pairs(states) do
                state.show = false
                state.changed = true
            end

            aura_env.index = 1
            WeakAuras.ScanEvents("VOZ_FETCH_LINES", event, ...)
        end
    elseif event == "OPTIONS" then
        aura_env.AddCustomLine(states, {
            show = true,
            name = "Example Category: voz' List",
            index = 1,
            category = true,
        })
        for i = 2, 10 do
            aura_env.AddCustomLine(states, {
                show = true,
                index = i,
                name = ("voz' List Entry %s"):format(i - 1),
            })
        end
        aura_env.AddCustomLine(states, {
            show = true,
            index = 11,
            hasVignette = true,
            name = "voz' List Entry: Vignette example <---",
        })
        aura_env.AddCustomLine(states, {
            show = true,
            index = 12,
            completed = true,
            name = "voz' List Entry: Completed example",
        })
    elseif event == "STATUS" then
        aura_env.requestedRefreshes = 0
        WeakAuras.ScanEvents("VOZ_REFRESH_LINES")
    elseif event == "VIGNETTE_MINIMAP_UPDATED" then
        local vignetteGUID, onMinimap = ...
        if onMinimap then
            local vignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
            aura_env.vignettes[vignetteGUID] = vignetteInfo
            aura_env.UpdateLineForVignette(states, vignetteGUID, vignetteInfo)
        elseif aura_env.vignettes[vignetteGUID] then
            aura_env.vignettes[vignetteGUID] = nil
            aura_env.UpdateLineForVignette(states, vignetteGUID, nil)
        end
    else
        aura_env.requestedRefreshes = aura_env.requestedRefreshes + 1
        C_Timer.After(1, function() WeakAuras.ScanEvents("VOZ_REFRESH_LINES") end)
    end

    return true
end