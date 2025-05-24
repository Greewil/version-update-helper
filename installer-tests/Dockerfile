FROM ubuntu:latest

RUN set -xe \
    && apt-get update \
    && apt-get install -y git \
    && apt-get install -y curl unzip

COPY run_tests.sh ./

CMD ./run_tests.sh installation-test
