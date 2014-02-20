# Description:
#   Eucker is ... just a bit outside
#
# Dependencies:
#
# Configuration:
#
# Commands:

_ = require 'lodash'

mustache = require 'mustache'

xml2js = require 'xml2js'

parser = new xml2js.Parser()

moment = require('moment')
chrono = require('chrono-node')

mlb_teams = ///
(
Dodgers|                    # nicknames
Angels|
Rangers|
Giants|
Royals|
Brewers|
Cardinals|
Rockies|
Blue\x20Jays|
Astros|
Mets|
White\x20Sox|
Padres|
Tigers|
Twins|
Reds|
Pirates|
Cubs|
Mariners|
Braves|
Diamondbacks|
Orioles|
Indians|
Marlins|
Athletics|
Phillies|
Nationals|
Rays|
Yankees|
Red\x20Sox|
Losx20Angelesx20Dodgers|    #full team names
Losx20Angelesx20Angels|
Texasx20Rangers|
Sanx20Franciscox20Giants|
Kansasx20Cityx20Royals|
Milwaukeex20Brewers|
St.x20Louisx20Cardinals|
Stx20Louisx20Cardinals|
Saintx20Louisx20Cardinals|
Coloradox20Rockies|
Torontox20Bluex20Jays|
Houstonx20Astros|
Newx20Yorkx20Mets|
Chicagox20Whitex20Sox|
Sanx20Diegox20Padres|
Detroitx20Tigers|
Minnesotax20Twins|
Cincinnatix20Reds|
Pittsburghx20Pirates|
Chicagox20Cubs|
Seattlex20Mariners|
Atlantax20Braves|
Arizonax20Diamondbacks|
Baltimorex20Orioles|
Clevelandx20Indians|
Miamix20Marlins|
Oaklandx20Athletics|
Philadelphiax20Phillies|
Washingtonx20Nationals|
Tampax20Bayx20Rays|
Newx20Yorkx20Yankees|
Bostonx20Redx20Sox|
Losx20Angeles|            # locations/cities
Texas|
Sanx20Francisco|
Kansasx20City|
Milwaukee|
Stx20Louis|
St.x20Louis|
Saintx20Louis|
Colorado|
Toronto|
Houston|
Newx20York|
Chicago|
Sanx20Diego|
Detroit|
Minnesota|
Cincinnati|
Pittsburgh|
Seattle|
Atlanta|
Arizona|
Baltimore|
Cleveland|
Miami|
Oakland|
Philadelphia|
Washington|
Tampax20Bay|
Boston|
LOS|                        # abbreviations
ANA|
TEX|
SFG|
KAN|
MIL|
STL|
COL|
TOR|
HOU|
NYM|
CWS|
SDP|
DET|
MIN|
CIN|
PIT|
CHC|
SEA|
ATL|
ARI|
BAL|
CLE|
MIA|
OAK|
PHI|
WAS|
TAM|
NYY|
BOS
)
///i


team_hash = [
              {code: 'mia', nickname: 'marlins', name: "miami marlins", location: 'miami', abbreviation: 'mia'},
              {code: 'myn', nickname: 'mets', name: "new york mets", location: 'new york', abbreviation: 'nym'},
              {code: 'det', nickname: 'tigers', name: "detroit tigers", location: 'detroit', abbreviation: 'det'}
              {code: 'bos', nickname: 'red sox', name: "boston red sox", location: 'boston', abbreviation: 'bos'}
            ]

master_scoreboard_url_template = "http://gd2.mlb.com/components/game/mlb/year_{{year}}/month_{{month}}/day_{{day}}/master_scoreboard.json"
linescore_url_template = "http://gd2.mlb.com/components/game/mlb/year_{{year}}/month_{{month}}/day_{{day}}/{{gid}}/linescore.json"
boxscore_url_template = "http://gd2.mlb.com/components/game/mlb/year_{{year}}/month_{{month}}/day_{{day}}/{{gid}}/boxscore.json"
game_events_url_template = "http://gd2.mlb.com/components/game/mlb/year_{{year}}/month_{{month}}/day_{{day}}/{{gid}}/game_events.json"


