FROM      ubuntu:16.04
MAINTAINER Albert Vilella "avilella@gmail.com"

# RUN useradd -m user
# USER user
# RUN echo $HOME

RUN apt-get update
RUN apt-get -y install build-essential git zlib1g-dev libncurses5-dev libjson-perl

RUN cd $HOME && git clone http://github.com/avilella/ancestry
RUN cd $HOME/ancestry && make all

RUN apt-get -y install python
RUN python $HOME/ancestry/runancestry.py



