#!/bin/bash

wget https://github.com/GoogleCloudPlatform/compute-virtual-ethernet-linux/releases/download/v1.2.2/gve-1.2.2.tar.gz --directory-prefix=/tmp
cd /tmp/ && tar -xvzf gve-1.2.2.tar.gz
make -C /lib/modules/`uname -r`/build M=$(pwd)/build modules modules_install
depmod
modprobe gve
