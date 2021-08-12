#!/bin/bash
#
# Adapted from https://github.com/GoogleCloudPlatform/deploymentmanager-samples.git
#
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ============================================================================== #
# Environment Variables
#
# LUSTRE_VERSION
#
# LUSTRE_CLIENT_VERSION
#
# E2FS_VERSION
# ============================================================================== #



ost_mount_point="/mnt/ost"
mdt_mount_point="/mnt/mdt"
LUSTRE_URL="https://downloads.whamcloud.com/public/lustre/${LUSTRE_VERSION}/el7/server/RPMS/x86_64/"
LUSTRE_CLIENT_URL="https://downloads.whamcloud.com/public/lustre/${LUSTRE_CLIENT_VERSION}/el7/client/RPMS/x86_64/"
E2FS_URL="https://downloads.whamcloud.com/public/e2fsprogs/${E2FS_VERSION}/el7/RPMS/x86_64/"

# Array of all required RPMs for Lustre
LUSTRE_RPMS=("kernel-3*.rpm"
"kernel-devel-*.rpm" 
"kernel-debuginfo-common-*.rpm"
"lustre-2*.rpm"
"lustre-ldiskfs-dkms-*.rpm"
"lustre-osd-ldiskfs-mount-*.rpm"
"kmod-lustre-2*.rpm"
"kmod-lustre-osd-ldiskfs-*.rpm")

LUSTRE_CLIENT_RPMS=("kmod-lustre-client-2*.rpm"
"lustre-client-2*.rpm")

# Array of all required RPMs for E2FS
E2FS_RPMS=("e2fsprogs-1*.rpm"
"e2fsprogs-libs-1*.rpm"
"libss-1*.rpm"
"libcom_err-1*.rpm")

# Install updates and minimum packages to install Lustre
function yum_install() {
	yum update -y
	yum install -y net-snmp-libs expect patch dkms gcc libyaml-devel mdadm epel-release pdsh
}

# Set Message of the Day declaring that Lustre is being installed
function start_motd() {
	motd="*** Lustre is currently being installed in the background. ***
***  Please wait until notified the installation is done.  ***"
	echo "$motd" > /etc/motd
}

#Set Message of the Day to show Lustre cluster information and declare the Lustre installation complete
function end_motd() {
	echo -e "Welcome to the Google Cloud Lustre Deployment!\nLustre MDS: $MDS_HOSTNAME\nLustre FS Name: $FS_NAME\nMount Command: mount -t lustre $MDS_HOSTNAME:/$FS_NAME <local dir>" > /etc/motd
	wall -n "*** Lustre installation is complete! *** "
	wall -n "`cat /etc/motd`"
}

# Wait in a loop until the internet is up
function wait_for_internet() {
	time=0
	#Loop over one ping to google.com, and while no response
	while [ `ping google.com -c1 | grep "time=" -c` -eq 0 ]; do
		sleep 5
		let time+=1
		# If we try 60 times (300 seconds) without success, abort
		if [ $time -gt 60 ]; then
			echo "Internet has not connected. Aborting installation."
			exit 1
		fi
	done
}

# Delete RPMs after installation
function cleanup() {
	rm -rf /lustre/*.rpm
}

# Install Lemur Lustre HSM Data Mover
function install_lemur() {
	yum install -y wget go make rpm-build libselinux-devel libyaml-devel zlib-devel
	yum groupinstall -y "Development Tools" --skip-broken

	mkdir -p /lustre
	cd /lustre

	git clone https://github.com/GoogleCloudPlatform/storage-lemur.git
	cd storage-lemur

	sudo make local-rpm

	rpm -ivh /root/rpmbuild/RPMS/x86_64/*.rpm

}

function install_lustre_client() {

	yum install -y git

	git clone git://git.whamcloud.com/fs/lustre-release.git && cd lustre-release
	git checkout 2.10.8

	yum install -y kernel-devel kernel-headers kernel-debug libtool libyaml-devel libselinux-devel zlib-devel rpm-build

	sh ./autogen.sh
	./configure --disable-server --with-o2ib=no --enable-client
	make rpms

	mkdir -p /lustre/lustre_client_release
	cp *.rpm /lustre/lustre_client_release/
	rpm -ivh /lustre/lustre_client_release/${LUSTRE_CLIENT_RPMS[@]}

}

function main() {

	start_motd
	wait_for_internet
	# Install wget
	yum install -y wget

	mkdir /lustre
	cd /lustre

	# Update and install packages in background while RPMs are downloaded
	yum_install &

	# Loop over RPM arrays and download them locally
	for i in ${LUSTRE_RPMS[@]}; do wget -r -l1 --no-parent -A "$i" ${LUSTRE_URL} -P /lustre; done
	for i in ${E2FS_RPMS[@]}; do wget -r -l1 --no-parent -A "$i" ${E2FS_URL} -P /lustre; done
	find /lustre -name "*.rpm" | xargs -I{} mv {} /lustre
	
	# Wait for yum_install for finish
	wait `jobs -p`
	
	# Disable yum-crom, firewalld, and disable SELINUX (Lustre requirements)
	systemctl disable yum-cron.service
	systemctl stop yum-cron
	sed -i -e "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
	systemctl stop firewalld
	systemctl disable firewalld
	
	# Install all downloaded RPMs
	rpm -ivh --force *.rpm
	install_lustre_client
	install_lemur
 
	cleanup

}
main $@
