#!/bin/bash
#
#  This tool is used for auto sync file from local to remote server
#
local_dir=$1
remote_dest=$2

setup_sync_deamon_darwin()
{
    fswatch ${local_dir}  | while read file
    do
        rsync -rltzuq --delete --exclude='.*' ${local_dir}/ ${remote_dest}
        echo "${file} was rsynced"
    done
}

setup_sync_deamon_linux()
{
    while true
    do
        inotifywait -r -e modify,attrib,close_write,move,create,delete ${local_dir}/
        rsync -avz ${local_dir} ${remote_dest}
    done
}

install_pkg_darwin()
{
    fswatch_file=$(which fswatch)
    if [ "${fswatch_file}" == "" ]
    then
        echo "install fswatch"
        brew install fswatch
    fi
}

install_pkg_linux()
{
    sudo apt-get install -y inotify-tools
}


os_type=$(uname -s)

if [ "${os_type}" == "Darwin" ]
then
    install_pkg_darwin
    setup_sync_deamon_darwin
elif [ "${os_type}" == "Linux" ]
then
    install_pkg_linux
    setup_sync_deamon_linux
fi
