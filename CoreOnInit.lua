local aura_env = aura_env
local C_QuestLog = C_QuestLog

aura_env.requestedRefreshes = 0
aura_env.vignettes = {}

local function GetCoords(coords)
    local x1 = coords:sub(1, 2)
    local x2 = coords:sub(3, 4)
    local y1 = coords:sub(5, 6)
    local y2 = coords:sub(7, 8)
    return ("%s.%s, %s.%s"):format(x1, x2, y1, y2)
end

local function PlayTTS(text)
    local C_TTSSettings = C_TTSSettings
    C_VoiceChat.SpeakText(1, text, Enum.VoiceTtsDestination.LocalPlayback, C_TTSSettings and C_TTSSettings.GetSpeechRate() or 0, C_TTSSettings and C_TTSSettings.GetSpeechVolume() or 100)
end

local function AddLines(entries, category, states, startingIndex)
    local index = startingIndex + 2
    local addedLines = false

    if not entries then
        return
    end

    local showCoords = aura_env.config["show_coords"]
    local showInfo = aura_env.config["show_info"]
    local infoColor = aura_env.config["info_color"]
    local filterConfig = aura_env.config["filter"]
    
    for _, entry in pairs(entries) do
        local c = 0
        local cCharacterOnly = 0
        local cWarbandOnly = 0
        local questsCount = 0
        local hasVignette = false
        local vignetteGUID
        local filtered = entry.filtered
        local completedOn = entry.completedOn or 1
        local warbandMode = entry.warbandMode and entry.allowWarbandMode
        local reputationMode = entry.reputationMode

        if not filtered and filterConfig then
            for _, filter in pairs(filterConfig) do
                if (entry.name == filter.name) then
                    filtered = true
                end
            end
        end
        
        if not filtered then
            local quests = reputationMode and entry.repQuests or entry.quests
            for _, quest in pairs(quests) do
                questsCount = questsCount + 1
                if C_QuestLog.IsQuestFlaggedCompleted(quest) then
                    cCharacterOnly = cCharacterOnly + 1
                    if not warbandMode then
                        c = c + 1
                    end
                end
                if C_QuestLog.IsQuestFlaggedCompletedOnAccount(quest) then
                    cWarbandOnly = cWarbandOnly + 1
                    if warbandMode then
                        c = c + 1
                    end
                end
            end
        end

        local questsIncomplete = questsCount > 0 and c < completedOn
        if questsIncomplete or not filtered and entry.showCompleted then
            local prepend = ""
            local append = ""
            local infoAppend = ""
            local vignetteAppend = ""
            local isCompleted = c >= completedOn

            if questsIncomplete then
                for k, v in pairs(aura_env.vignettes) do
                    if entry.name == v.name then
                        hasVignette = true
                        vignetteGUID = k
                        vignetteAppend = " <---"
                        break
                    end
                end
            end

            if entry.completedOn then
                append = append .. ": " .. (completedOn - c)
            end

            if entry.coords and showCoords then
                infoAppend = infoAppend .. (" (%s)"):format(GetCoords(entry.coords))
            end

            if entry.info and showInfo then
                infoAppend = infoAppend .. (" (%s)"):format(entry.info)
            end

            if questsCount == 0 then
                infoAppend = infoAppend .. " [Missing ID!]"
                isCompleted = true
            elseif entry.allowWarbandMode and cCharacterOnly ~= cWarbandOnly then
                prepend = prepend .. "[*]"
            end

            states[entry] = {
                show = true,
                name = entry.name,
                prepend = prepend,
                append = append,
                infoAppend = ("|c%02X%02X%02X%02X%s|r"):format(infoColor[4] * 255, infoColor[1] * 255, infoColor[2] * 255, infoColor[3] * 255, infoAppend),
                vignetteAppend = vignetteAppend,
                hasVignette = hasVignette,
                vignetteGUID = vignetteGUID,
                completed = isCompleted,
                zoneId = entry.zoneId,
                coords = entry.coords,
                index = index
            }
            index = index + 1
            addedLines = true
        end
    end
    
    if addedLines then
        states["category_" .. category] =  {
            show = true,
            name = category,
            category = true,
            index = startingIndex
        }
        if aura_env.config["empty_line_before_category"] then
            local emptyLine = {
                show = true,
                name = "",
                index = startingIndex + 1,
            }
            aura_env.AddCustomLine(states, emptyLine)
        end
        if aura_env.config["empty_line_after_category"] then
            index = index + 1
            local emptyLine = {
                show = true,
                name = "",
                index = index,
            }
            aura_env.AddCustomLine(states, emptyLine)
        end
    end

    return index
end

aura_env.AddCustomLine = function(states, line)
    states["custom_" .. line.index] = line
end

aura_env.OnAddLines = function(states, _, entries, category, order)
    aura_env.index = order * 10000
    aura_env.index = AddLines(entries, category, states, aura_env.index)
end

aura_env.UpdateLineForVignette = function(states, vignetteGUID, vignetteInfo)
    for _, entry in pairs(states) do
        if vignetteInfo then
            if not entry.completed and vignetteInfo.name == entry.name then
                entry.hasVignette = true
                entry.vignetteGUID = vignetteGUID
                entry.vignetteAppend = " <---"
                entry.changed = true
                if aura_env.config["tts_enabled"] then
                    PlayTTS(entry.name)
                end
                return
            end
        elseif entry.vignetteGUID == vignetteGUID then
            entry.hasVignette = false
            entry.vignetteGUID = nil
            entry.vignetteAppend = ""
            entry.changed = true
            return
        end
    end
end