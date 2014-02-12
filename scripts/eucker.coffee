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
#   hubot sport me now  - show espn now feed
#

espn = require 'espn'

espn.setApiKey process.env.ESPN_API_KEY

espn_now = (msg, err, json) ->
  espn.now(err, json)

espn_now_top = (msg, err, json) ->
  espn.nowTop(err, json)

module.exports = (robot) ->

  robot.respond /sport me now/i, (msg) ->
    espn_now msg, (err, json) ->
      feed = json.feed
      item = msg.random feed
      msg.send item.headline

  robot.respond /sport me top/i, (msg) ->
    espn_now_top msg, (err, json) ->
      feed = json.feed
      item = msg.random feed
      msg.send item.headline

  robot.respond /sport me image/i, (msg) ->
    espn_now_top msg, (err, json) ->
      feed = json.feed
      item = msg.random feed
      image = msg.random item.images
      msg.send image.url
