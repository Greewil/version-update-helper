FROM ubuntu:latest

RUN set -xe \
    && apt-get update \
    && apt-get install -y git \
    && apt-get install -y curl unzip

COPY run_tests.sh ./

ENV TESTS_COMMANDS='installation-test'

CMD ./run_tests.sh ${TESTS_COMMANDS}
