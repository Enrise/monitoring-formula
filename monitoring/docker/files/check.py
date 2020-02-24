#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import argparse
import json
import os
import re
import sys
import time

import docker

_STAT_RE = re.compile("(\w+)\s(\w+)")


# Get status of container
def status(args):
    try:
        container = client.inspect_container(args.container)
    except docker.errors.NotFound:
        return 0

    returncode = {
        'created': 1,
        'restarting': 2,
        'removing': 3,
        'paused': 4,
        'exited': 5,
        'dead': 6,
        'running': 10
    }
    return returncode.get(container['State']['Status'], 0)


# Get container uptime
def uptime(args):
    try:
        container = client.inspect_container(args.container)
    except docker.errors.NotFound:
        return 0

    if not container['State']['Running']:
        return 0

    uptime = container['State']['StartedAt']
    start = time.strptime(uptime[:19], "%Y-%m-%dT%H:%M:%S")
    return int(time.time() - time.mktime(start))


# Get container disk
def disk(args):
    with os.popen("docker inspect -s -f {{.SizeRootFs}} " + args.container + " 2>&1") as pipe:
        stat = pipe.read().strip()
    pipe.close()

    # test that the docker command succeeded and pipe contained data
    if 'stat' not in locals():
        stat = ""
    return int(stat.split()[0])


# Get healthcheck status
def healthcheck(arsg):
    try:
        container = client.inspect_container(args.container)
    except docker.errors.NotFound:
        return 0

    # If the container is not running, it is stopped
    if not container['State']['Running']:
        return 4

    # If there is no health key, it's unknown
    if 'Health' not in container['State']:
        return 0

    state = container['State']['Health']['Status']

    if state == "unhealthy":
        return 1
    elif state == "healthy":
        return 2
    elif state == "starting":
        return 3

    return 0


# Get container CPU usage
def cpu(args):
    container_dir = "/sys/fs/cgroup/cpuacct"

    # cpu usage in nanoseconds
    cpuacct_usage_last = single_stat_check(args, "cpuacct.usage")
    cpuacct_usage_new = single_stat_update(args, container_dir, "cpuacct.usage")
    last_change = update_stat_time(args, "cpuacct.usage.utime")

    # time used in division should be in nanoseconds scale, but take into account
    # also that we want percentage of cpu which is x 100, so only multiply by 10 million
    time_diff = (time.time() - float(last_change)) * 10000000

    cpu = (int(cpuacct_usage_new) - int(cpuacct_usage_last)) / time_diff
    return float("{:.2f}".format(cpu))


# Get container memory usage
def memory(args):
    container_dir = "/sys/fs/cgroup/memory"
    memory_usage_last = single_stat_update(args, container_dir, "memory.usage_in_bytes")
    return int(memory_usage_last.strip())


# Get container network usage (in)
def net_received(args):
    container_dir = "/sys/devices/virtual/net/eth0/statistics"
    eth_last = single_stat_check(args, "rx_bytes")
    eth_new = single_stat_update(args, container_dir, "rx_bytes")
    last_change = update_stat_time(args, "rx_bytes.utime")

    # we are dealing with seconds here, so no need to multiply
    time_diff = (time.time() - float(last_change))
    try:
        eth_bytes_per_second = (int(eth_new) - int(eth_last)) / time_diff
    except ValueError:
        eth_bytes_per_second = 0

    return int(eth_bytes_per_second)


# Get container network usage (out)
def net_sent(args):
    container_dir = "/sys/devices/virtual/net/eth0/statistics"
    eth_last = single_stat_check(args, "tx_bytes")
    eth_new = single_stat_update(args, container_dir, "tx_bytes")
    last_change = update_stat_time(args, "tx_bytes.utime")

    # we are dealing with seconds here, so no need to multiply
    time_diff = (time.time() - float(last_change))

    try:
        eth_bytes_per_second = (int(eth_new) - int(eth_last)) / time_diff
    except ValueError:
        eth_bytes_per_second = 0

    return int(eth_bytes_per_second)


