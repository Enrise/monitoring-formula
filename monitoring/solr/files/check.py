#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import urllib
import json
import sys

instance = sys.argv[1]
key = sys.argv[2]

if not instance or not key:
    print("Missing instance or key")
    sys.exit(1)

fqdn = 'http://localhost:8080'
uri = '/solr/{0}/admin/system?wt=json'.format(instance)


def _getData(key):
    resp = urllib.urlopen(fqdn + uri).read()
    data = json.loads(resp)

    switcher = {
        "schema": data['core']['schema'],
        "start": data['core']['start'],

        # Memory
        "memory_free": data['jvm']['memory']['raw']['free'],
        "memory_max": data['jvm']['memory']['raw']['max'],
        "memory_total": data['jvm']['memory']['raw']['total'],
        "memory_used": data['jvm']['memory']['raw']['used'],

        "version": data['lucene']['solr-spec-version'],
        "mode": data['mode'],

        "uptime": data['jvm']['jmx']['upTimeMS'],
    }
    return switcher.get(key)


def main():
    print(_getData(key))


if __name__ == "__main__":
    main()
