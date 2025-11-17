#!/bin/bash
# Copyright(C) 2025 Lemem Developers. All rights reserved.

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
# >> User-Configuration  <<
user_passwd="$(echo "$HOSTNAME" | sed 's+-.*++g')"
retailer_mode=false
retailer_prod="enabled retailer mode as an example"
# [ Mirrors ]
mirror_alpine="https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/x86_64/alpine-minirootfs-3.22.2-x86_64.tar.gz"
mirror_proot="https://proot.gitlab.io/proot/bin/proot"
#  >> Runtime configuration <<
if "$retailer_mode"; then install_path=$HOME/.subsystem; elif [ -n "$SERVER_PORT" ]; then install_path="$HOME/cache/$(echo "$HOSTNAME" | md5sum | sed 's+ .*++g')"; else install_path="./testing-arena"; fi

d.stat() { echo -ne "\033[1;37m==> \033[1;34m$@\033[0m\n"; }
d.dftr() { echo -ne "\033[1;33m!!! DISABLED FEATURE: \033[1;31m$@ \033[1;33m!!!\n"; }
d.warn() { echo -ne "\033[1;33mwarning: \033[1;31m$@\[033;0m\n"; }

die() {
  echo -ne "\n\033[41m               \033[1;37mA FATAL ERROR HAS OCCURED               \033[0m\n"
  echo -ne "\033[1;31mThe installation cannot continue. Please contact the server administrator.\033[0m\n"
  sleep 5
  exit 1
}

# <dbgsym:bootstrap>
check_link="curl --output /dev/null --silent --head --fail"
bootstrap_system() {

  _CHECKPOINT=$PWD

  d.stat "Initializing the Alpine rootfs image..."
  curl -L "$mirror_alpine" -o a.tar.gz && tar -xf a.tar.gz || die
  rm -rf a.tar.gz

  d.stat "Downloading a Docker Daemon..."
  curl -L "$mirror_proot" -o dockerd || die
  chmod +x dockerd

  d.stat "Bootstrapping system..."
  touch etc/{passwd,shadow,groups}

  # coppy files
  cp /etc/resolv.conf "$install_path/etc/resolv.conf" -v
  cp /etc/hosts "$install_path/etc/hosts" -v
  cp /etc/localtime "$install_path/etc/localtime" -v
  cp /etc/passwd "$install_path"/etc/passwd -v
  cp /etc/group "$install_path"/etc/group -v
  cp /etc/nsswitch.conf "$install_path"/etc/nsswitch.conf -v
  mkdir -p "$install_path/home/container"

./dockerd -r . -b /dev -b /sys -b /proc -b /tmp \
    --kill-on-exit -w /home/container /bin/sh -c "apk update && apk add bash xorg-server git nano vim tmate btop htop fastfetch neofetch python3 py3-pip py3-numpy openssl \
      xinit xvfb fakeroot dropbear qemu qemu-img qemu-system-x86_64 \
    virtualgl mesa-dri-gallium \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main; \
    git clone https://github.com/h3l2f/noVNC1 && \
    cd noVNC1 && \
    openssl req -x509 -sha256 -days 356 -nodes -newkey rsa:2048 -subj '/CN=$(curl -L checkip.pterodactyl-installer.se)/C=US/L=San Fransisco' -keyout self.key -out self.crt && \
    cp vnc.html index.html && \
    ln -s /usr/bin/fakeroot /usr/bin/sudo && \
    pip install websockify --break-system-packages && \
     wget https://cdn.bosd.io.vn/windows11.qcow2 && mv windows11.qcow2 /"

cat >"$install_path/home/container/.bashrc" <<EOF
    echo " 🛑 wm cannot continue. Please contact the server administrator "

EOF

}
# </dbgsym:bootstrap>
DOCKER_RUN="env - \
    HOME=$install_path/home/container $install_path/dockerd --kill-on-exit -r $install_path -b /dev -b /proc -b /sys -b /tmp \
    -b $install_path:$install_path /bin/sh -c"
run_system() {
  if [ -f $HOME/.do-not-start ]; then
    rm -rf $HOME/.do-not-start
    cp /etc/resolv.conf "$install_path/etc/resolv.conf" -v
    $DOCKER_RUN /bin/sh
    exit
  fi
  # Starting NoVNC
  d.stat "Starting noVNC server..."
  $install_path/dockerd --kill-on-exit -r $install_path -b /dev -b /proc -b /sys -b /tmp -w "/home/container/noVNC1" /bin/sh -c "./utils/novnc_proxy --vnc localhost:5901 --listen 0.0.0.0:$SERVER_PORT" &>/dev/null &
  
  d.stat "Your server is now available at \033[1;32mhttp://$(curl --silent -L checkip.pterodactyl-installer.se):$SERVER_PORT"

  # start qemu vm
  d.stat "starting windows 11..."

  $DOCKER_RUN "qemu-system-x86_64 -m "$VM_MEMORY" -smp $(nproc --all) -nic user -drive file=windows11.qcow2 -display vnc=127.0.0.1:1"                         
  
  $DOCKER_RUN bash
}

cd "$install_path" || {
  mkdir -p "$install_path"
  cd "$install_path"
}

[ -d "bin" ] && run_system || bootstrap_system