# =====================================================
# build prisma engine
FROM rust:1.58.1-slim as builder
ENV RUSTFLAGS="-C target-feature=-crt-static"

RUN apt-get update
RUN apt-get install -y openssl libssl-dev direnv git musl-dev build-essential perl protobuf-compiler pkg-config
RUN git clone --depth=1 --branch=3.13.0 https://github.com/prisma/prisma-engines.git /prisma
WORKDIR /prisma
RUN cargo build --release

# ====================================================
FROM ubuntu:20.04

COPY --from=builder /prisma/target/release/query-engine /prisma-engines/query-engine
COPY --from=builder /prisma/target/release/migration-engine /prisma-engines/migration-engine
COPY --from=builder /prisma/target/release/introspection-engine /prisma-engines/introspection-engine
COPY --from=builder /prisma/target/release/prisma-fmt /prisma-engines/prisma-fmt
