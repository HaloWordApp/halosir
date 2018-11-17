FROM buildpack-deps:bionic

WORKDIR /builder
COPY docker/builder/builder_setup.sh ./
COPY .tool-versions ./

RUN ["/bin/bash", "builder_setup.sh"]

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
