#!/bin/bash

# Replace 'your_password' with your actual password, and '<my_username>' with the desired username.
my_username="decastrotheo9600@gmail.com"

# Run my_cmd using expect to handle the password prompt.
expect << EOF
spawn protonvpn-cli login $my_username
expect "Enter your Proton VPN password:"
send "$PROTON_PWD\r"
expect eof
EOF

protonvpn-cli disconnect
python3 ~/Desktop/UsefulBashCommands/__vpn/main.py $1
