FROM buildpack-deps:bionic

WORKDIR /builder
COPY docker/builder/builder_setup.sh ./
COPY .tool-versions ./

RUN ["/bin/bash", "builder_setup.sh"]
