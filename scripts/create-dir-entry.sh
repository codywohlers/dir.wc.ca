#!/bin/bash
# create-dir-entry.sh URL NAME
# create html to add to dir.wc.ca for a new site
# part of dir.wc.ca project
#
# - get favicon
# - get country
# - output html

# 2025-Jan-01 code@codwyohlers.ca - initial creation.


if [ -z "$1" ] ;then echo "Error: No URL provided" >&2 ;exit 1 ;fi
if [ -z "$2" ] ;then echo "Error: No NAME provided" >&2 ;exit 1 ;fi

URL="$1"
#URL="https://fast.com"
NAME="$2"

cd ~/tmp

# check if valid URL (from https://stackoverflow.com/a/3184819/3394887)
regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
if [[ ! "$URL" =~ $regex ]] ;then echo "Error: Invalid URL: $URL" ;exit 1 ;fi

# fake the user-agent so gay bot detection doesn't be gay
#USER_AGENT='Mozilla/5.0 (Windows NT 10.0; Win64; x64) Gecko/20100101 Firefox/100.0'


# use headless chrome to get a rendered dom html.
#DATA=$(google-chrome --user-agent="$USER_AGENT" --incognito --headless --dump-dom "$URL" 2>/dev/null)
DATA=$(google-chrome --incognito --headless --dump-dom "$URL" 2>/dev/null)
# Use for testing with a file as an argument:
#DATA="$(cat "$1")"


# get favicon and save as useful filename.
FAVICON_URL="$URL"`echo "$DATA" |grep link |grep \"icon\" |head -n1 |grep -oe href=\".*\" |sed 's/"$//' |sed 's/^href="//'`
echo "favicon $FAVICON_URL"
EXT=`echo $FAVICON_URL |sed 's/.*\.//'`
DOMAIN=`echo "$URL" |sed 's|^https*://||' |sed 's|/$||'`
#curl -o  $DOMAIN.$EXT "$FAVICON_URL"
wget -nv -O $DOMAIN.$EXT "$FAVICON_URL"
mv -v $DOMAIN.$EXT "$HOME/Projects/dir.wc.ca/html/img/"


COUNTRY_CODE=`whois "$DOMAIN" |grep -im1 country | grep -o [A-Z][A-Z]$`
#COUNTRY_CODE="US"

COUNTRY_NAME=`cat "/media/mammoth/library/data/country-code-names.txt" |grep "^$COUNTRY_CODE" |sed "s/^$COUNTRY_CODE //"`
COUNTRY_FLAG=`cat "/media/mammoth/library/data/country-code-flags.txt" |grep "^$COUNTRY_CODE" |sed "s/^$COUNTRY_CODE //"`


OUT="<tr><td class=\"center\"><a href=\"$URL\"><img src=\"../../img/$DOMAIN.$EXT\" height=50></a> </td>
    <td><a href=\"$URL\">$NAME</a></td>
	<td class=\"small-font left-pad\"><span title=\"$COUNTRY_NAME\">$COUNTRY_FLAG</span> $DOMAIN</td>
</tr>"

echo "$OUT"
echo "$OUT" |xclip -selection clip-board
echo "Copied to clipboard."


