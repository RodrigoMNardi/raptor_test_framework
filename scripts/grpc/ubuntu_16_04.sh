#!/usr/bin/env bash
git clone -b $(curl -L https://grpc.io/release) https://github.com/grpc/grpc &&
cd grpc &&
git submodule update --init &&
echo "--- installing grpc ---" &&
ex -s -c '356i|CPPFLAGS += -Wno-unused-variable' -c x Makefile &&
make -j$(nproc) && make install && ldconfig &&
echo "--- installing protobuf ---" &&
cd third_party/protobuf &&
make install && make clean && ldconfig &&
cd ../.. && make clean && rm -rf /var/local/git/grpc
