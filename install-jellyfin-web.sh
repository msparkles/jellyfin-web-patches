#!/bin/sh

function semverParseInto() {
    local RE='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
    #MAJOR
    eval $2=`echo $1 | sed -e "s#$RE#\1#"`
    #MINOR
    eval $3=`echo $1 | sed -e "s#$RE#\2#"`
    #MINOR
    eval $4=`echo $1 | sed -e "s#$RE#\3#"`
    #SPECIAL
    eval $5=`echo $1 | sed -e "s#$RE#\4#"`
}

MAJOR=0
MINOR=0
PATCH=0
SPECIAL=""

semverParseInto $(pacman -Q jellyfin-server | sed "s/jellyfin-server //") MAJOR MINOR PATCH SPECIAL

PROJDIR=$PWD

echo "Project dir: $PROJDIR"

cd "$PROJDIR/jellyfin-web" || exit

echo "Jellyfin version: $MAJOR.$MINOR.z"

git checkout "release-$MAJOR.$MINOR.z" || exit
git reset origin/"release-$MAJOR.$MINOR.z" --hard || exit
git apply --verbose "$PROJDIR/patches"/* || exit

npm install || exit
npm run build:production || exit

mkdir -p /usr/share/jellyfin || exit
rm -rf /usr/share/jellyfin/web || exit
mv dist /usr/share/jellyfin/web || exit
