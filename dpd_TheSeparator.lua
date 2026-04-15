-- @description The Separator — Extract Audio from Video
-- @author Dead Pixel Design
-- @version 1.0.0
-- @changelog
--   Initial release
-- @about
--   # The Separator by Dead Pixel Design
--
--   Extracts audio from video items onto dedicated audio tracks in one click.
--
--   ## How to use
--   1. Select one or more video items on the timeline
--   2. Run this action
--   3. A new audio track appears directly below each video track, synced and ready to edit
--   4. The original video item's audio output is silenced — no double-playback
--
--   ## Supported formats
--   MP4, MOV, AVI, MKV, WMV, M4V, WebM, FLV, MTS, M2TS, TS
--
--   ## Notes
--   - Fully undoable (Ctrl+Z / Cmd+Z)
--   - Assign a keyboard shortcut: Actions > Show Action List > search "Separator"
--   - The video item's audio volume is set to 0 (not deleted). Drag it back up in
--     Item Properties if you ever need to restore it.

-- ============================================================
-- The Separator v1.0.0
-- Dead Pixel Design — https://deadpixeldesign.com
-- ============================================================

local VIDEO_EXTENSIONS = {
  mp4  = true, mov  = true, avi  = true, mkv  = true,
  wmv  = true, m4v  = true, webm = true, flv  = true,
  mts  = true, m2ts = true, ts   = true
}

local function isVideoFile(path)
  if not path then return false end
  local ext = path:match("%.([^%.]+)$")
  if not ext then return false end
  return VIDEO_EXTENSIONS[ext:lower()] == true
end

local function getSourceFileName(take)
  local source = reaper.GetMediaItemTake_Source(take)
  if not source then return nil end
  local parent = reaper.GetMediaSourceParent(source)
  if parent then source = parent end
  local filename = reaper.GetMediaSourceFileName(source, "")
  return (filename ~= "") and filename or nil
end

local function darkenColor(packed, amount)
  local r = math.max(0, ((packed >> 16) & 0xFF) - amount)
  local g = math.max(0, ((packed >> 8)  & 0xFF) - amount)
  local b = math.max(0, ( packed        & 0xFF) - amount)
  return (r << 16) | (g << 8) | b
end

-- ============================================================

local function run()

  local itemCount = reaper.CountSelectedMediaItems(0)

  if itemCount == 0 then
    reaper.ShowMessageBox(
      "No items selected.\n\nSelect one or more video items on the timeline, then run this action.",
      "The Separator", 0
    )
    return
  end

  -- Collect items before any track insertions shift indices
  local items = {}
  for i = 0, itemCount - 1 do
    items[#items + 1] = reaper.GetSelectedMediaItem(0, i)
  end

  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)

  local processed = 0
  local skipped   = 0

  for _, item in ipairs(items) do

    local take = reaper.GetActiveTake(item)
    if not take then
      skipped = skipped + 1
      goto continue
    end

    local filename = getSourceFileName(take)
    if not filename or not isVideoFile(filename) then
      skipped = skipped + 1
      goto continue
    end

    local srcTrack  = reaper.GetMediaItem_Track(item)
    -- IP_TRACKNUMBER is 1-based; InsertTrackAtIndex is 0-based.
    -- Passing trackIdx (1-based value) as the 0-based insert index places the
    -- new track immediately below srcTrack.
    local trackIdx  = math.floor(reaper.GetMediaTrackInfo_Value(srcTrack, "IP_TRACKNUMBER"))

    local position  = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local length    = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local startOffs = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")
    local takeVol   = reaper.GetMediaItemTakeInfo_Value(take, "D_VOL")
    local takePitch = reaper.GetMediaItemTakeInfo_Value(take, "D_PITCH")
    local takeName  = reaper.GetTakeName(take)

    -- Create audio track directly below the video track
    reaper.InsertTrackAtIndex(trackIdx, true)
    local audioTrack = reaper.GetTrack(0, trackIdx)

    local _, srcName = reaper.GetTrackName(srcTrack)
    reaper.GetSetMediaTrackInfo_String(audioTrack, "P_NAME", srcName .. " [Audio]", true)

    -- Color-pair with video track (slightly darker for visual grouping)
    local vidColor = reaper.GetTrackColor(srcTrack)
    if vidColor ~= 0 then
      reaper.SetTrackColor(audioTrack, darkenColor(vidColor, 25))
    end

    -- Add the audio item
    local audioItem = reaper.AddMediaItemToTrack(audioTrack)
    reaper.SetMediaItemInfo_Value(audioItem, "D_POSITION", position)
    reaper.SetMediaItemInfo_Value(audioItem, "D_LENGTH",   length)

    local audioTake = reaper.AddTakeToMediaItem(audioItem)
    local audioSrc  = reaper.PCM_Source_CreateFromFile(filename)
    reaper.SetMediaItemTake_Source(audioTake, audioSrc)
    reaper.SetMediaItemTakeInfo_Value(audioTake, "D_STARTOFFS", startOffs)
    reaper.SetMediaItemTakeInfo_Value(audioTake, "D_VOL",       takeVol)
    reaper.SetMediaItemTakeInfo_Value(audioTake, "D_PITCH",     takePitch)

    local audioTakeName = (takeName ~= "") and (takeName .. " [Audio]") or "Audio"
    reaper.GetSetMediaItemTakeInfo_String(audioTake, "P_NAME", audioTakeName, true)

    -- Silence audio on the original video item so it doesn't double-play.
    -- Sets take volume to 0 — fully reversible via Item Properties.
    reaper.SetMediaItemTakeInfo_Value(take, "D_VOL", 0.0)

    processed = processed + 1
    ::continue::
  end

  reaper.PreventUIRefresh(-1)
  reaper.UpdateArrange()
  reaper.TrackList_AdjustWindows(false)
  reaper.Undo_EndBlock("The Separator — Extract Audio from Video", -1)

  if processed == 0 then
    local msg = (skipped > 0)
      and "None of the selected items are recognized video files.\n\nSupported: MP4, MOV, AVI, MKV, WMV, M4V, WebM, FLV, MTS, TS"
      or  "Nothing to process."
    reaper.ShowMessageBox(msg, "The Separator", 0)
  else
    local plural = (processed == 1) and "item" or "items"
    local msg    = processed .. " video " .. plural .. " processed."
    if skipped > 0 then
      msg = msg .. "\n" .. skipped .. " non-video item(s) skipped."
    end
    msg = msg .. "\n\nAudio extracted to new track(s) below.\nFully undoable with Ctrl+Z."
    reaper.ShowMessageBox(msg, "The Separator — Done", 0)
  end

end

run()
