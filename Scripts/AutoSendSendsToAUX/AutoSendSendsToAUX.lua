-- @description Create sends from selected track to all tracks inside AUX folder (if selected is not inside AUX, and avoiding duplicates)
-- @version 1.0
-- @author Kimitri

-- Checks if the track is inside the AUX folder
local function IsInsideAUXFolder(track)
  local parent = reaper.GetParentTrack(track)
  while parent do
    local _, parentName = reaper.GetTrackName(parent)
    if parentName == "AUX" then
      return true
    end
    parent = reaper.GetParentTrack(parent)
  end
  return false
end

-- Finds the AUX folder track
local function GetAUXFolder()
  local numTracks = reaper.CountTracks(0)
  for i = 0, numTracks - 1 do
    local tr = reaper.GetTrack(0, i)
    local _, name = reaper.GetTrackName(tr)
    if name == "AUX" then
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
  local sendCount = reaper.GetTrackNumSends(source, 0) -- 0 = sends normais
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

local selTrack = reaper.GetSelectedTrack(0, 0)
if selTrack then
  if not IsInsideAUXFolder(selTrack) then
    local auxFolder = GetAUXFolder()
    local auxTracks = GetTracksInsideFolder(auxFolder)
    for _, tr in ipairs(auxTracks) do
      if not SendExists(selTrack, tr) then
        reaper.CreateTrackSend(selTrack, tr)
      end
    end
  end
end

reaper.Undo_EndBlock("Create sends from selected track to AUX children (no duplicates)", -1)
