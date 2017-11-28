hubot-elastic
==

A Hubot script for interacting with an [elasticsearch](http://www.elasticsearch.org/x) cluster

Installation
---

In hubot project repo, run:

npm install hubot-elastic --save

Then add hubot-elastic to your external-scripts.json:

```
[
  "hubot-elastic"
]
```

You can query in Human Language on these API's.
Commands
---
* hubot: cluster health - Gets the cluster health for the given server or alias
* hubot: nodes - Gets the information from the cat nodes endpoint for the given server or alias
* hubot: indexes - Gets the information from the cat indexes endpoint for the given server or alias
* hubot: allocation - Gets the information from the cat allocation endpoint for the given server or alias
* hubot: cluster settings - Gets a list of all of the settings stored for the cluster
* hubot: disable allocation - disables shard allocation to allow nodes to be taken offline
* hubot: enable allocation - renables shard allocation
