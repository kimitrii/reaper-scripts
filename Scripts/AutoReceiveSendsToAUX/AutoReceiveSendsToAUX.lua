-- @description Auto Receive Sends to Selected Track if inside AUX folder (ignore folders)
-- @version 1.0
-- @author Kimitri

-- Check if the track is inside a folder named "AUX"
local function IsInsideAUXFolder(track)
  local parent = reaper.GetParentTrack(track)
  if parent then
    local _, parent_name = reaper.GetTrackName(parent)
    if parent_name == "AUX" then
      return true
    end
  end
  return false
end

-- Check if the track is a folder parent
local function IsFolder(track)
  return reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH") == 1
end

-- Check if the track has a parent (is inside any folder)
local function HasParent(track)
  return reaper.GetParentTrack(track) ~= nil
end

local function SendExists(source, dest)
  local sendCount = reaper.GetTrackNumSends(source, 0) -- 0 = normal sends
  for i = 0, sendCount - 1 do
    local sendDest = reaper.GetTrackSendInfo_Value(source, 0, i, "P_DESTTRACK")
    if sendDest == dest then
      return true
    end
  end
  return false
end

function Main()
  local new_track = reaper.GetSelectedTrack(0, 0) -- Get the first selected track
  if not new_track then return end
  
  if IsInsideAUXFolder(new_track) then
    local track_count = reaper.CountTracks(0)
    for i = 0, track_count - 1 do
      local src = reaper.GetTrack(0, i)

      if src ~= new_track and not IsInsideAUXFolder(src) and not IsFolder(src) and HasParent(src) then
        if not SendExists(src, new_track) then
          reaper.CreateTrackSend(src, new_track)
        end
      end
    end
  end
end

reaper.Undo_BeginBlock()
Main()
reaper.Undo_EndBlock("Auto Sends to Selected Track inside AUX folder", -1)
