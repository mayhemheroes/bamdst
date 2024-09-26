FROM fuzzers/afl:2.52 as builder

RUN apt-get update
RUN apt install -y make automake autotools-dev zlib1g-dev
ADD . /bamdst
WORKDIR /bamdst
RUN make CC=afl-clang CXX=afl-clang++
RUN mkdir /bamdstCorpus
RUN mkdir /staticbam
RUN cp ./example/*.bed /bamdstCorpus/
RUN cp ./example/*.bam /staticbam/

FROM fuzzers/afl:2.52
COPY --from=builder /bamdstCorpus /testsuite/
COPY --from=builder /bamdst/bamdst /
COPY --from=builder /staticbam /staticbam/

ENTRYPOINT ["afl-fuzz", "-i", "/testsuite", "-o", "/bamdstOut"]
CMD ["/bamdst", "-p", "@@", "-o", ".", "/staticbam/test.bam"]
