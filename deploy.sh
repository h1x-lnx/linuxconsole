#!/bin/mksh

set -euo pipefail


deploy()
{
       rsync -avP --delete build/ root@vm0://var/www/linuxconsole.net

       ssh root@vm0 chown -v -R root:nginx /var/www/linuxconsole.net
       ssh root@vm0 chmod -v 750 /var/www/linuxconsole.net
       ssh root@vm0 chmod -v 640 /var/www/linuxconsole.net/*

       exit 0
}


ssl_deploy_c()
{
       in=$(cat "$1")
       in=$(openssl enc -base64 <<< $in)
       len=${#in}

       for i in $(seq 0 $((len - 1))); do

               c=${in:$i:1}
               c_i=$(echo -n "${c}" | od -i -A n)
               c_i=$((c_i + 1))
               c_x=$(printf "0x%x\n" $c_i)
               echo -n "$c_x "

       done

       exit 0
}


ssl_deploy_d()
{
       in=$(cat "$1")
       o=''

       for c_x in $in; do
               c_x=$(sed 's/0x//g' <<< $c_x)
               c_x=$(tr 'a-z' 'A-Z' <<< $c_x)
               c_i=$(echo "ibase=16; $c_x" | bc)
               c_i=$((c_i - 1))
               c=$(printf "\x$(printf "%x" $c_i)")
               o=$o$c

       done
       openssl enc -base64 -d <<< $o
       exit 0
}


[ $# -eq 0 ] && deploy
[ "$1" == "-c" ] && ssl_deploy_c $2
[ "$1" == "-d" ] && ssl_deploy_d $2
