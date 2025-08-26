-- @description Move new FX before the chosen FX only when there is a change
-- @version 1.0
-- @author Kimitri


local EXT_SECTION = "MoveFXBefore"
local EXT_KEY = "vu_name"

-- try to load saved value
local vu_name = reaper.GetExtState(EXT_SECTION, EXT_KEY)

-- if it doesn't exist, ask the user
if vu_name == "" then
    local ret, user_input = reaper.GetUserInputs("Select target FX", 1, "FX name (or part of it):", "")
    if not ret or user_input == "" then
        reaper.ShowMessageBox("You did not provide an FX name. The script will exit.", "Error", 0)
        return
    end
    vu_name = user_input
    reaper.SetExtState(EXT_SECTION, EXT_KEY, vu_name, true) -- save (true = persistent across sessions)
end

local last_fx_count = {}
local vu_index_cache = {}
local last_state = reaper.GetProjectStateChangeCount(0)

local function checkFX()
    local state = reaper.GetProjectStateChangeCount(0)
    if state ~= last_state then
        last_state = state
        local num_tracks = reaper.CountTracks(0)

        for i = 0, num_tracks - 1 do
            local track = reaper.GetTrack(0, i)
            local fx_count = reaper.TrackFX_GetCount(track)
            local prev_count = last_fx_count[i] or 0

            if fx_count > prev_count then
                -- find or use cached VU
                local vu_index = vu_index_cache[i]
                if not vu_index or vu_index >= fx_count then
                    vu_index = nil
                    for j = 0, fx_count - 1 do
                        local _, fx_name = reaper.TrackFX_GetFXName(track, j, "")
                        if fx_name:find(vu_name, 1, true) then
                            vu_index = j
                            break
                        end
                    end
                    vu_index_cache[i] = vu_index
                end

                if vu_index then
                    for fx = prev_count, fx_count - 1 do
                        if fx > vu_index then
                            reaper.TrackFX_CopyToTrack(track, fx, track, vu_index, true)
                            vu_index = vu_index + 1
                        end
                    end
                    vu_index_cache[i] = vu_index
                end
            end

            last_fx_count[i] = fx_count
        end
    end

    reaper.defer(checkFX)
end

checkFX()
