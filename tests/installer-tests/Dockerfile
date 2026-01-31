FROM ubuntu:latest

RUN set -xe \
    && apt-get update \
    && apt-get install -y git expect curl unzip

COPY run_tests.sh autoupdate.exp ./

ENV TESTS_COMMANDS='installation-test'

CMD ./run_tests.sh ${TESTS_COMMANDS}
