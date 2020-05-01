#!/bin/bash

# Stop at any error, show all commands
set -ex


if [ $PLATFORM == x86_64 ] || [ "$1" == "glibc_only" ]; then
    # Output something every 10 minutes or Travis kills the job
    while sleep 9m; do echo -n -e " \b"; done &
    docker build --rm -t centos-with-vsyscall32:latest --cache-from centos-with-vsyscall32:latest --target centos-with-vsyscall32 -f docker/glibc/Dockerfile docker/glibc/
    docker build --rm -t centos-with-vsyscall64:latest --cache-from centos-with-vsyscall32:latest --cache-from centos-with-vsyscall64:latest --target centos-with-vsyscall64 -f docker/glibc/Dockerfile docker/glibc/
    # Killing background sleep loop
    kill %1
    if [ "$1" == "glibc_only" ]; then
        exit 0
    fi
    docker build --rm -t mephi42/manylinux2010_centos-6-no-vsyscall --cache-from mephi42/manylinux2010_centos-6-no-vsyscall:latest --cache-from centos-with-vsyscall32:latest --cache-from centos-with-vsyscall64:latest -f docker/glibc/Dockerfile docker/glibc/
fi

docker build --rm -t mephi42/manylinux2010_$PLATFORM:$TRAVIS_COMMIT -f docker/Dockerfile-$PLATFORM docker/
