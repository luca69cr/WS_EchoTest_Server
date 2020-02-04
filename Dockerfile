# Copyright (C) 2016 PerfectlySoft Inc.
# Author: Shao Miller <swiftcode@synthetel.com>

FROM perfectlysoft/ubuntu1510
RUN /usr/src/Perfect-Ubuntu/install_swift.sh --sure
RUN git clone https://github.com/luca69cr/WS_EchoTest_Server /usr/src/MintyCode
WORKDIR /usr/src/MintyCode
RUN swift build
CMD .build/debug/PerfectTemplate --port 8181:8181
