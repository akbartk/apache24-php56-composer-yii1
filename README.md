# apache24-php56-composer-yii1

Base image docker | debian:stretch-slim | apache24 | php7.2 or php5.6

```
debian:stretch-slim
PHP_V=5.6
```

# docker Build
```
docker build -t apache24-php56-composer-yii1:latest
```

# docker run

80 http, 443 https, 2323 ssh (etc/ssh/sshd_config)

```
docker run -it -d \
    --name=apache24-php56-composer-yii1 \
    -p 8350:80 \
    -p 2323:2323 \
    -v /some/www-html/:/var/www/html \
    -v /some/vhost:/var/www/vhost \
apache24-php56-composer-yii
```

# Swarm

```
docker service create \
    --name apache24-php56-composer-yii1 \
    --restart-condition on-failure \
    --mount type=bind,source=/some/www-html/,target=/var/www/html \
    --mount type=bind,source=/some/vhost,target=:/var/www/vhost \
    --network apps-web \
apache24-php56-composer-yii1
```