# helper, fetch and update the time when stat has been updated
# used in cpu calculation
def update_stat_time(args, filename):
    try:
        with open("/tmp/" + args.container + "/" + filename, "r+") as f:
            stat_time = f.readline()
            f.seek(0)
            curtime = str(time.time())
            f.write(curtime)
            f.truncate()

    except Exception:
        if not os.path.isfile("/tmp/" + args.container + "/" + filename):
            # bootstrap with one second (epoch), which makes sure we don't divide
            # by zero and causes the stat calculation to start with close to zero value
            stat_time = 1
            f = open("/tmp/" + args.container + "/" + filename, "w")
            f.write(str(stat_time))
            f.close()
    return stat_time


# helper function to gather single stats
def single_stat_check(args, filename):
    try:
        with open("/tmp/" + args.container + "/" + filename, "r") as f:
            stat = f.read().strip()
    except Exception:
        if not os.path.isdir("/tmp/" + args.container):
            os.mkdir("/tmp/" + args.container)

        # first time running for this container, bootstrap with empty zero
        stat = "0"
        f = open("/tmp/" + args.container + "/" + filename, "w")
        f.write(str(stat) + '\n')
        f.close()

    if 'Error response from daemon' in stat:
        return 0

    return stat


# helper function to update single stats
def single_stat_update(args, container_dir, filename):
    pipe = os.popen("docker exec " + args.container + " cat " + container_dir + "/" + filename + " 2>&1")
    for line in pipe:
        stat = line
    pipe.close()

    # test that the docker command succeeded and pipe contained data
    if not 'stat' in locals():
        stat = ""
    try:
        f = open("/tmp/" + args.container + "/" + filename, "w")
        f.write(stat)
        f.close()
    except Exception:
        if not os.path.isdir("/tmp/" + args.container):
            os.mkdir("/tmp/" + args.container)
        with open("/tmp/" + args.container + "/" + filename, "w") as f:
            f.write(stat)

    if 'Error response from daemon' in stat:
        return 0

    return stat


# helper function to gather stat type data (multiple rows of key value pairs)
def multi_stat_check(args, filename):
    result = dict()
    try:
        with open("/tmp/" + args.container + "/" + filename, "r") as f:
            for line in f:
                m = _STAT_RE.match(line)
                if m:
                    result[m.group(1)] = m.group(2)
    except Exception:
        if not os.path.isdir("/tmp/" + args.container):
            os.mkdir("/tmp/" + args.container)

        # first time running for this container create empty file
        open("/tmp/" + args.container + "/" + filename, "w").close()
    return result


def multi_stat_update(args, container_dir, filename):
    result = dict()
    try:
        pipe = os.popen("docker exec " + args.container + " cat " + container_dir + "/" + filename + " 2>&1")
        for line in pipe:
            m = _STAT_RE.match(line)
            if m:
                result[m.group(1)] = m.group(2)
        pipe.close()
        f = open("/tmp/" + args.container + "/" + filename, "w")

        for key in result.keys():
            f.write(key + " " + result[key] + "\n")
        f.close()
    except Exception:
        return result
    return result


if __name__ == "__main__":
    global client
    client = docker.Client(base_url='unix://var/run/docker.sock')

    if len(sys.argv) > 2:
        parser = argparse.ArgumentParser(prog="docker_check.py",
                                         description="retrieve stats from Docker")
        parser.add_argument("container", help="container id")
        parser.add_argument("stat", help="container stat",
                            choices=["status", "uptime", "cpu", "mem", "disk", "netin", "netout", "health", "json"])
        args = parser.parse_args()

        # validate the parameter for container
        m = re.match("(^[a-zA-Z0-9-_]+$)", args.container)
        if not m:
            print("Invalid parameter for container id detected")
            sys.exit(2)

        # call the correct function to get the stats
        if args.stat == "status":
            print(status(args))
        elif args.stat == "uptime":
            print(uptime(args))
        elif args.stat == "disk":
            print(disk(args))
        elif args.stat == "cpu":
            print(cpu(args))
        elif args.stat == "mem":
            print(memory(args))
        elif args.stat == "netin":
            print(net_received(args))
        elif args.stat == "netout":
            print(net_sent(args))
        elif args.stat == "health":
            print(healthcheck(args))
        elif args.stat == "json":
            # v2 check
            container = dict()
            container['status'] = status(args)
            container['uptime'] = uptime(args)
            container['disk'] = disk(args)
            container['cpu'] = cpu(args)
            container['mem'] = memory(args)
            container['netin'] = net_received(args)
            container['netout'] = net_sent(args)
            container['health'] = healthcheck(args)
            print(json.dumps(container))
