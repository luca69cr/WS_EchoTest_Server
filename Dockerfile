# Copyright (C) 2016 PerfectlySoft Inc.
# Author: Shao Miller <swiftcode@synthetel.com>

FROM swift:latest as builder

#COPY . .
RUN apt-get -y update && apt-get install -y --no-install-recommends apt-utils libssl-dev
RUN apt-get -y update && apt-get install -y --no-install-recommends apt-utils libcurl4-openssl-dev
RUN apt-get -y update && apt-get install -y --no-install-recommends apt-utils libpq-dev
RUN apt-get -y update && apt-get install -y --no-install-recommends apt-utils uuid-dev
RUN git clone https://github.com/luca69cr/WS_EchoTest_Server.git /root/mintycode

WORKDIR /root/mintycode/WS_EchoTest_Server
RUN swift build -c release

FROM swift:slim
WORKDIR /root
COPY --from=builder /root/mintycode/WS_EchoTest_Server .
CMD [".build/x86_64-unknown-linux/release/WS_EchoTest_Server"] --port 8181:8181
