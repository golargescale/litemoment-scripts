-- =========================================================================
-- VLC Video Auto Clip Tool
-- Description: Get the currently playing video file path and playback time from VLC, 
--              rewind 20 seconds, and clip a 30-second segment.
-- Author: webmaster@litemoment.com
-- Version: 1.0
-- Last Modified: 2026-05-18
-- =========================================================================

-- ★★★★★ Change ffmpeg paths here ★★★★★
property ffprobeBin : "/opt/homebrew/bin/ffprobe"
property ffmpegBin : "/opt/homebrew/bin/ffmpeg"

-- Helper function: Get video resolution
on getVideoDimensions(filePath)
    try
        set ffprobeCmd to ffprobeBin & " -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 " & quoted form of filePath
        set dimensions to do shell script ffprobeCmd
        set {width, height} to {word 1 of dimensions as integer, word 2 of dimensions as integer}
        return {width, height}
    on error
        return {0, 0}
    end try
end getVideoDimensions

-- Helper function: Check if aspect ratio is approximately 16:9 (±0.1 tolerance)
on isAspectRatio169(width, height)
    if height = 0 then return false
    set aspect to width / height
    set target to 16.0 / 9.0  -- ≈1.7778
    set tolerance to 0.1
    return (aspect > (target - tolerance) and aspect < (target + tolerance))
end isAspectRatio169

on run argv
    -- ★★★★★ Change this to your desired output folder ★★★★★
    set outputDir to (system attribute "HOME") & "/.litemoment/media/trim"
    
    -- Default values
    set typeStr to "LITE"
    set hindSightSecs to 20
    set trimLength to 30
    
    -- Parse up to 3 arguments
    set argCount to count of argv
    if argCount > 0 then
        set typeStr to item 1 of argv as string
    end if
    if argCount > 1 then
        set hindSightSecs to (item 2 of argv) as integer
    end if
    if argCount > 2 then
        set trimLength to (item 3 of argv) as integer
    end if
    
    -- Validate: both integers must be between 5 and 180
    if hindSightSecs < 5 then set hindSightSecs to 5
    if hindSightSecs > 180 then set hindSightSecs to 180
    
    if trimLength < 5 then set trimLength to 5
    if trimLength > 180 then set trimLength to 180
    
    -- Your trimming logic here using typeStr, hindSightSecs, trimLength

    -- 1. Get video info and current time from VLC
    tell application "VLC"
      -- Use more reliable syntax to get file path
      set filePath to get path of current item
      set currentPos to current time as integer
    end tell

    -- Check if path is valid
    if filePath is missing value or filePath is "" then
      display dialog "Error: Could not get the currently playing file path from VLC." buttons {"OK"} default button 1 with icon stop
      error number -128
    end if

    -- 2. Ensure output directory exists
    do shell script "mkdir -p " & quoted form of outputDir

    -- 3. Calculate clip parameters
    set startTime to currentPos - hindSightSecs
    if startTime < 0 then set startTime to 0
    set clipDuration to trimLength

    -- 4. Generate output filename
    set origFileName to do shell script "basename " & quoted form of filePath
    set fileNameWithoutExt to do shell script "echo " & quoted form of origFileName & " | sed 's/\\.[^.]*$//'"
    set outputFileName to fileNameWithoutExt & "_clip_" & startTime & "s-" & typeStr & ".mp4"
    set outputPath to outputDir & "/" & outputFileName

    -- 5. Get video resolution and check aspect ratio
    set {vidWidth, vidHeight} to getVideoDimensions(filePath)
    set is16by9 to isAspectRatio169(vidWidth, vidHeight)

    -- 6. Select ffmpeg parameters based on aspect ratio
    if is16by9 then
        -- 16:9 video uses re-encoding (precise trimming)
        set ffmpegCmd to ffmpegBin & " -i " & quoted form of filePath & " -ss " & startTime & " -t " & clipDuration & " -c:v libx264 -preset fast -crf 23 -c:a aac " & quoted form of outputPath
        set encodeMode to "Re-encode (Precise)"
    else
        -- Non-16:9 video uses stream copy (fast, may be imprecise)
        -- Note: Placing -ss before -i fast-seeks to keyframes, but start point may not be exact
        set ffmpegCmd to ffmpegBin & " -ss " & startTime & " -i " & quoted form of filePath & " -t " & clipDuration & " -c:v copy -c:a copy " & quoted form of outputPath
        set encodeMode to "Stream Copy (Fast)"
    end if

    try
      do shell script ffmpegCmd
      -- On success, send notification (auto-dismissing)
      display notification "File saved to: " & outputDir with title "Video Clip Successful" subtitle (fileNameWithoutExt & " has been saved")
    on error errMsg
      -- On failure, send notification (auto-dismissing)
      display notification errMsg with title "Clip Failed" subtitle "Please check if FFmpeg is installed"
    end try

end run