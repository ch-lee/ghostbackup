#!/bin/bash

directory=/usr/local/chlee/backups
days=+30

find $directory -mtime $days -type f -delete
