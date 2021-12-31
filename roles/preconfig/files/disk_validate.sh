function show_usage_and_exit
{
  printf "\nUsage: $(basename $0) <hdisk#> <VGname>"; exit -1;
}

[ $# -eq 0 ] && show_usage_and_exit


# main code

disk=$1
vg=$2
disk_state=`lsdev|fgrep $disk| awk '{print $2}'`
if [[ "$disk_state" = "Available" ]] ; then
    disk_vg1=`lspv|fgrep $disk | awk '{print $2}'`
    disk_vg2=`lspv|fgrep $disk | awk '{print $3}'`
    if [[ "$disk_vg1" = "none" && "$disk_vg2" = "None"  ]] ; then
           echo "Disk $disk is clean"
           exit 0
    elif [[ "$disk_vg1" != "none" && "$disk_vg2" = $vg ]] ; then
           echo "VG already created"
           exit 0
    else
           echo "Disk $disk belong to another or old VG and not clean. If old one clear pvid from disk using 'chdev –l hdisk# -a pv=clear' and use 'dd if=/dev/zero of=/dev/hdiskX bs=1024k count=100
' to clear disk headers"
           exit 1
    fi
else
    echo "$disk is not Available state cmd: lsdev"
    exit 1
fi 
