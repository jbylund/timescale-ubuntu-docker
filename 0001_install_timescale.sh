#!/bin/bash
set -eux
cd /tmp
curl --location https://github.com/timescale/timescaledb/archive/2.1.0.tar.gz > timescale.tar.gz
tar -xf timescale.tar.gz
/bin/rm -vf timescale.tar.gz
cd timescaledb-2.1.0
./bootstrap -DREGRESS_CHECKS=OFF
cd build && make -j $(nproc) && make install

echo "shared_preload_libraries = 'timescaledb'" | tee --append $( find / -name "postgresql.conf" ) /usr/share/postgresql/13/postgresql.conf.sample

axel --quiet https://golang.org/dl/go1.16.linux-amd64.tar.gz
tar -C /usr/local -xf go1.16.linux-amd64.tar.gz

export GOPATH=$(go env GOPATH)
go get github.com/timescale/timescaledb-tune/cmd/timescaledb-tune
cp /root/go/bin/timescaledb-tune /usr/local/bin/timescaledb-tune
chmod a+x /usr/local/bin/timescaledb-tune
timescaledb-tune -h 2>/dev/null
