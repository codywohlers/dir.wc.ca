#!/bin/bash
# create-dir-entry.sh DOMAIN NAME
# create html to add to dir.wc.ca for a new site
# part of dir.wc.ca project
#
# DOMAIN - xxx.yyy or xxx.yyy.zzz
# NAME - The site name as a single string
#
# - get favicon
# - get country
# - output html

# 2025-Jan-04 code@codwyohlers.ca - add empty country check, change URL to DOMAIN, only check root domain for whois, remove trailing / from favicon
# 2025-Jan-03 code@codwyohlers.ca - changed argument to not need https.  added svg to allowed favicon extensions
# 2025-Jan-01 code@codwyohlers.ca - initial creation.


if [ -z "$1" ] ;then echo "Error: No DOMAIN provided" >&2 ;exit 1 ;fi
if [ -z "$2" ] ;then echo "Error: No NAME provided" >&2 ;exit 1 ;fi

DOMAIN="$1"
#DOMAIN="https://fast.com"
NAME="$2"

cd ~/tmp

# check if valid DOMAIN (from https://stackoverflow.com/a/3184819/3394887)
#regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
#if [[ ! "$DOMAIN" =~ $regex ]] ;then echo "Error: Invalid DOMAIN: $DOMAIN" ;exit 1 ;fi

# remove http(s):// and trailing / if present
DOMAIN=`echo "$DOMAIN" |sed 's|^https*://||' |sed 's|/$||'`

# fake the user-agent so gay bot detection doesn't be gay
#USER_AGENT='Mozilla/5.0 (Windows NT 10.0; Win64; x64) Gecko/20100101 Firefox/100.0'


# use headless chrome to get a rendered dom html.
#DATA=$(google-chrome --user-agent="$USER_AGENT" --incognito --headless --dump-dom "$DOMAIN" 2>/dev/null)
DATA=$(google-chrome --incognito --headless --dump-dom "https://""$DOMAIN" 2>/dev/null)
# Use for testing with a file as an argument:
#DATA="$(cat "$1")"


# get favicon and save as useful filename.
FAVICON_URL=`echo "$DATA" |grep link |grep \"icon\" |head -n1 |grep -oe 'href="[^"]*' |sed 's/^href="//'`
regex='^https://'
if [[ ! "$FAVICON_URL" =~ $regex ]] ;then 
	FAVICON_URL="https://$DOMAIN/"`echo "$FAVICON_URL"`
fi

echo "favicon = $FAVICON_URL"
EXT=`echo $FAVICON_URL |sed 's/.*\.//' |sed 's|/$||'`
if [ "$EXT" == "png" ] || [ "$EXT" == "ico" ] || [ "$EXT" == "svg" ] ;then
	#curl -o  $DOMAIN.$EXT "$FAVICON_URL"
	wget -nv -O $DOMAIN.$EXT "$FAVICON_URL"
	if [ $? = 0 ] ;then
		mv -iv $DOMAIN.$EXT "$HOME/Projects/dir.wc.ca/html/img/"
	else
		echo "favicon download error" >&2
	fi
else
	echo "favicon extension \"$EXT\" unknown, not downloading" >&2
fi


ROOT_DOMAIN=`echo "$DOMAIN" |sed 's/^[^.]*\.\([^.]*\.\)/\1/'`
echo "root domain = $ROOT_DOMAIN"
COUNTRY_CODE=`whois "$ROOT_DOMAIN" |grep -im1 country |sed 's/[ \t]*$//' |grep -o [A-Z][A-Z]$`
#COUNTRY_CODE="US"
echo "country = $COUNTRY_CODE"

if [ ! -z $COUNTRY_CODE ] ;then
	COUNTRY_NAME=`cat "/media/mammoth/library/data/country-code-names.txt" |grep "^$COUNTRY_CODE" |sed "s/^$COUNTRY_CODE //"`
	COUNTRY_FLAG=`cat "/media/mammoth/library/data/country-code-flags.txt" |grep "^$COUNTRY_CODE" |sed "s/^$COUNTRY_CODE //"`
fi

OUT="<tr><td class=\"center\"><a href=\"https://$DOMAIN\"><img src=\"../../img/$DOMAIN.$EXT\" height=50></a> </td>
    <td><a href=\"https://$DOMAIN\">$NAME</a></td>
	<td class=\"small-font left-pad\"><span title=\"$COUNTRY_NAME\">$COUNTRY_FLAG</span> $DOMAIN</td>
</tr>"

echo
echo "$OUT"
echo "$OUT" |xclip -selection clip-board
echo
echo "HTML copied to clipboard."


