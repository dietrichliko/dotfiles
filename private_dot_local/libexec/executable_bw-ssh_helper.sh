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
        id="8befbdec-876d-4403-896b-823e38b98aad"
        ;;
    liko@lxplus*.cern.ch)
        id="5a127c4b-6b03-4660-828c-58dc40f2a5b2"
        ;;
    *)
        echo "Unknown: ${BASH_REMATCH[1]}"
        exit 1
        ;;
esac

bw get "$object" "$id"

