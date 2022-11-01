#!/bin/bash

# Makes json log messages human readable, by parsing the json and pretty-printing
# the app specific interesting fields.


if [ -z `which jq` ]; then
  echo "Please install 'jq' for Json pretty print, e.g.:  sudo apt install jq"
  exit 1
fi

# -r preserves backslashes, otherwise '\n' gets converted to just 'n', and we can no longer
# pretty-print e.g. stacktraces with newlines.
while read -r line
do
  # Remove Docker's color codes.
  line=$(echo "$line" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")

  # We'll add our own colors, here're some codes:
  # (from http://misc.flogisoft.com/bash/tip_colors_and_formatting)
  # \e[34m = blue
  # \e[95m = light magenta
  # \e[32m = green
  # \e[33m = yellow
  # \e[90m = dark gray
  # \e[92m = light green
  # \e[39m = default

  if [[ "$line" =~ ^web_ ]] ; then
    echo -e "`echo "$line" | sed -r 's/^([^|]+\|)(.*)$/\\\\e[34m\1\\\\e[39m\2/'`"
  elif [[ "$line" =~ ^rdb_ ]] ; then
    echo -e "`echo "$line" | sed -r 's/^([^|]+\|)(.*)$/\\\\e[95m\1\\\\e[39m\2/'`"
  elif [[ "$line" =~ ^cache_ ]] ; then
    echo -e "`echo "$line" | sed -r 's/^([^|]+\|)(.*)$/\\\\e[32m\1\\\\e[39m\2/'`"
  elif [[ "$line" =~ ^search_ ]] ; then
    echo -e "`echo "$line" | sed -r 's/^([^|]+\|)(.*)$/\\\\e[33m\1\\\\e[39m\2/'`"
  elif [[ "$line" =~ ^gulp_ ]] ; then
    echo -e "`echo "$line" | sed -r 's/^([^|]+\|)(.*)$/\\\\e[90m\1\\\\e[39m\2/'`"
  elif [[ "$line" =~ ^app_ ]] ; then
    # The program 'jq' extracts the timestamp, severity, message etc fields from a json log message.
    # The -j flag removes surrounding quotes.
    json=$( egrep -o '\{".*\}' <<< "$line" )
    if [ -n "$json" ]; then
      pretty_json=$(echo "$json" | jq -j '.severity, "  ", .message, "  kvs: ", .kvs' )
      app="$(echo "$line" | sed -r 's/^([^|]+\|)(.*)$/\1/')"
      echo -e "\e[92m$app\e[39m $pretty_json"
    else
      # In dev mode, when compiling & reloading, Play Framework logs non-json messages.
      echo -e "`echo "$line" | sed -r 's/^([^|]+\|)(.*)$/\\\\e[92m\1\\\\e[39m\2/'`"
    fi
  else
    echo "$line"
  fi
done

