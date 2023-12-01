#!/usr/bin/env bash

for file in $(ls -1A src/); do
    original_location=$(realpath src/${file})
    target_location=~/${file}
    if [ -a ${target_location} ]; then
        if [[ -L "${target_location}" ]]; then
            if [ "$(readlink -f ${target_location})" = "${original_location}" ]; then
                echo Nothing to do for ${original_location}
                continue
            fi
        fi
        mkdir -p backup
        backup_location="backup/${file}"
        echo Moving ${target_location} to ${backup_location}
        if [ -a "${backup_location}" ]; then
            echo "File ${backup_location} already exists, skipping!"
            continue
        fi
        mv "${target_location}" "${backup_location}"
    fi
    echo Creating link for ${original_location} at ${target_location}
    ln -s "${original_location}" "${target_location}"
done
