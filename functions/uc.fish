#!/usr/bin/fish

# Load dependencies
set -l cmd (command basename (status -f) | command cut -f 1 -d '.')
set -l path (status filename | command xargs dirname)/..
source $path/dependency.fish \
-n $cmd -N unsplash-wallpaper grep sed curl
or exit 1

# Set variables
set -l collections_list $path/collections_list
set --query wallpapers_folder
or set -l wallpapers_folder $HOME/Pictures/wallpapers
set --query wallpaper_cache
or set -l wallpaper_cache 10

# Parse arguments
if argparse -n $cmd -x a,r,u,f,c,l,h 'a/add' 'r/remove' 'u/url' 'f/folder=' 'c/cache=' 'l/list' 'h/help' -- $argv 2>&1 | read err
  err $err
  reg "Use |$cmd -h| to see examples of valid syntaxes"
  exit 1
end

# Check for flags, arguments, and collection lists
set -l flag (set --name | string match -r '(?<=^_flag_).{2,}')
if string match -qr '^(add|remove|url)$' $flag
  if test -z "$argv"
    err "$cmd: Missing argument"
    source "$path/instructions.fish $cmd -a/--\S+"
    exit 1
  end
end
if string match -qr '^(remove|url|list|)$' $flag
  if not test -s "$collections_list"
    err "$cmd: No collections list currently exists"
    reg "Start one using |$cmd --add|"
    exit 1
  end
end

switch "$flag"
  case help
    source "$path/instructions.fish $cmd -a/--\S+"
    test -z "$argv"

  case list
    command cat $collections_list
    test -z "$argv"

  case url
    command printf '%s\n' https://unsplash.com/collections/{(string join , $argv)}

  case folder
    if test -z "$argv"
      echo "$wallpapers_folder"
      exit 0
    end
    string match "$wallpapers_folder" "$argv"
    and exit 0
    if command mkdir -p "$argv" 2>&1 | read err
      err "$cmd: "(string match -r '(?<=mkdir: ).+'$err)
      exit 1
    end
    command mv $wallpapers_folder/* "$argv" 2>/dev/null
    set -U wallpapers_folder "$argv"
    win "Wallpapers folder set to |$wallpapers_folder|"

  case cache
    if string match -qvr '\d' $_flag_cache
      err "$cmd: $_flag_cache: Invalid value"
      source "$path/instructions.fish $cmd -a/--\S+"
      exit 1
    end
    set -U wallpaper_cache $_flag_cache
    win "Wallpaper cache size se to |$wallpaper_cache|"

  case remove
    set -l list_length (cat $collections_list | command wc -l)
    for collection in $argv
      command sed -ie "2,\${ /^$collection\b/d;/\b$collection\$/d }" $collections_list
    end
    test (command cat $collections_list | command wc -l) -eq $list_length
    and dim "None of the collections passed is currently listed"
    or win "Collections removed"

  case add

    # Verify argument validity
    if echo (math (count $argv) / 3) $argv[(command seq 2 3 (count $argv))] \
    | string match -qvr '\d'
      err "$cmd: Invalid syntax"
      source "$path/instructions.fish $cmd -a/--\S+"
      exit 1
    end

    # Check collection availability
    for i in (command seq 1 3 (count $argv) | command sort -r)
      if not contains $argv[$i] \
      $collections[(command seq 1 3 (count $collections))]
        command curl --connect-timeout 60 -o /dev/null \
        -sIf https://unsplash.com/collections/$argv[$i]
        and continue
        err "$cmd: $argv[$i]: Collection was not found. Check its number or your connection."
      else
        dim "Collection |$argv[$i]| already present in the collection list"
      end
      set --erase argv[$i..(math $i + 2)]
    end
    test "$argv"
    or exit 1

    # Add contents to collection list
    set -l parameters Collection Photocount Name
    set -l collections (command tail +2 "$collections_list" 2>/dev/null \
    | string match -ar '\S+')
    for i in (command seq (count $parameters))
      echo $parameters[$i] > "$PREFIX"/tmp/$parameters[$i]
      command printf '%s\n' $collections[(seq $i 3 (count $collections))] \
      $argv[(command seq $i 3 (count $argv))] \
      >> "$PREFIX"/tmp/$parameters[$i]
    end
    command pr -mt "$PREFIX"/tmp/{(string join , $parameters)} > "$collections_list"
    command rm "$PREFIX"/tmp/{(string join , $parameters)}

  case ''

    # Select a listed collection at random if none was passed
    if test -z "$argv"
      set argv (tail +2 "$collections_list" 2>/dev/null \
      | string match -ar '\S+')
      if test -z "$argv"
        err "$cmd: No collection described and no collection list available"
        exit 1
      end
      set argv $argv[(command seq 2 3 (count $argv))]
      for i in (command seq 2 (count $argv))
        set argv[$i] (math $argv[$i] + $argv[(math $i - 1)])
      end
      set -l lottery (random 1 $argv[-1])
      for i in (command seq (count $argv))
        test $lottery -le $argv[$i]
        or continue
        set -l tmp (grep -oP '^\d+' "$collections_list")
        set argv $tmp[$i]
        break
      end
    end

    # Retrieve wallpaper and, if possible, set it as the current wallpaper
    command mkdir -p $wallpapers_folder
    cd $wallpapers_folder
    eval (command whereis unsplash-wallpaper | awk '{print $2}') -o $argv 1>&2
    or exit 1
    set wallpapers (ls -t | string match -ar '^wallpaper-.+\.jpe?g$')
    if type -qf gsettings
      set -l PID (command pgrep gnome-session)
      set -x DBUS_SESSION_BUS_ADDRESS \
      (command grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ | command cut -d= -f2-)
      command gsettings set org.gnome.desktop.background picture-uri \
      file://(command realpath $wallpapers[1])
      command gsettings set org.gnome.desktop.screensaver picture-uri \
      file://(command realpath $wallpapers[1])
    else if type -qf termux-wallpaper
      command termux-wallpaper -f $wallpapers[1] >/dev/null 2>&1
      command termux-wallpaper -lf $wallpapers[1]
    end

    # Delete old wallpapers according to cache size
    test (count $wallpapers) -gt $wallpaper_cache
    and command rm $wallpapers[(math $wallpaper_cache + 1)..-1]
    prevd
end
