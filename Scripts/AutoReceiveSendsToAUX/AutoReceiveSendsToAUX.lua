-- @description Auto Receive Sends to Selected Track if inside chosen AUX folder (ignore folders)
-- @version 1.0
-- @author Kimitri

local EXT_SECTION = "AutoSendsAUX"
local EXT_KEY = "aux_name"

local function GetAuxName()
  local aux_name = reaper.GetExtState(EXT_SECTION, EXT_KEY)

  -- if not found, ask the user
  if aux_name == "" then
    local ret, user_input = reaper.GetUserInputs("Set AUX Folder Name", 1, "Folder name:", "AUX")
    if not ret then return nil end
    aux_name = user_input
    -- save AUX name on state
    reaper.SetExtState(EXT_SECTION, EXT_KEY, aux_name, true)
  end

  return aux_name
end

-- Check if the track is inside the chosen AUX folder
local function IsInsideAUXFolder(track, aux_name)
  local parent = reaper.GetParentTrack(track)
  if parent then
    local _, parent_name = reaper.GetTrackName(parent)
    if parent_name == aux_name then
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
  local aux_name = GetAuxName()
  if not aux_name then return end

  local new_track = reaper.GetSelectedTrack(0, 0) -- Get the first selected track
  if not new_track then return end
  
  if IsInsideAUXFolder(new_track, aux_name) then
    local track_count = reaper.CountTracks(0)
    for i = 0, track_count - 1 do
      local src = reaper.GetTrack(0, i)

      if src ~= new_track and not IsInsideAUXFolder(src, aux_name) and not IsFolder(src) and HasParent(src) then
        if not SendExists(src, new_track) then
          local send_idx = reaper.CreateTrackSend(src, new_track)
          reaper.SetTrackSendInfo_Value(src, 0, send_idx, "I_MIDIFLAGS", -1)
        end
      end
    end
  end
end

reaper.Undo_BeginBlock()
Main()
reaper.Undo_EndBlock("Auto Sends to Selected Track inside chosen AUX folder", -1)
