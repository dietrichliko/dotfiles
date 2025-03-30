#!/bin/bash

if [[ "$1" =~ \((.*)\)\ Password: ]]; then
   object="password"
elif [[ "$1" =~ \((.*)\)\ Your\ 2nd\ factor\ \(.*\): ]]; then
   object="totp"
else
   echo "No match: $1" >&2
   exit 1
fi

case "${BASH_REMATCH[1]}" in
    dliko@lxplus*.cern.ch)
        id="86e7067a-6e82-41b9-a6f8-add4010274f5"
        ;;
    liko@lxplus*.cern.ch)
        id="614223ea-4ae4-44ec-9f8c-ac5300ea104a"
        ;;
    *)
        echo "Unknown: ${BASH_REMATCH[1]}"
        exit 1
        ;;
esac

bw get "$object" "$id"

