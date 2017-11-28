hubot-elastic
==

A Hubot script for interacting with an [elasticsearch](http://www.elasticsearch.org/x) cluster

Installation
---

In hubot project repo, run:

npm install hubot-elastic --save

Then add hubot-etcd to your external-scripts.json:

```
[
  "hubot-elastic"
]
```

Commands
---

* hubot: cluster health [cluster] - Gets the cluster health for the given server or alias
* hubot: cat nodes [cluster] - Gets the information from the cat nodes endpoint for the given server or alias
* hubot: cat indexes [cluster] - Gets the information from the cat indexes endpoint for the given server or alias
* hubot: cat allocation [cluster]  - Gets the information from the cat allocation endpoint for the given server or alias
* hubot: cluster settings [cluster] - Gets a list of all of the settings stored for the cluster
* hubot: index settings [cluster] [index] - Gets a list of all of the settings stored for a particular index
* hubot: disable allocation [cluster] - disables shard allocation to allow nodes to be taken offline
* hubot: enable allocation [cluster] - renables shard allocation