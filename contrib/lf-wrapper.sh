#!/bin/sh
# This wrapper script is invoked by xdg-desktop-portal-termfilechooser.
#
# Inputs:
# 1. "1" if multiple files can be chosen, "0" otherwise.
# 2. "1" if a directory should be chosen, "0" otherwise.
# 3. "0" if opening files was requested, "1" if writing to a file was
#    requested. For example, when uploading files in Firefox, this will be "0".
#    When saving a web page in Firefox, this will be "1".
# 4. If writing to a file, this is recommended path provided by the caller. For
#    example, when saving a web page in Firefox, this will be the recommended
#    path Firefox provided, such as "~/Downloads/webpage_title.html".
#    Note that if the path already exists, we keep appending "_" to it until we
#    get a path that does not exist.
# 5. The output path, to which results should be written.
#
# Output:
# The script should print the selected paths to the output path (argument #5),
# one path per line.
# If nothing is printed, then the operation is assumed to have been canceled.

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

cmd="/usr/bin/lf"
TERMCMD="/usr/bin/foot"
termcmd="${TERMCMD:-/usr/bin/foot -e}"

info=$(
    cat <<EOF

xdg-desktop-portal-termfilechooser saving files tutorial

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!                 === WARNING! ===                 !!!
!!! The contents of *whatever* file you open last in !!!
!!! ranger will be *overwritten*!                    !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Instructions:
1) Move this file wherever you want.
2) Rename the file if needed.
3) Confirm your selection by opening the file, for
   example by pressing <Enter>.

Notes:
1) This file is provided for your convenience. You
   could delete it and choose another file to overwrite
   that, for example.
2) If you quit ranger without opening a file, this file
   will be removed and the save operation aborted.

EOF
)
if [ "$save" = "1" ]; then
    # Save-file mode:
    # Start with the requested path selected and write the selection to $out.
    set -- \
        -selection-path "$out" \
        -command 'set promptfmt "Select save path (press q to cancel, l/Enter to select)"' \
        "$path"

    # selectfile workaround: create the file if it does not exist.
    if [ ! -e "$path" ]; then
        printf '%s' "$info" > "$path"
    fi

elif [ "$multiple" = "1" ]; then
    # Multiple-file selection.
    # Press <Space> to select files, then use your normal quit/selection workflow.
    set -- \
        -selection-path "$out" \
        -command 'set promptfmt "Select file(s) (Space to select multiple, q to cancel, l/Enter to confirm)"'

elif [ "$directory" = "1" ]; then
    # Directory selection.
    # Start in the requested directory and only allow the user to confirm
    # a directory by selecting it.
    set -- \
        -selection-path "$out" \
        -command 'set promptfmt "Select directory (l/Enter to select, q to cancel)"'

else
    # Normal single-file selection.
    set -- \
        -selection-path "$out" \
        -command 'set promptfmt "Select file (l/Enter to select, q to cancel)"'
fi



# "$termcmd" -- $cmd "$@"
/usr/bin/echo -e "$termcmd" -e $cmd "$@" > /tmp/loglog
"$termcmd" -e $cmd "$@"

if [ "$save" = "1" ] && [ ! -s "$out" ]; then
    rm "$path"
fi
