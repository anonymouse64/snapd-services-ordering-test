#!/bin/bash -e

echo "service1 started, sleeping"

sleep 5

echo "done sleeping, notifying"

systemd-notify --ready
