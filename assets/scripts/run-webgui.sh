#!/bin/bash
set -e

pushd /app/stable-diffusion-webui

# some optimizations
export OMP_NUM_THREADS=6
export MKL_NUM_THREADS=6

# override required for non-official supported AMD gpus
# HSA_OVERRIDE_GFX_VERSION=10.3.0 python3 launch.py --precision full --no-half --skip-torch-cuda-test
# python3 launch.py --precision full --no-half --skip-torch-cuda-test
python3 launch.py --skip-torch-cuda-test --precision full --no-half --use-cpu all

popd