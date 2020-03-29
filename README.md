# apache24-php56-composer-yii1

Base image docker | debian:stretch-slim | apache24 | php7.2


# docker Build
```
docker build -t apache24-php56-composer-yii1:latest
```

# docker run

80 http, 443 https, 2323 ssh (etc/ssh/sshd_config)

```
docker run -dit \
    --name=basecontainer \
    -p 80:80 \
    -p 443:443 \
    -p 2323:2323 \
    -v /home/akbar/ahu-e-kerja/app/:/var/www/html \
apache24-php56-composer-yii1
```
