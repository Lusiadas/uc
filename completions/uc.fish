# Load dependency
source -- (command dirname (status -f))/../dependency.fish -P https://gitlab.com/argonautica/contains_opts

# Set variables
set -l cmd (command basename (status -f) | command cut -f 1 -d '.')
set -l flags u url a add r remove f folder c cache l list h help
set -l list (eval $cmd -l | tail +2 | string match -ar '\S+')
set -l numbers $list[(command seq 1 3 (count $list))]
set -l names $list[(command seq 3 3 (count $list))]

# Add completions
complete -xc $cmd -n 'not contains_opts' -s u -l url \
-d "Present the urls of specified collections."
complete -xc $cmd -n 'not contains_opts' -s a -l add \
-d 'Add a new collection to the list'
complete -xc $cmd -n 'not contains_opts' -s r -l remove \
-d 'Remove a collection from the list'
complete -rc $cmd -n 'not contains_opts' -s f -l folder \
-d 'Set where images are stored'
complete -xc $cmd -n 'not contains_opts' -s c -l cache \
-d 'Set the size of the image cache'
complete -c $cmd -n 'not contains_opts' -s l -l list \
-d 'Show listed collections'
complete -c $cmd -n 'not contains_opts' -s h -l help \
-d 'Display instructions'
for i in (command seq (count $numbers))
  complete -fc $cmd -n "not contains_opts (string match -rv -- '^(u|url|r|remove)\$' $flags)" -a "$numbers[$i]" -d "$names[$i]"
end
