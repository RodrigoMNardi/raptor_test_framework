#!/usr/bin/env bash

sudo apt-get install protobuf-c-compiler libprotobuf-c-dev -y
sudo apt-get install libzmq5 libzmq3-dev -y

echo "==== Cloning gRPC ===="
git clone -b $(curl -L https://grpc.io/release) https://github.com/grpc/grpc

cd grpc
git submodule update --init

echo "==== Make gRPC ===="
make

echo "==== Make install gRPC ===="
sudo make install

echo "==== Make install Protobuf ===="
cd third_party/protobuf
sudo make install
