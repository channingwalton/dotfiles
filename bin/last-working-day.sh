#!/bin/bash

FORMAT='%Y-%m-%d'

if [ $(date +%w) == 0 ] ; then
    date -v-2d +"${FORMAT}"
elif [ $(date +%w) == 1 ] ; then
    date -v-3d +"${FORMAT}"
else
    date -v-1d +"${FORMAT}"
fi

