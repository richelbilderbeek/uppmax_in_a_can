#!/bin/bash

set -e
#set -x

# check if sshfs in is the path
[[ $(command -v sshfs) ]] || printf 'There is no sshfs in your PATH. Please run 

singularity exec uppmax_in_a_can.sif sshfs_extract ; PATH=$PATH:$(pwd) ; ./mount_sshfs.sh

to get a precompiled sshfs executable that could work on your system. If it does not, please install sshfs on your own (https://github.com/libfuse/sshfs).'

# get the uppmax username
echo "UPPMAX username:"
read a
    
# check if anything needs unmounting
read -r mount_sw mount_proj mount_crex mount_home mount_module <<< $(echo 0 0 0 0 0)
[[ -d mnt/sw/mf ]] || mount_sw=1
[[ -L mnt/proj/staff ]] || mount_proj=1
[[ -d mnt/crex/proj ]] || mount_crex=1
[[ -f mnt/home/$a/.bashrc ]] || mount_home=1
[[ -d mnt/usr/local/Modules/lmod ]] || mount_module=1

# get the uppmax password
if [[ $((mount_sw+mount_proj+mount_crex+mount_home+mount_module)) > 0 ]] ;
then
    
    # get the uppmax password
    echo "UPPMAX password:"
    read -s l
fi

# init structure
mkdir -p mnt/home/$a
mkdir -p mnt/proj
mkdir -p mnt/sw
mkdir -p mnt/crex
mkdir -p mnt/usr/local/Modules

# mount stuff if needed
[[ $mount_sw == 0 ]] || sshfs -o allow_other,password_stdin $a@rackham.uppmax.uu.se:/sw/ mnt/sw <<< $l
[[ $mount_proj == 0 ]] || sshfs -o allow_other,password_stdin $a@rackham.uppmax.uu.se:/proj/ mnt/proj <<< $l
[[ $mount_crex == 0 ]] || sshfs -o allow_other,password_stdin $a@rackham.uppmax.uu.se:/crex/ mnt/crex <<< $l
[[ $mount_home == 0 ]] || sshfs -o allow_other,password_stdin $a@rackham.uppmax.uu.se:/home/$a mnt/home/$a <<< $l
[[ $mount_module == 0 ]] || sshfs -o allow_other,password_stdin $a@rackham.uppmax.uu.se:/usr/local/Modules mnt/usr/local/Modules <<< $l

# no keep
unset l

# for the cow
read -r mount_sw mount_proj mount_crex mount_home mount_module <<< $(echo 0 0 0 0 0)
[[ -d mnt/sw/mf ]] || mount_sw=1
[[ -L mnt/proj/staff ]] || mount_proj=1
[[ -d mnt/crex/proj ]] || mount_crex=1
[[ -f mnt/home/$a/.bashrc ]] || mount_home=1
[[ -d mnt/usr/local/Modules/lmod ]] || mount_module=1

if [[ $((mount_sw+mount_proj+mount_crex+mount_home+mount_module)) == 0 ]] ;
then
    printf """ ____________________________________________
/                                            \ 
| Alrigt, sshfs mount points are up!         |
| To start the virtual UPPMAX node           |
|                                            |
| $ ./start_node.sh uppmax_in_a_can.sif      |
\____________________________________________/ 
        \  ^___^
         \ (ooo)\_______
           (___)\       )\/\ 
                ||----w |
                ||     ||
                
"""
fi
