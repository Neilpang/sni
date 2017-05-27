# sni
A sniproxy docker image


# 1. Start sniproxy as a daemon

```sh
docker run --rm  -itd  --name=sni  -p 80:80 -p 443:443  neilpang/sni
```

or:

```sh
docker run --rm  -itd  --name=sni  --net=host  neilpang/sni
```

or:

```sh
docker run --rm  -itd  --name=sni  \
  -p 80:80 \
  -p 443:443  \
  -v $(pwd)/sniconf:/sniproxy \
  neilpang/sni

```


# 2. Add sni proxy host

Add http proxy:

```sh
docker exec  sni  addhttp  example.com  172.17.0.2
```

or:

```sh
docker exec  sni  addhttp  example.com  172.17.0.2 8080
```

Add ssl proxy:

```sh
docker exec  sni  addssl  example.com  172.17.0.2
```

or:

```sh
docker exec  sni  addssl  example.com  172.17.0.2 8443
```







