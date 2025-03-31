#!/bin/bash
#
# Install and update github cli
#
# Dietrich Liko <Dietrich.Liko@oeaw.ac.at>

# https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
verlte() {
    printf '%s\n' "$1" "$2" | sort -C -V
}

# get url of latest release
match='gh_.*_linux_amd64\.tar\.gz'
cmd='.assets[] | select(.name | match($match)) | .browser_download_url'
url=$(curl -s https://api.github.com/repos/cli/cli/releases/latest |\
	jq -r --arg match "$match" "$cmd")

name="${url##*/}"
latest=$(echo $name | cut -d_ -f2)

# if gh is already installed, check the version
set -o pipefail
version=$(gh --version 2> /dev/null | head -n 1 | cut -d\  -f3)
if [ $? -eq 0 ]; then
   verlte "$latest" "$version"
   if [ $? -eq 0 ]; then
       exit
   fi
fi

# install github cli
tmpname="$(mktemp "/tmp/${name}_XXXXXX")"
curl -sLo "$tmpname" "$url"
tar xzf "$tmpname" -C "$HOME/.local" --strip-components 1 --exclude LICENSE
rm "$tmpname"

