#!/usr/bin/env bash

# Check the passed parameter
case "$1" in
    --sleep)
        # Loop through every active monitor and turn it off
        for out in $(wlr-randr | awk '/^[a-zA-Z0-9-]+/ {print $1}'); do
            wlr-randr --output "$out" --off
        done
        ;;
    --wake)
        # Loop through every active monitor and turn it on
        for out in $(wlr-randr | awk '/^[a-zA-Z0-9-]+/ {print $1}'); do
            wlr-randr --output "$out" --on
        done
        ;;
    *)
        echo "Usage: $0 {--sleep|--wake}"
        exit 1
        ;;
esac
