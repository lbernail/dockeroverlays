#!/usr/bin/env python

import consul
import json

c=consul.Consul(host="consul1",port=8500)

(idx,endpoints)=c.kv.get("docker/network/v1.0/endpoint/",recurse=True)
epdata=[ ep['Value'] for ep in endpoints if ep['Value'] is not None]

for data in epdata:
  print(json.dumps(json.loads(data.decode("utf-8")), indent=4, sort_keys=True))
