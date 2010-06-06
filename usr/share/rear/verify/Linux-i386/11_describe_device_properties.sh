#
# describe the device sizes of the physical devices.
#
while read device junk ; do
	# device is something like /dev/sda or /dev/cciss/c0d0
	mkdir -p $TMP_DIR$device || Error "Could not mkdir '$TMP_DIR$device'"
	sfdisk -d $device | grep -E "(unit:|${device}.*:)" >$TMP_DIR$device/sfdisk.partitions
	test $PIPESTATUS -eq 0 || Error "Could not store the partition table for '$device'"

	sfdisk -g $device > $TMP_DIR$device/sfdisk.geometry || Error \
		"Could not store geometry for '$device'"
	sfdisk -s $device > $TMP_DIR$device/size || Error \
		"Could not store size for '$device'"

        FindDrivers $device >$TMP_DIR/$device/drivers || Error "Could not determine the required drivers for '$device'" 
        # NOTE: The result can be empty if we simply don't know! 
         
done <$TMP_DIR/physical_devices
