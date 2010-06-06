# describe all filesystems, including the extended attributes like max mount count,
# check interval, etc.

while read mountpoint device mountby filesystem junk ; do
	mkdir -p $VAR_DIR/recovery$device
	vol_id $device >$VAR_DIR/recovery$device/fs_vol_id || \
		Error "Cannot determine filesystem info on '$device'
Your udev implementation (vol_id or udev_volume_id) does not recognize it."
	echo "$device" >$VAR_DIR/recovery$device/depends
	case $filesystem in
		ext*)
			tmp_fs_parameters=$(mktemp $TMP_DIR/fs_parameters.XXXXXX) || \
				Error "Failed creating a temporary file in $TMP_DIR."
			tune2fs -l $device > $tmp_fs_parameters || \
				Error "Could not run tune2fs or failed to write to $tmp_fs_parameters."
			FS_RESERVED_BLOCKS=$(grep "Reserved block count" $tmp_fs_parameters | sed -e 's/^.*: \+\([0123456789]\+\).*$/\1/g')
			FS_MAX_MOUNTS=$(grep "Maximum mount count" $tmp_fs_parameters | sed -e 's/^.*: \+\([-0123456789]\+\).*$/\1/g')
			FS_CHECK_INTERVAL=$(grep "Check interval" $tmp_fs_parameters | sed -e 's/^.*: \+\([0123456789]\+\).*$/\1/g')

			# The check interval is displayed in seconds, but tune2fs only allows us to set
			# the interval in days, weeks or month. So we have to convert the seconds to days
			(( FS_CHECK_INTERVAL = FS_CHECK_INTERVAL / 86400 ))
			rm  $tmp_fs_parameters
			fs_parameters=$VAR_DIR/recovery$device/fs_parameters
			> $fs_parameters || Error "Could not write to $fs_parameters"
			echo "FS_RESERVED_BLOCKS=$FS_RESERVED_BLOCKS" > $fs_parameters
			echo "FS_MAX_MOUNTS=$FS_MAX_MOUNTS" >> $fs_parameters
			echo "FS_CHECK_INTERVAL=$FS_CHECK_INTERVAL" >> $fs_parameters
			;;
		*)
			Log "The filesystem $filesystem on $device does not support extended filesystem"
			Log "parameters like max mount count, check imterval etc. or it"
			Log "is not implemented in ReaR yet" 
			Log "Please file a bug if you think this is an error"
			;;
	esac	
done <$VAR_DIR/recovery/mountpoint_device
