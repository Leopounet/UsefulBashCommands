function decrease_brightness {
    xrandr --output $(xrandr --current | grep ' connected' | awk ' {print $1} ') --brightness  $(xrandr --verbose | grep Bright | awk ' { print ($2 - 0.05)}')
}

function increase_brightness {
    xrandr --output $(xrandr --current | grep ' connected' | awk ' {print $1} ') --brightness  $(xrandr --verbose | grep Bright | awk ' { print ($2 + 0.05)}')
}