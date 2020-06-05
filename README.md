# DLB Demo

Dynamic Load Balancing demo for introducing OpenResty.

First used in [#18 A2OS Weekly](https://github.com/NUAA-Open-Source/weekly/issues/7).

## Quickstart

```bash
$ git clone https://github.com/Triple-Z/dlb-demo
$ cd dlb-demo/
$ docker-compose up
```

Then visit the http://localhost:8888 continuously, you will find out the response content number is changing all the time :P

> Or use `for i in {1..10} ; do curl http://localhost:8888 ; done` instead.

## Example Results

Backend server configs:

```lua
servers = {
    {
        host = "172.28.0.101",
        port = 80,
        weight = 5, -- backend 1
    },
    {
        host = "172.28.0.102",
        port = 80,
        weight = 2, -- backend 2
    },
    {
        host = "172.28.0.103",
        port = 80,
        weight = 2, -- backend 3
    },
}
```

Results:

```bash
# Round-robin (rr)
$ for i in {1..10} ; do curl http://localhost:8888 ; done
response from backend 1
response from backend 2
response from backend 3
response from backend 1
response from backend 2
response from backend 3
response from backend 1
response from backend 2
response from backend 3
response from backend 1

# Weighted round-robin (wrr)
$ for i in {1..10} ; do curl http://localhost:8888 ; done
response from backend 1
response from backend 1
response from backend 1
response from backend 1
response from backend 1
response from backend 2
response from backend 2
response from backend 3
response from backend 3
response from backend 1

# Smooth weighted round-robin (swrr)
$ for i in {1..10} ; do curl http://localhost:8888 ; done
response from backend 1
response from backend 2
response from backend 1
response from backend 3
response from backend 1
response from backend 1
response from backend 2
response from backend 3
response from backend 1
response from backend 1
```

## TODO

- [x] Round-robin
- [x] weighted round-robin
- [x] smooth weighted round-robin
- [ ] Health check
- [ ] IP hash
- [ ] consistency hash

## Copyright

Copyright &copy; 2020 [Triple-Z](https://github.com/Triple-Z)

This project is open sourced by [MIT License](./LICENSE.md).
