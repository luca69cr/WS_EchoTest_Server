#****************************************************************************************************************
# Copyright (C) 2020 MintyCode.
# Author: Luca MURATORE <luca.muratore@me.com>
# project: WS_EchoTest_Server
# version: 1.0.0
#****************************************************************************************************************

#************************************
# Create swift with complier
#************************************
FROM swift:latest as builder

#************************************
# Install needed system libraries for perfect
#************************************
RUN apt-get update \
    && apt-get install -y apt-utils libssl-dev libcurl4-openssl-dev libpq-dev uuid-dev --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

#COPY . .
#************************************
# Clone git repository file to build project
#************************************
RUN git clone https://github.com/luca69cr/WS_EchoTest_Server.git /root/mintycode

#************************************
# Build Project
#************************************
WORKDIR /root/mintycode
RUN swift build -c release

#************************************
# Create swift without complier
#************************************
FROM swift:slim
WORKDIR /root
#COPY --from=builder /root/mintycode .

#************************************
# Copy the executable file into root
#************************************
COPY  --from=builder /root/mintycode/.build/x86_64-unknown-linux/release/WS_EchoTest_Server .

#************************************
# Copy the html prj added folder into root
#************************************
RUN mkdir ./webroot
COPY --from=builder /root/mintycode/webroot/index.html ./webroot


#************************************
# remove unused mintycode folder
#************************************
RUN rm -rf ./mintycode

#************************************
# Create project run
#************************************
EXPOSE 8181/tcp
#ENTRYPOINT [".build/x86_64-unknown-linux/release/WS_EchoTest_Server"]
ENTRYPOINT ["./WS_EchoTest_Server"]
