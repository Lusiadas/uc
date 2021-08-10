set -l bld (set_color 00afff -o)
set -l reg (set_color normal)
set -l instructions $bld"uc - unsplash collections

"$bld"DECRIPTION

List unsplash photo collections from where to get a random wallpaper.

"$bld"OPTIONS

"$bld"uc"$reg" [collection number]
Get a random image from a collection and set it as the new background and screensaver wallpaper. If no collection is specified, a random listed collection will be used instead.

"$bld"uc"$reg" -a/--add [name] [collection number] [photocount] ...
Add a new collection to the list. Its name must not contain whitespaces.

"$bld"uc"$reg" -r/--remove [collection number] ...
Remove a collection from the list.

"$bld"uc"$reg" -u/--url [collection number] ...
Present the urls of specified collections.

"$bld"uc"$reg" -f/-folder [directory]
Set where images are stored. If no directory is passed, display where they are currently being stored.

"$bld"uc"$reg" -c/--cache [number]
Set the size of the image cache.

"$bld"uc"$reg" -l/--list [collection/size/description]
Show listed collections.

"$bld"uc"$reg" -h/--help
Display these instructions.
"
string match -- '*/--\S+' "$argv"
and echo $instructions | grep -A 1 -E "$argv" 1>&2
or echo $instructions | less -R
