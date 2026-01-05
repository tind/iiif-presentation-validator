#!/bin/bash

docker build -t validator . && docker run -it --rm -p 8000:8000 --name validator validator:latest
