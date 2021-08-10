[![GPL License](https://img.shields.io/badge/license-GPL-blue.svg?longCache=true&style=flat-square)](/LICENSE)
[![Fish Shell Version](https://img.shields.io/badge/fish-v3.0.1-blue.svg?style=flat-square)](https://fishshell.com)
[![Oh My Fish Framework](https://img.shields.io/badge/Oh%20My%20Fish-Framework-blue.svg?style=flat-square)](https://www.github.com/oh-my-fish/oh-my-fish)

# uc

> A plugin for [Oh My Fish](https://www.github.com/oh-my-fish/oh-my-fish)

uc (unsplash collections) allows one to list photo collections on unsplash from where to draw a wallpaper at random.

## Options

```
uc [collection number]
Get a random image from a collection and set it as the new background and screensaver wallpaper. If no collection is specified, a random listed collection will be used instead.

uc -a/--add [collection number] ...
Add a new collection to the list.

uc -r/--remove [collection number] ...
Remove a collection from the list.

uc -u/--url [collection number] ...
Present the urls from specified collections.

uc -f/-folder [directory]
Set where images are stored. If no directory is passed, display where they're currently being stored.

uc -c/--cache [number]
Set the size of the image cache.

uc -l/--list [collection/size/description]
Show listed collections.

uc -h/--help
Display these instructions.
```

## Install

```fish
omf repositories add https://gitlab.com/argonautica/argonautica 
omf install uc
```

### Dependencies

This plugin uses [unsplash_wallpaper](https://github.com/cuth/unsplash-wallpaper) by [cuth](https://github.com/cuth) to get wallpapers. If you don't have it installed, you'll be prompted to install it upon installing of this plugin.

## Configuration

This script is optimized to work with environment variables available to [cron](https://en.wikipedia.org/wiki/Cron), so that you can change your background and lockscreen wallpapers periodically and automatically. As an example, to change them every 3 hours, use the command `crontab -e` and append the following line:

```
0 */3 * * * .local/share/omf/pkg/uc/functions/uc.fish
```

For more information on how to schedule tasks using cron, consult this [video](https://www.youtube.com/watch?v=8j0SWYNglcw).
