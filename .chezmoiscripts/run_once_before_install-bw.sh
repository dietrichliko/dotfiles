#!/bin/bash

type bw >/dev/null 2>&1 && exit

case "$(uname -s)" in
    Linux)
        url='https://api.github.com/repos/Bitwarden/clients/releases'
	glibc_version="$(getconf GNU_LIBC_VERSION | cut -d. -f2)"
	if [ "$glibc_version" -le 28 ]; then
            match='bw-oss-linux-.*.zip'
	else
            match='bw-linux-.*.zip'
	fi
        cmd='[.[] | select(.tag_name | startswith("cli"))][0].assets[] | select(.name | match($match)).browser_download_url'
	download_url="$(curl -sL "$url" | jq -r --arg match "$match" "$cmd")"
	tmpname="$(mktemp "/tmp/${url##*/}_XXXXX")"
	curl -sL -o "$tmpname" "$download_url"
	unzip -qq "$tmpname" -d ~/.local/bin
	rm "$tmpname"
	;;
    *) 
        echo "Unsupported OS"
	;;
esac

