#!/bin/bash
set -e

pushd /app/stable-diffusion-webui

# some optimizations
# export OMP_NUM_THREADS=6
# export MKL_NUM_THREADS=6

python3 launch.py --skip-torch-cuda-test --precision full --no-half --use-cpu all

popd