# docker-intellij

[![Build Status](https://travis-ci.org/madduci/docker-intellij.svg?branch=master)](https://travis-ci.org/madduci/docker-intellij)

A dockerized version of IntelliJ Community Edition as throw-away development environment.

It uses the default OpenJDK and Maven shipped within the IDE. If you need different versions, you can extend the base Dockerfile by adding your desired ones.

## How to run it

It goes as simple as:

`docker-compose up -d`

## Limitations

It doesn't work on Docker for Windows and it has to be tested on Docker for Mac