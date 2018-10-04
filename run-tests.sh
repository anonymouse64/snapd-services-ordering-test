#!/bin/bash -e

# run ten times
for i in {1..10}; do 
    # clean up any previous snaps
    if [ -f snap/snapcraft.yaml ]; then
        snapcraft clean > /dev/null
        rm -rf snap/snapcraft.yaml 
    fi

    # always remove existing snaps
    rm -rf *.snap

    # generate a random name for the snap and build this snap
    NEW_SNAP_NAME=test-services-$RANDOM
    sed -e "s/SNAP-NAME/$NEW_SNAP_NAME/" snap/snapcraft.yaml.in > snap/snapcraft.yaml
    snapcraft > /dev/null

    # install the snap and then get the logs from the snap
    sudo snap install --devmode ${NEW_SNAP_NAME}*.snap > /dev/null
    sudo snap logs ${NEW_SNAP_NAME} > ${NEW_SNAP_NAME}.log

    # get the timestamps from when service1 and service3 are started
    SVC_1_TS=$(cat ${NEW_SNAP_NAME}.log | grep "service1 started, sleeping" | awk '{print $1}')
    SVC_3_TS=$(cat ${NEW_SNAP_NAME}.log | grep "service3 started, sleeping" | awk '{print $1}')

    # strip the seconds out from the time stamps from the log
    # also note since we're doing arithmetic we need to strip leading zeros i.e. "09" needs to be "9"
    # otherwise the arithmetic is done in a different base
    SVC_1_SECONDS=$(date --date="$SVC_1_TS" "+%s" | sed 's/^0*//')
    SVC_3_SECONDS=$(date --date="$SVC_3_TS" "+%s" | sed 's/^0*//')

    # also handle the case where the time stamp was "00", then we need to make it just "0"
    if [ -z "${SVC_1_SECONDS}" ]; then 
        SVC_1_SECONDS="0"
    fi

    if [ -z "${SVC_3_SECONDS}" ]; then 
        SVC_3_SECONDS="0"
    fi

    # compare the timestamps to see if service3 was started before service1 + 4 seconds
    # (the sleep is 5 seconds, so if the ordering was obeyed it will always be greater than 4)
    SVC_1_SECONDS_PLUS4=$(($SVC_1_SECONDS + 4))
    if [ "$SVC_3_SECONDS" -lt "$SVC_1_SECONDS_PLUS4" ]; then
        echo "invalid service ordering for test ${NEW_SNAP_NAME}"
        echo "See log output:"
        cat ${NEW_SNAP_NAME}.log
    fi

    # remove the snap
    sudo snap remove ${NEW_SNAP_NAME} > /dev/null
done
