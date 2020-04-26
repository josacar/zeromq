FROM crystallang/crystal:0.34.0-alpine

WORKDIR /app

# RUN apt-get -qq update && \
#   apt-get -qqy install libzmq3-dev

RUN apk add --no-cache libzmq czmq-dev

ADD shard.yml shard.lock  .

RUN shards install

ADD Makefile .
ADD src src

RUN make crystal

EXPOSE 6666

CMD bin/zeromq-server
