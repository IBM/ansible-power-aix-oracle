function show_usage_and_exit
{
  printf "\nUsage: $(basename $0) <final_size(MB)>"; exit -1;
}

[ $# -eq 0 ] && show_usage_and_exit

################################################################################
#                                                                              #
# Main                                                                         #
#                                                                              #
################################################################################

final_size=$1
if [ $final_size -eq 0 ]; then
  echo "Final size 0 MB requested, nothing to do."
  exit 0
fi

paging_space_size=`lsps -s | tail -1 | awk '{print $1}' | sed -e '/MB/s///'`

if (( $paging_space_size < $final_size )) ; then
  page_lv=`lsvg -l rootvg | fgrep paging | awk '{print $1}'`

  # Find the physical partition size for allocating paging space(MB's)
  ppsize=`/usr/sbin/lsvg rootvg |grep 'PP SIZE' |awk '{print $6}'`

  _num_pps=$(echo "($final_size - $paging_space_size) / $ppsize" | bc -l)
  asize=$(( `echo $_num_pps|cut -f1 -d"."` + 1 ))
  echo "Adding $asize segments to Paging"
  echo "/usr/sbin/chps -s $asize $page_lv"
  /usr/sbin/chps -s $asize $page_lv
  echo "Paging LV $page_lv changed."

  paging_space_size=`lsps -s | tail -1 | awk '{print $1}' | sed -e '/MB/s///'`

  if (( $paging_space_size < $final_size )) ; then
    error_if_non_zero 50 "Failure to increase paging size"
  else
    echo "Paging size is = ${paging_space_size} MB"
  fi

else
  echo "Current paging size $paging_space_size MB >= requested $final_size MB. No action taken."

fi

exit 0
