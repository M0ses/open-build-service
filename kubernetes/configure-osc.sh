#!/bin/bash

if [ ! -d /root/.config/osc/ ];then
  mkdir -p /root/.config/osc/
  cat <<EOF > /root/.config/osc/oscrc
[general]
apiurl = https://obs-frontend-rails:7443

[https://obs-frontend-rails:7443]
user = Admin
pass = opensuse
EOF
fi

exit
