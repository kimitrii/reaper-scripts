-- @description Select child tracks inside folders (exclude folders and AUX)
-- @version 1.0
-- @author Kimitri

function main()
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)

  reaper.Main_OnCommand(40297, 0) -- unselect all

  local auxName = "AUX"
  local auxNameUpper = string.upper(auxName)

  local ignoreAuxDepth = -1
  local trackCount = reaper.CountTracks(0)

  for i = 0, trackCount - 1 do
    local tr = reaper.GetTrack(0, i)
    local depthFlag = reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERDEPTH")
    local depth = reaper.GetTrackDepth(tr)

    -- if inside AUX folder, ignore it
    if ignoreAuxDepth >= 0 then
      if depth > ignoreAuxDepth then
        goto continue -- inside AUX folder
      else
        ignoreAuxDepth = -1 -- out of AUX
      end
    end

    -- check if is AUX folder
    if depthFlag == 1 then
      local _, name = reaper.GetTrackName(tr, "")
      if string.upper(name or "") == auxNameUpper then
        ignoreAuxDepth = depth
        goto continue
      end
    end

    -- select child tracks inside folder
    if depth > 0 and depthFlag <= 0 then
      reaper.SetTrackSelected(tr, true)
    end

    ::continue::
  end

  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock("Select child tracks inside folders (except AUX)", -1)
end

main()
