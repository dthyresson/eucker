# Description:
#   Eucker is ... just a bit outside
#
# Dependencies:
#   "espn": "0.0.4"
#
# Configuration:
#   ESPN_API_KEY from ESPN
#
# Commands:
#   hubot eucker feed now
#   hubot eucker feed now (boxing|college-football|golf|mens-college-basketball|mlb|mma|nascar|nba|nfl|nhl|olympics|racing|soccer|tennis|wnba|womens-college-basketball)
#   hubot eucker feed top
#   hubot eucker feed popular

espn = require('espn').setApiKey process.env.ESPN_API_KEY

module.exports = (robot) ->

  robot.respond /eucker feed now\s?(boxing|college-football|golf|mens-college-basketball|mlb|mma|nascar|nba|nfl|nhl|olympics|racing|soccer|tennis|wnba|womens-college-basketball)*$/i, (msg) ->

    options =
      leagues: msg.match[1]

    espn.now options, (err, json) ->
      msg.send headline msg.random json.feed

  robot.respond /eucker feed top$/i, (msg) ->
    options = []
    espn.nowTop options, (err, json) ->
      msg.send headline msg.random json.feed

  robot.respond /eucker feed popular$/i, (msg) ->
    options = []
    espn.nowPopular options, (err, json) ->
      msg.send headline msg.random json.feed

headline = (item) ->
  "#{item.headline}\n#{item.links.web.href}"
