# Copyright (C) 2016 PerfectlySoft Inc.
# Author: Shao Miller <swiftcode@synthetel.com>

FROM swift:latest as builder

# Install needed system libraries for perfect
RUN apt-get update \
    && apt-get install -y apt-utils libssl-dev libcurl4-openssl-dev libpq-dev uuid-dev --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

#COPY . .

RUN git clone https://github.com/luca69cr/WS_EchoTest_Server.git /root/mintycode

WORKDIR /root/mintycode
RUN swift build -c release

FROM swift:slim
WORKDIR /root
COPY --from=builder /root/mintycode .
EXPOSE 8181/tcp
ENTRYPOINT [".build/x86_64-unknown-linux/release/WS_EchoTest_Server"]
