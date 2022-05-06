# =====================================================
# build prisma engine
FROM rust:1.58.1-alpine3.14
ENV RUSTFLAGS="-C target-feature=-crt-static"
RUN apk --no-cache add openssl direnv git musl-dev openssl-dev build-base perl protoc
RUN git clone --depth=1 --branch=3.13.0 https://github.com/prisma/prisma-engines.git /prisma
WORKDIR /prisma
RUN cargo build --release