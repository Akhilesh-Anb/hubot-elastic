# Description:
#rking on the coffee script for changes in querying.
#   Get ElasticSearch Cluster Information
#
# Commands:
#  > *health*    - Gets the cluster health for the given server or alias
#  > *nodes, Memory Usage, CPU usage, Load, Master Node*                 - Gets the information from the cat nodes endpoint for the given server or alias
#  > *indexes *          - Gets the information from the cat indexes endpoint for the given server or alias
#  > *allocation *       - Gets the information from the cat allocation endpoint for the given server or alias
#  > *cluster settings *         - Gets a list of all of the settings stored for the cluster
#  > *index settings [index] *   - Gets a list of all of the settings stored for a particular index
#  > *disable allocation/routing *       - disables shard allocation to allow nodes to be taken offline
#  > *enable allocation/routing *        - renables shard allocation
#  > *problems in cluster*       - please note that this needs to include any port numbers as appropriate
#
# Notes:
#   The server must be a fqdn (with the port!) to get to the elasticsearch cluster
#
# Author:
# Akhilesh Appana

_esAliases = {}

QS = require 'querystring'

module.exports = (robot) ->

  robot.brain.on 'loaded', ->
    if robot.brain.data.elasticsearch_aliases?
      _esAliases = robot.brain.data.elasticsearch_aliases

  clusterHealth = (msg) ->
      msg.http("http://<IP>:9200/_cat/health?v")
        .get() (err, res, body) ->
          msg.send("/code ```#{body}```")

  spotLite = (msg, alias) ->
      msg.send("Getting the query details of index spot-lite")
      data = {"query":{"bool":{"must":[{"terms":{"Network.raw":["ABC"]}},{"term":{"Daypart.raw":"CABLE PRESS PRIME"}},{"range":{"Year":{"gte": "2008","lte": "2017"}}}]}},"aggs":{"group_by_Network":{"terms":{"field": "Network.raw","size":0},"aggs":{"group_by_Year":{"terms": { "field": "Year","size": 0},"aggs":{"SumOfDur":{"sum":{"field": "LSDur"}},"SumOfImpression":{"sum":{"script":"doc['LSDur'].value * doc['LSP18-49Imps'].value"}},"SumOfUE":{"sum":{ "script": "doc['LSDur'].value * doc['LSP18-49UE'].value"}}}}}}},"size": 0}

      json = JSON.stringify(data)
      msg.http("http://<IP>:9200/spot-lite/networkRatings/_search")
        .get(json) (err, res, body) ->
          json1 = JSON.stringify(JSON.parse(body),null,2);
          msg.send("/code ```#{json1}\n```")

  catNodes = (msg) ->
      msg.send("Getting the list of nodes for the cluster:")
      msg.http("http://<IP>:9200/_cat/nodes?v")
        .get() (err, res, body) ->
          lines = body.split("\n")
          header = lines.shift()
          list = [header].concat(lines.sort().reverse()).join("\n")
          msg.send("/code ```#{list} \n```")

  catShards = (msg) ->
      msg.send("Getting the list of shards for the cluster:")
      msg.http("http://<IP>:9200/_cat/shards?v")
        .get() (err, res, body) ->
          lines = body.split("\n")
          header = lines.shift()
          list = [header].concat(lines.sort().reverse()).join("\n")
          msg.send("/code ```#{list}```")

  catIndices = (msg) ->
      msg.send("Getting the list of indices for the cluster: ")
      msg.http("http://<IP>:9200/_cat/indices?v")
        .get() (err, res, body) ->
          lines = body.split("\n")
          header = lines.shift()
          list = [header].concat(lines.sort().reverse()).join("\n")
          msg.send("/code \n ```#{list} \n ```")

  showProblems = (msg) ->
      msg.send("Getting the problems of the cluster :")
      msg.http("http://<IP>:9200/_cluster/allocation/explain")
        .get() (err, res, body) ->
          json = JSON.stringify(JSON.parse(body),null,2);
          msg.send("/code ```#{json}```")


  catAllocation = (msg, alias) ->
      msg.send("Getting the allocation for the cluster: ")
      msg.http("http://<IP>:9200/_cat/allocation/?v=disk.percent,node,shards,disk.used,disk.avail")
        .get() (err, res, body) ->
          lines = body.split("\n")
          header = lines.shift()
          list = [header].concat(lines.sort().reverse()).join("\n")
          msg.send("/code ```#{list} \n ```")

  disableAllocation = (msg, alias) ->
      msg.send("Disabling Allocation for the cluster: ")

      data = {
        'persistent': {
          'cluster.routing.allocation.enable': 'none'
        }
      }

      json = JSON.stringify(data)
      msg.http("http://<IP>:9200/_cluster/settings")
        .put(json) (err, res, body) ->
          msg.send("/code ```#{body}```")

  enableAllocation = (msg, alias) ->
      msg.send("Enabling Allocation for the cluster ")

      data = {
        'persistent': {
          'cluster.routing.allocation.enable': 'all'
        }
      }

      json = JSON.stringify(data)
      msg.http("http://<IP>:9200/_cluster/settings")
        .put(json) (err, res, body) ->
          msg.send("/code ```#{body}```")

  showClusterSettings = (msg) ->
      msg.send("Getting the Cluster settings for ")
      msg.http("http://<IP>:9200/_cluster/settings?pretty=true")
        .get() (err, res, body) ->
          msg.send("/code ```#{body}```")

  showIndexSettings = (msg, index) ->
      msg.send("Getting the Index settings for #{index} ")
      msg.http("http://<IP>:9200/#{index}/_settings?pretty=true")
        .get() (err, res, body) ->
          msg.send("/code ```#{body}```")

  robot.hear /nodes|node|ip|ips|ip address|adresses|ip's|members|member|master|cpu|load|memory|ram|hosts|usage|usage report/i, (msg) ->
    if msg.message.user.id is robot.name
      return

    catNodes msg, msg.match[1], (text) ->
      msg.send text

  robot.hear /indexes|indices|index|replicas|documents/i, (msg) ->
    if msg.message.user.id is robot.name
      return

    catIndices msg, msg.match[1], (text) ->
      msg.send text

  robot.hear /disk|size|total|available|ip|ip's|ips|used|disk usage/i, (msg) ->
    if msg.message.user.id is robot.name
      return

    catAllocation msg, msg.match[1], (text) ->
      msg.send text

  robot.hear /cluster settings|cluster setting|settings of cluster|settings of my cluster/i, (msg) ->
    if msg.message.user.id is robot.name
      return

    showClusterSettings msg, msg.match[1], (text) ->
      msg.send(text)

  robot.hear /cluster health|health|status/i, (msg) ->
    if msg.message.user.id is robot.name
      return

    clusterHealth msg, msg.match[1], (text) ->
      msg.send text

  robot.hear /Get me the index settings of (.*)/i, (msg) ->
    if msg.message.user.id is robot.name
      return

    showIndexSettings msg, msg.match[1], msg.match[2], (text) ->
      msg.send text

  robot.hear /shards/i, (msg) ->
    if msg.message.user.id is robot.name
      return

    catShards msg, msg.match[1], (text) ->
      msg.send text


  robot.hear /issues|problems|problem|issue/i, (msg) ->
    if msg.message.user.id is robot.name
      return

    showProblems msg, msg.match[1], msg.match[2], (text) ->
      msg.send text

  robot.hear /disable allocation|disable|disable routing|disable the routing|disable the allocation/i, (msg) ->
    if msg.message.user.id is robot.name
      return

    disableAllocation msg, msg.match[1], (text) ->
      msg.send text

  robot.hear /enable allocation|enable the allocation|enable|enable the routing|enable routing/i, (msg) ->
    if msg.message.user.id is robot.name
      return

    enableAllocation msg, msg.match[1], (text) ->
      msg.send text

  robot.hear /spot-lite/i, (msg) ->
    if msg.message.user.id is robot.name
      return

    spotLite msg, msg.match[1], (text) ->
      msg.send(text)


