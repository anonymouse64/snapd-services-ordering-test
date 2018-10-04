#!/bin/bash -e

echo "service3 started, sleeping"

sleep 5

echo "done sleeping, notifying"

systemd-notify --ready
