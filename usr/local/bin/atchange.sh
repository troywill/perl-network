#!/bin/bash
echo -n ">>>>"
date
./perl-daemon &
ps aux | grep perl
