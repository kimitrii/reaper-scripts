-- @description Set next color from custom palette
-- @version 1.2
-- @author Kimitri

-- Custom Pallete
local palette = {
  0x906BFA | 0x1000000,
  0xD86BFA | 0x1000000,
  0xEE65CB | 0x1000000,
  0xF36889 | 0x1000000,
  0xF3845D | 0x1000000,
  0xF3D161 | 0x1000000,
  0x54D362 | 0x1000000,
  0x1EDFAD | 0x1000000,
  0x00B6F1 | 0x1000000,
  0xABCDFF | 0x1000000,
  0xD1E4FF | 0x1000000
}

local paletteSize = #palette
local section = "TrackColorCycle"
local key = "Index"

-- Retrieve the index of the last used color
local idx = tonumber(reaper.GetExtState(section, key)) or 0

-- Go to the next color
idx = (idx % paletteSize) + 1

-- Apply the color to all selected tracks
local selCount = reaper.CountSelectedTracks(0)
if selCount > 0 then
  for i = 0, selCount - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    reaper.SetTrackColor(track, palette[idx])
  end
end

-- Save the last used color
reaper.SetExtState(section, key, tostring(idx), true)