game_events_description_template =  """
                                    \n
                                    {{#inning}}
                                    \n
                                    Bottom of the {{num}}
                                    {{#bottom}}
                                    {{#atbat}}
                                    * {{des}}
                                    {{/atbat}}
                                    {{/bottom}}
                                    \n
                                    Top of the {{num}}
                                    {{#top}}
                                    {{#atbat}}
                                    * {{des}}
                                    {{/atbat}}
                                    {{/top}}
                                    \n
                                    {{/inning}}
                                    \n
                                    """

module.exports = (robot) ->

  robot.respond /gid ([a-zA-Z\s]+) (yesterday|today|on [a-zA-Z0-9\s]*|last [a-zA-Z0-9\s]*|next [a-zA-Z0-9\s]*)/i, (msg) ->
    team = msg.match[1]
    gameday_date = human_to_gameday_date msg.match[2]
    game_data_directory msg, gameday_date, team, (gid) ->
      msg.send gid

  robot.respond /linescore ([a-zA-Z\s]+) (yesterday|today|on [a-zA-Z0-9\s]*|last [a-zA-Z0-9\s]*|next [a-zA-Z0-9\s]*)/i, (msg) ->
    team = msg.match[1]
    gameday_date = human_to_gameday_date msg.match[2]
    gameday_linescore_data msg, gameday_date, team, (linescore) ->
      msg.send JSON.stringify(linescore)

  robot.respond /boxscore ([a-zA-Z\s]+) (yesterday|today|on [a-zA-Z0-9\s]*|last [a-zA-Z0-9\s]*|next [a-zA-Z0-9\s]*)/i, (msg) ->
    team = msg.match[1]
    gameday_date = human_to_gameday_date msg.match[2]
    gameday_boxscore_data msg, gameday_date, team, (boxscore) ->
      msg.send JSON.stringify(boxscore)

  robot.respond /events ([a-zA-Z\s]+) (yesterday|today|on [a-zA-Z0-9\s]*|last [a-zA-Z0-9\s]*|next [a-zA-Z0-9\s]*)/i, (msg) ->
    team = msg.match[1]
    gameday_date = human_to_gameday_date msg.match[2]
    gameday_game_events_data msg, gameday_date, team, (game_events) ->
      msg.send mustache.render(game_events_description_template, game_events.data.game)

gameday_game_events_data = (msg, gameday_date, team, game_events) ->
  game_data_directory msg, gameday_date, team, (gid) ->
    gameday_date.gid = gid
    game_events_url = mustache.render(game_events_url_template, gameday_date)
    msg.http(game_events_url)
      .get() (err, res, body) ->
        game_events JSON.parse(body)

gameday_linescore_data = (msg, gameday_date, team, linescore) ->
  game_data_directory msg, gameday_date, team, (gid) ->
    gameday_date.gid = gid
    linescore_url = mustache.render(linescore_url_template, gameday_date)
    msg.http(linescore_url)
      .get() (err, res, body) ->
        linescore JSON.parse(body)

gameday_boxscore_data = (msg, gameday_date, team, boxscore) ->
  game_data_directory msg, gameday_date, team, (gid) ->
    gameday_date.gid = gid
    boxscore_url = mustache.render(boxscore_url_template, gameday_date)
    msg.http(boxscore_url)
      .get() (err, res, body) ->
        boxscore JSON.parse(body)

human_to_gameday_date = (text) ->
  date_obj = chrono.parse text
  date = moment(date_obj[0].startDate)
  {year: date.format("YYYY"), month: date.format("MM"), day: date.format("DD"), gid: ''}

game_data_directory = (msg, gameday_date, team, gid) ->
  master_scoreboard_url = mustache.render(master_scoreboard_url_template, gameday_date)
  msg.http(master_scoreboard_url)
    .get() (err, res, body) ->
      scoreboard = JSON.parse(body)
      team_code = mlb_team_code team
      game = game_for_team_code scoreboard, team_code
      gid game.game_data_directory.match(/(gid\w*)$/i)[0]

mlb_team_code = (team) ->
  team_attributes = _.find(team_hash, {nickname: team.toLowerCase()}) or _.find(team_hash, {abbreviation: team.toLowerCase()}) or _.find(team_hash, {name: team.toLowerCase()}) or _.find(team_hash, {location: team.toLowerCase()})
  team_attributes.code

game_for_team_code = (scoreboard, team_code) ->
  home_team_game = _.find(scoreboard.data.games.game, { 'home_code': team_code })
  away_team_game = _.find(scoreboard.data.games.game, { 'away_code': team_code })
  home_team_game or away_team_game
