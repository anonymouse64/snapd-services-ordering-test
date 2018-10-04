#!/bin/bash -e

echo "this is the start of service3, sleeping"

sleep 5

echo "done sleeping, notifying"

systemd-notify --ready
