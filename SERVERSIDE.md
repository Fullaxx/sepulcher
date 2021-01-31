# WebStore Services to support Sepulcher
[Webstore](https://github.com/Fullaxx/webstore) is the data-storage backend for Sepulcher.
The following describes how to run webstore in different ways. \
One webstore instance will be configured for key transfer and the other will support message distribution. \
The purpose of describing seperate 2 services is to demonstrate various configuration options. \
These can be combined into 1 service if you desire.

## Start KeyStore Instance (for Public Key Transfer)
For the KeyStore service, we run a generic webstore instance with 3 specific options: \
REQPERIOD=4 and REQCOUNT=1 limit connections from any IP address to 1 every 4 seconds. \
MAXPOSTSIZE=16384 limits any upload to 16384 bytes. This should be large enough for keys. \
```bash
KSIP="51.195.74.99"
RIP="172.17.0.1"
RPORT="6399"

docker run -d --rm --name keysredis \
-p ${RIP}:${RPORT}:6379 \
-v /srv/docker/keys/redis:/data \
redis

docker run -d --rm --name keyshttp \
-p ${KSIP}:80:8080 \
-e MAXPOSTSIZE=16384 \
-e REQPERIOD=4 -e REQCOUNT=1 \
-e REDISIP=${RIP} \
-e REDISPORT=${RPORT} \
-v /srv/docker/keys/httplog:/log \
fullaxx/webstore

docker run -d --rm --name keyshttps \
-p ${KSIP}:443:8080 \
-e MAXPOSTSIZE=16384 \
-e REQPERIOD=4 -e REQCOUNT=1 \
-e REDISIP=${RIP} \
-e REDISPORT=${RPORT} \
-e CERTFILE=config/live/keys.dspi.org/fullchain.pem \
-e KEYFILE=config/live/keys.dspi.org/privkey.pem \
-v /srv/docker/certbot:/cert \
-v /srv/docker/keys/httpslog:/log \
fullaxx/webstore
```

## Start MsgStore Instance (for Message Transfer)
For the MsgStore Instance, we run a generic webstore instance with 4 specific options: \
REQPERIOD=5 and REQCOUNT=2 limit connections from any IP address to 2 every 5 seconds. \
BAR=1 tells the server to DELETE any message that is successfully retrieved. \
MAXPOSTSIZE=1000000 limits any upload to 1000000 bytes. \
This options should be tailored for your specific needs.
```bash
MSIP="51.195.74.98"
RIP="172.17.0.1"
RPORT="6398"
docker pull redis
docker pull ubuntu:focal
docker pull fullaxx/webstore

docker run -d --rm --name msgsredis \
-p ${RIP}:${RPORT}:6379 \
-v /srv/docker/msgs/redis:/data \
redis

docker run -d --rm --name msgshttp \
-p ${MSIP}:80:8080 \
-e BAR=1 -e MAXPOSTSIZE=1000000 \
-e REQPERIOD=5 -e REQCOUNT=2 \
-e REDISIP=${RIP} \
-e REDISPORT=${RPORT} \
-v /srv/docker/msgs/httplog:/log \
fullaxx/webstore

docker run -d --rm --name msgshttps \
-p ${MSIP}:443:8080 \
-e BAR=1 -e MAXPOSTSIZE=1000000 \
-e REQPERIOD=5 -e REQCOUNT=2 \
-e REDISIP=${RIP} \
-e REDISPORT=${RPORT} \
-e CERTFILE=config/live/msgs.dspi.org/fullchain.pem \
-e KEYFILE=config/live/msgs.dspi.org/privkey.pem \
-v /srv/docker/certbot:/cert \
-v /srv/docker/msgs/httpslog:/log \
fullaxx/webstore
```
