#!/bin/bash -e

echo "this is the start of service2"

systemd-notify --ready

