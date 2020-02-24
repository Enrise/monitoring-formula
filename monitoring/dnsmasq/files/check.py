#!/usr/bin/env python3
import json
import os
import re
import signal
import time

import psutil
import systemd.journal


def findProcessIdByName(processName):
    for proc in psutil.process_iter():
        try:
            pinfo = proc.as_dict(attrs=['pid', 'name'])
            # Check if process name contains the given name string.
            if processName.lower() in pinfo['name'].lower():
                return pinfo['pid']
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    return False


def getMetrics():
    # Get the process ID for dnsmasq
    dnsmasq_pid = findProcessIdByName('dnsmasq')

    # Send a SIGUSR1 to dump the stats
    os.kill(dnsmasq_pid, signal.SIGUSR1)

    # Grab a timestamp 1 second ago to get the right metrics
    timestamp = time.time() - 3

    output = []

    # Grab the values from syslog
    j = systemd.journal.Reader()
    j.seek_tail()
    j.seek_realtime(timestamp)
    j.add_match(_SYSTEMD_UNIT="dnsmasq.service")
    for entry in j:
        output.append(entry['MESSAGE'])
    return output


def main():
    metrics = getMetrics()
    # Example output:
    # time 1580813932
    # cache size 10000, 0/0 cache insertions re-used unexpired cache entries.
    # queries forwarded 0, queries answered locally 0
    # queries for authoritative zones 0
    # server 8.8.8.8#53: queries sent 0, retried or failed 0
    # server 1.0.0.1#53: queries sent 0, retried or failed 0
    # server 1.1.1.1#53: queries sent 0, retried or failed 0

    output = {}
    local_metrics = {}
    server_metrics = {}
    # Filter the output
    for line in metrics:
        if line.startswith('cache size'):
            # Cache size line
            result = re.match("cache size ([0-9]+), ([0-9]+)/([0-9]+) cache insertions re-used unexpired cache entries",
                              line)
            local_metrics['cache'] = {'size': int(result[1]), 'insertions': int(result[2]), 'expired': int(result[3])}
        elif line.startswith('queries forwarded'):
            # Queries forwarded metrics
            result = re.match("queries forwarded ([0-9]+), queries answered locally ([0-9]+)",
                              line)
            local_metrics['queries'] = {'forwarded': int(result[1]), 'answered': int(result[2])}
        elif line.startswith('queries authoritative zones'):
            # Queries auth zone
            result = re.match("queries for authoritative zones ([0-9]+)", line)
            local_metrics['authorative'] = {'queries': int(result[1])}
        elif line.startswith('server'):
            # Specific upstream server metrics
            result = re.match("server (.*)#([0-9]+): queries sent ([0-9]+), retried or failed ([0-9]+)",
                              line)

            server_metrics[result[1]] = {'queries': int(result[3]), 'retried': int(result[4])}

    output['local'] = local_metrics
    output['server'] = server_metrics

    print(json.dumps(output))


if __name__ == '__main__':
    main()
