#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import json
import docker


# discover containers
def discover():
    d = dict()
    d["data"] = list()

    client = docker.Client(base_url='unix://var/run/docker.sock')
    containers = client.containers(all=True, trunc=True)
    for container in containers:
        ps = dict()
        ps["{#CONTAINERNAME}"] = container['Names'][0].replace('/', '', 2)
        ps["{#CONTAINERID}"] = container['Id']
        d["data"].append(ps)
    print(json.dumps(d))


if __name__ == "__main__":
    discover()
