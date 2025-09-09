-- @description Create sends from selected track to all tracks inside chosen AUX folder (if selected is not inside, avoiding duplicates)
-- @version 1.0
-- @author Kimitri

local EXT_SECTION = "AutoSendsAUX"
local EXT_KEY = "aux_name"

local function GetAuxName()
  local aux_name = reaper.GetExtState(EXT_SECTION, EXT_KEY)

  if aux_name == "" then
    local ret, user_input = reaper.GetUserInputs("Set AUX Folder Name", 1, "Folder name:", "AUX")
    if not ret or user_input == "" then return nil end
    aux_name = user_input
    reaper.SetExtState(EXT_SECTION, EXT_KEY, aux_name, true) 
  end

  return aux_name
end

-- Checks if the track is inside the AUX folder
local function IsInsideAUXFolder(track, aux_name)
  local parent = reaper.GetParentTrack(track)
  while parent do
    local _, parentName = reaper.GetTrackName(parent)
    if parentName == aux_name then
      return true
    end
    parent = reaper.GetParentTrack(parent)
  end
  return false
end

-- Finds the AUX folder track
local function GetAUXFolder(aux_name)
  local numTracks = reaper.CountTracks(0)
  for i = 0, numTracks - 1 do
    local tr = reaper.GetTrack(0, i)
    local _, name = reaper.GetTrackName(tr)
    if name == aux_name then
      return tr
    end
  end
  return nil
end

-- Collects all tracks inside the AUX folder
local function GetTracksInsideFolder(folderTrack)
  local tracks = {}
  if not folderTrack then return tracks end

  local idx = reaper.GetMediaTrackInfo_Value(folderTrack, "IP_TRACKNUMBER")
  local numTracks = reaper.CountTracks(0)

  for i = idx, numTracks - 1 do
    local tr = reaper.GetTrack(0, i)
    local depth = reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERDEPTH")
    tracks[#tracks + 1] = tr
    if depth < 0 then break end -- include the last track and exit
  end

  return tracks
end

-- Checks if a send already exists from source to destination
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

-- MAIN
reaper.Undo_BeginBlock()

local aux_name = GetAuxName()
if aux_name then
  local selTrack = reaper.GetSelectedTrack(0, 0)
  if selTrack then
    if not IsInsideAUXFolder(selTrack, aux_name) then
      local auxFolder = GetAUXFolder(aux_name)
      local auxTracks = GetTracksInsideFolder(auxFolder)
      for _, tr in ipairs(auxTracks) do
        if not SendExists(selTrack, tr) then
          local send_idx = reaper.CreateTrackSend(selTrack, tr)
          reaper.SetTrackSendInfo_Value(selTrack, 0, send_idx, "I_MIDIFLAGS", -1)
        end
      end
    end
  end
end

reaper.Undo_EndBlock("Create sends from selected track to " .. (aux_name or "AUX") .. " children (no duplicates)", -1)
