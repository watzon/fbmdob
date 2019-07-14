FROM crystallang/crystal:0.29.0

COPY . /fbmdob

RUN cd /fbmdob && \
    shards build

EXPOSE 6969

CMD ["/fbmdob/bin/fbmdob"]
