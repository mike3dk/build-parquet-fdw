FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y \
build-essential \
htop \
wget \
lsb-release \
ca-certificates \
gnupg \
gnupg2 \
gnupg1 \
git

# install postgres 14
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
apt update -y && \
apt install -y postgresql-server-dev-14 libpq-dev 

# install libparquet-dev
RUN wget https://apache.jfrog.io/artifactory/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb
RUN apt install -y -V ./apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb && \
apt update -y && \
apt install -y -V libarrow-dev
RUN apt install -y -V libparquet-dev

# clone parquet_fdw and build
RUN git clone https://github.com/adjust/parquet_fdw && \
cd parquet_fdw && \
make install

# copy to output
RUN mkdir -p /output && \
cp /parquet_fdw/parquet_fdw.so /output/ && \
cp /parquet_fdw/parquet_fdw.control /output/ && \
cp /parquet_fdw/*.sql /output/
