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
#   hubot eucker now  - show espn now feed
#

espn = require 'espn'

espn.setApiKey process.env.ESPN_API_KEY

espn_now = (msg, err, json) ->
  espn.now(err, json)

espn_now_top = (msg, err, json) ->
  espn.nowTop(err, json)

espn_now_popular = (msg, err, json) ->
  espn.nowPopular(err, json)

module.exports = (robot) ->

  robot.respond /eucker headline/i, (msg) ->
    espn_now msg, (err, json) ->
      feed = json.feed
      item = msg.random feed
      image = msg.random item.images
      msg.send "#{image.url}"
      msg.send #{item.headline} - Read: #{item.links.web.href}"

  robot.respond /eucker top/i, (msg) ->
    espn_now_top msg, (err, json) ->
      feed = json.feed
      item = msg.random feed
      msg.send "#{image.url}"
      msg.send #{item.headline} - Read: #{item.links.web.href}"

  robot.respond /eucker popular/i, (msg) ->
    espn_now_popular msg, (err, json) ->
      feed = json.feed
      item = msg.random feed
      image = msg.random item.images
      msg.send "#{image.url}"
      msg.send #{item.headline} - Read: #{item.links.web.href}"
