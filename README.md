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

> Or use `curl http://localhost:8888` instead.

## TODO

- [ ] weighted round-robin
- [ ] IP hash
- [ ] consistency hash

## Copyright

Copyright &copy; 2020 [Triple-Z](https://github.com/Triple-Z)

This project is open sourced by [MIT License](./LICENSE.md).
