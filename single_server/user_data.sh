#!/usr/bin/env bash
# user_data.sh - Bootstrap script for ec2 instances.

# Author: Ruben Ricaurte <ricaurtef@gmail.com>

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace


# Global definitions.
readonly index_file='index.html'


make_index() {
    if echo 'Hello, world!' > "$index_file"; then
        echo "'$index_file' was created successfully."
    else
        echo "Error: '$index_file' cannot be created." >&2
        exit 1
    fi
}


start_webserver() {
    if ! command -v busybox &> /dev/null; then
        echo "Error: busybox not found." >&2
        exit 1
    fi

    if [[ -f "$index_file" ]]; then
        nohup busybox httpd -f -p ${server_port} &
    else
        echo "Error: '$index_file' not found, cannot start the webserver." >&2
        exit 1
    fi
}


main() {
    make_index
    start_webserver
}


main "$@"
