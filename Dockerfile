ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS builder

RUN apk add --no-cache gcc make bash musl-dev git \
	&& git clone --recurse-submodules https://github.com/jserv/MazuCC.git
WORKDIR /MazuCC
#--CPU=x86_64
RUN make -j$(nproc) \
	&& make check

ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS runtime

LABEL author="Bensuperpc <bensuperpc@gmail.com>"
LABEL mantainer="Bensuperpc <bensuperpc@gmail.com>"

ARG VERSION="1.0.0"
ENV VERSION=$VERSION

RUN apk add --no-cache musl-dev make

COPY --from=builder /MazuCC /usr/local

ENV PATH="/usr/local:${PATH}"

ENV CC=/usr/local/mzcc
WORKDIR /usr/src/myapp

CMD ["mzcc"]

LABEL org.label-schema.schema-version="1.0" \
	  org.label-schema.build-date=$BUILD_DATE \
	  org.label-schema.name="bensuperpc/docker-MazuCC" \
	  org.label-schema.description="build tinycc compiler" \
	  org.label-schema.version=$VERSION \
	  org.label-schema.vendor="Bensuperpc" \
	  org.label-schema.url="http://bensuperpc.com/" \
	  org.label-schema.vcs-url="https://github.com/Bensuperpc/docker-MazuCC" \
	  org.label-schema.vcs-ref=$VCS_REF \
	  org.label-schema.docker.cmd="docker build -t bensuperpc/mzcc -f Dockerfile ."