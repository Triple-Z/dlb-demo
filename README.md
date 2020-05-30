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

> Or use `for i in {1..10}; do curl http://localhost:8888; done` instead.

## TODO

- [x] Round-robin
- [x] weighted round-robin
- [ ] smooth weighted round-robin
- [ ] Health check
- [ ] IP hash
- [ ] consistency hash

## Copyright

Copyright &copy; 2020 [Triple-Z](https://github.com/Triple-Z)

This project is open sourced by [MIT License](./LICENSE.md).
