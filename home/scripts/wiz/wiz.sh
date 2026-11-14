BULB=${BULB:-192.168.10.111}

send() {
  for _ in 1 2; do
    echo -n "$1" > /dev/udp/"$BULB"/38899
  done
}

case $1 in
  hex)
    h=${2#\#}
    if [ ${#h} -ne 6 ]; then
      echo "usage: wiz hex #rrggbb [dimming]" >&2
      exit 1
    fi
    send "{\"method\":\"setPilot\",\"params\":{\"state\":true,\"r\":$((16#${h:0:2})),\"g\":$((16#${h:2:2})),\"b\":$((16#${h:4:2})),\"dimming\":${3:-60}}}"
    ;;
  temp) send "{\"method\":\"setPilot\",\"params\":{\"state\":true,\"temp\":$2,\"dimming\":${3:-50}}}" ;;
  on)   send '{"method":"setPilot","params":{"state":true}}' ;;
  off)  send '{"method":"setPilot","params":{"state":false}}' ;;
  *)    echo "usage: wiz {hex #rrggbb [dim] | temp K [dim] | on | off}" >&2; exit 1 ;;
esac
