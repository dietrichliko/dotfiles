#!/bin/bash 

type rbw 2&>1 >/dev/null && exit

case "$(uname -s)" in
    Linux)
        url=$(curl -sL https://api.github.com/repos/doy/rbw/releases/latest | jq -r ".assets[0].browser_download_url")
        tmpname=$(mktemp "/tmp/${url##*/}_XXXXX")
        curl -sLo "$tmpname" "$url"
        tar zxf "$tmpname" -C "$HOME/.local/bin" rbw rbw-agent
        rm "$tmpname"
        ;;
    *) 
        echo "Unsupported OS"
	;;
esac

