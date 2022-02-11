
(* 
Export Apple Photos
===================

Exports all photos in Apple Photos library . 
The photos are exported "with using originals". 


TODO
----

* Albums in the top folder (i.e. outside any folder) aren't exported. 
  Only albums in folders are exported. To list them run this:

    tell application "Photos"
        repeat with alb in albums
            log (get name of alb)
        end repeat
    end tell

References
----------

[1] https://apple.stackexchange.com/questions/410229/applescript-photos-export-quality

*)

tell application "Finder"
	set exportLocation to (choose folder with prompt "Choose a folder to export into") as text
end tell

-- main
tell application "Photos"
	repeat with topFolder in folders
		my processFolder(topFolder, 0, (get name of topFolder), exportLocation)
	end repeat
end tell


-- recursively scan folders and export albums
on processFolder(fold, level, dirpath, dest)
	tell application "Photos"
		log "Folder " & (get name of fold)
		repeat with subFolder in (get folders of fold)
			set subPath to dirpath & "/" & (get name of subFolder)
			my exportAlbum(subFolder, subPath)
			my processFolder(subFolder, level + 1, subPath)
		end repeat
		my exportAlbum(fold, dirpath, dest)
	end tell
end processFolder


-- export all albums in folder `f`
on exportAlbum(f, relativePath, dest)
	
	tell application "Photos"
		repeat with i in (get albums of f)
			set tFolder to (the POSIX path of (dest as string) & relativePath & "/" & (get name of i)) as POSIX file as text
			repeat 1 times
				tell application "Finder"
					if exists tFolder then
						log "Skipping album " & (get name of i)
						exit repeat
					end if
				end tell
				log "Album " & (get name of i) & " -> " & tFolder as POSIX file as text
				my makeFolder(tFolder) -- create a folder named (the name of this album) in dest
				with timeout of 120 * 60 seconds -- 2 hours
					
					export (get media items of i) to (tFolder as alias) with using originals
				end timeout
			end repeat
		end repeat
	end tell
end exportAlbum


-- util mkdir
on makeFolder(tPath)
	do shell script "mkdir -p " & quoted form of POSIX path of tPath
end makeFolder