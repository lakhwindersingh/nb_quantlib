FROM ubuntu:20.10 AS quantlib_stage

USER root
ENV DEBIAN_FRONTEND noninteractive
ARG TAG=latest
ARG PYTHON_VERSION=3.8
ARG QUANTLIB_VERSION=1.22

ENV QUANTLIB_VERSION="${QUANTLIB_VERSION}"
ENV PYTHON_VERSION="${PYTHON_VERSION}"
ENV BOOST=/usr/include/boost

ENV LC_NUMERIC=C
ENV LANG=en_US.UTF-8

RUN apt-get update
RUN apt-get -y install apt-utils git sudo wget curl software-properties-common build-essential gcc cmake protobuf-compiler
RUN apt-get -y install libboost-dev libboost-all-dev libboost-math-dev libboost-test-dev libboost-serialization-dev
RUN apt-get -y install python3-setuptools python3 python3-pip libpng-dev python-dev cython3
RUN apt-get -y upgrade

RUN apt-get -y install libarmadillo-dev binutils-dev

RUN wget https://github.com/lballabio/QuantLib/releases/download/QuantLib-v"${QUANTLIB_VERSION}"/QuantLib-"${QUANTLIB_VERSION}".tar.gz \
    && tar xfz QuantLib-"${QUANTLIB_VERSION}".tar.gz \
    && rm QuantLib-"${QUANTLIB_VERSION}".tar.gz \
    && cd QuantLib-"${QUANTLIB_VERSION}" \
    && ./configure --prefix=/usr --disable-static CXXFLAGS=-O3 \
    && make -j 10 && make check && sudo make install && ldconfig && sudo ldconfig\
    && cd .. && rm -rf QuantLib-"${QUANTLIB_VERSION}"
    
RUN wget https://github.com/lballabio/QuantLib-SWIG/releases/download/QuantLib-SWIG-v"${QUANTLIB_VERSION}"/QuantLib-SWIG-"${QUANTLIB_VERSION}".tar.gz \
    && tar xfz QuantLib-SWIG-"${QUANTLIB_VERSION}".tar.gz \
    && rm QuantLib-SWIG-"${QUANTLIB_VERSION}".tar.gz \
    && cd QuantLib-SWIG-"${QUANTLIB_VERSION}" \
    && ./configure PYTHON=/usr/bin/python"${PYTHON_VERSION}" --prefix=/usr --disable-static CXXFLAGS=-O3 \
    && make -j 10 && make check && sudo make -C Python install && ldconfig  && sudo ldconfig \
    && cd .. && rm -rf QuantLib-SWIG-"${QUANTLIB_VERSION}"

    

# Setup for Jupyter Notebook
RUN groupadd -g 1000 jupyter && \
    useradd -g jupyter -m -s /bin/bash jupyter && \
    mkdir -p /etc/sudoers.d /root/.jupyter  /home/jupyter/.jupyter /home/jupyter/notebook && \
    echo "jupyter:jupyter" | chpasswd && \
    echo "jupyter ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/jupyter && \
    chmod -R a+rwX  /etc/sudoers.d/jupyter /home/jupyter && \
    echo "/usr/lib" >  /etc/ld.so.conf.d/nbquant.conf && \
    echo "/usr/local/lib" >>  /etc/ld.so.conf.d/nbquant.conf && \
    #sudo mkdir /data && sudo chmod 777 /data && \
    ldconfig  && \
    echo "export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH" > /etc/profile.d/jupyter.sh && \
    echo "export PATH=/usr/local/bin:/usr/bin:/home/jupyter/.local/bin:$PATH" >> /etc/profile.d/jupyter.sh && \
    cp /etc/profile.d/jupyter.sh /root/.bashrc && \
    # Below file enable password access instead of token
    echo "c.NotebookApp.token = 'jupyter'" > /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.notebook_dir = '/home/jupyter/notebook/'" >> /root/.jupyter/jupyter_notebook_config.py && \
    cp /root/.jupyter/jupyter_notebook_config.py /home/jupyter/.jupyter

USER jupyter
RUN pip install --user jupyter jupyterlab 

USER root
# clean up
RUN apt-get -y remove libboost-dev libboost-all-dev libboost-math-dev libboost-test-dev libboost-serialization-dev && \
    # apt-get -y remove apt-utils  software-properties-common build-essential gcc git cmake protobuf-compiler && \
    apt-get -y autoremove && apt-get clean

COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh
EXPOSE 8282 
WORKDIR /home/jupyter/

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
