setopt NO_SHARE_HISTORY   
setopt NO_EXTENDED_HISTORY
setopt NO_INC_APPEND_HISTORY
zmodload zsh/datetime                          # needed for EPOCHSECONDS
  
HISTSIZE=2000                                  # this zsh's history size
SAVEHIST=2000                                     # never touch HISTFILE
HISTFILE=~/.zshhistory                         # history file name
HISTSTORAGE=~/.zsh_cmd_storage
UUIDFORTHISSHELL="`date +%s`-$$-`hostname`"


# before showing prompt        
precmd() {                     
    if (( LASTTIME > 0 )); then
        # create a HISTLINE with start time and duration
        # (same as zsh's EXTENDED_HISTORY format)
        # local HISTLINE=": $LASTTIME:$(($EPOCHSECONDS-$LASTTIME));$LASTCMD"
        local HISTLINE="$UUIDFORTHISSHELL: $LASTTIMESTAMP [$(($EPOCHSECONDS-$LASTTIME))] $LASTCMD"

        # carefully append HISTLINE to HISTFILE             
        # (using $HISTFILE.lock as a lockfile)              
        local FILE="$HISTSTORAGE"              # set outfile       
        if [[ -e "$FILE.lock" ]]; then         # if lockfile exists
            FILE="$FILE.tmp"                   #   use tempfile as outfile
        elif [[ -e "$FILE.tmp" ]]; then        # no lockfile, but tempfile
            mv "$FILE.tmp" "$FILE.$$" &&       #   hide tempfile from other
               < "$FILE.$$" >>! "$FILE" &&     #   append it to outfile
               rm "$FILE.$$"                   #   and delete tempfile
        fi                                     #
        echo -E "$HISTLINE" >>! "$FILE"        # append last cmd to outfile

        # if VERBOSE
        if [[ -n $VERBOSE ]] then              # talk a bit
            echo -n '\e[31m'                   #   in red
            echo "LASTTIME=$LASTTIME"          #
            echo "LASTCMD=$LASTCMD"            #
            echo "FILE=$FILE"                  #
            echo -E "$HISTLINE"                #
            echo -n '\e[39m'                   #
        fi                                     #
        unset LASTCMD LASTTIME                 #
    fi                                         #

    # allow history sharing between shells
    # BUGGY! Does not work!
    #fc -RI                                     # read new parts of HISTFILE
}

# before running command                                              
preexec() {                                                           
    LASTCMD="${(pj:\\\n:)${(f)1}}"             # remember command line
    LASTTIME="$EPOCHSECONDS"                   #   and time of execution
    LASTTIMESTAMP=`date +%FT%T%:z`             #   and timestamp of execution

    # if VERBOSE
    if [[ -n $VERBOSE ]] then                  # talk a bit
        echo -n '\e[34m'                       #   in red
        local i                                #
        echo "arguments to preexec():"         #   lists preexec's argumens
        for ((i=1; i<=ARGC; i++)) {            #
            echo "    $i: $argv[i]"            #
        }                                      #
        echo "LASTTIME=$LASTTIME"              #
        echo "LASTCMD=$LASTCMD"                #
        echo "FILE=$HISTFILE"                  #
        echo -n '\e[39m'                       #
    fi                                         #
}                                              #
