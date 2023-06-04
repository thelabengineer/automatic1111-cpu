# syntax=docker/dockerfile-upstream:master-labs
FROM ubuntu:jammy

## ARGS

# SD
ARG SDVER=v1.3.1

# install packages
ARG PACKAGES="git libgl1-mesa-glx pciutils"

# miniconda
ARG CONDASETUP=Miniconda3-py310_23.3.1-0-Linux-x86_64.sh
ARG CONDAURL=https://repo.anaconda.com/miniconda/${CONDASETUP}
ARG CONDADIR="/miniconda"
ARG CONDAENV=sd
ARG CONDA_PREFIX=${CONDADIR}/envs/${CONDAENV}

# miniconda environment
ENV PATH=${CONDADIR}/bin:${PATH}
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CONDA_PREFIX}/lib/

# sd
ARG APPDIR=/app
ARG MODELDIR=/models
ARG SDDIR=${APPDIR}/stable-diffusion-webui
ARG SDMODELDIR=${SDDIR}/models/Stable-diffusion
ARG SDLORADIR=${SDDIR}/models/Lora
ARG SDEMBDSDIR=${SDDIR}/embeddings
ARG LYCORISDIR=${SDDIR}/models/LyCORIS
ARG OUTPUTSDIR=${SDDIR}/outputs

## install packages
RUN apt update && apt install -y ${PACKAGES}

## install miniconda
ADD --checksum=sha256:aef279d6baea7f67940f16aad17ebe5f6aac97487c7c03466ff01f4819e5a651 ${CONDAURL} /
RUN chmod a+x /${CONDASETUP}
RUN /bin/bash /${CONDASETUP} -b -p ${CONDADIR} # /bin/bash workaround for defect shellscript

## update conda if current version is not up-to-date
RUN conda update -n base -c defaults conda

## create directories

# app related
RUN mkdir -p -m 0775 ${APPDIR}

## copy files

# webgui run-script
COPY assets/scripts/run-webgui.sh ${APPDIR}/run-webgui.sh

# copy pickle scan script
COPY assets/scripts/pickle_scan.sh ${APPDIR}/pickle_scan.sh

# clone automatic1111
RUN git clone --depth 1 --branch ${SDVER} --recursive 'https://github.com/AUTOMATIC1111/stable-diffusion-webui.git' "/app/stable-diffusion-webui"

# copy conda dependency files for generation at build time (not at start-up time)
ADD --chown=1000:root assets/requirements.yaml ${SDDIR}

## setup conda environment
WORKDIR ${SDDIR}

# create conda env
RUN conda env create -f requirements.yaml

# init conda prompt
RUN conda init bash

# setup default conda environment in containers
RUN echo 'conda activate sd' >> ~/.bashrc

## let all RUN's after the following line run within the conda environment
SHELL [ "conda", "run", "-n", "sd", "/bin/bash", "--login", "-c" ]

## add default container user
RUN groupadd -g 1000 vscode
RUN useradd -rm -d /home/vscode -s /bin/bash -g root -G sudo -u 1000 vscode

## create vscode extension folders
RUN mkdir /home/vscode/.vscode-server
RUN mkdir /home/vscode/.vscode-server-insiders
RUN chown vscode:vscode /home/vscode/.vscode-server
RUN chown vscode:vscode /home/vscode/.vscode-server-insiders

# setup default conda environment for vscode user
USER vscode
RUN ${CONDADIR}/bin/conda init bash
# by default activate custom conda env
RUN echo "conda activate sd" >> /home/vscode/.bashrc

# switch back to root
USER root

# fix access rights for user
RUN chown --recursive vscode:vscode ${APPDIR}

## setup webgui components
ENV PYTHONUNBUFFERED=1
ENV GRADIO_SERVER_NAME=0.0.0.0
ENV GRADIO_SERVER_PORT=7860

## create volumes

# output files
RUN ln -s ${OUTPUTSDIR} /outputs
VOLUME [ "/outputs" ]

# models
RUN ln -s ${SDMODELDIR} /models
VOLUME [ "/models" ]

# lora
RUN ln -s ${SDLORADIR} /loras
VOLUME [ "/loras" ]

# textual inversions
RUN ln -s ${SDEMBDSDIR} /embeddings
VOLUME [ "/embeddings" ]

# LyCORIS
RUN ln -s ${LYCORISDIR} /lycoris
VOLUME [ "/lycoris" ]

# git cache volume (avoid pulling)
VOLUME [ "${SDDIR}/repositories" ]

# document web gui port
EXPOSE 7860/tcp