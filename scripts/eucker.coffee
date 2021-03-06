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

{wait, repeat, doAndRepeat, waitUntil} = require 'wait'

tablify = require('tablify').tablify

# Eucker Bot!
module.exports = (robot) ->

  # Lists a game's events
  # Usage: hubot events red sox on April 19th 2013

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

  robot.respond /events ([a-zA-Z\s]+) (yesterday|today|on [a-zA-Z0-9\s]*|last [a-zA-Z0-9\s]*|next [a-zA-Z0-9\s]*)/i, (msg) ->
    team = msg.match[1]
    gameday_date = human_to_gameday_date msg.match[2]
    gameday_game_events_data msg, gameday_date, team, (game_events) ->
      msg.send mustache.render(game_events_description_template, game_events.game)

  # Did a team win or lose on a given date?
  # Usage: hubot did the red sox win on April 19th 2013?

  home_team_wins_template = "{{home_team_name}} beat the {{away_team_name}} {{home_team_runs}}-{{away_team_runs}} at {{venue}} on {{{original_date}}}"
  away_team_wins_template = "{{away_team_name}} beat the {{home_team_name}} {{away_team_runs}}-{{home_team_runs}} at {{venue}} on {{{original_date}}}"

  robot.respond /([a-zA-Z\s]+) (win|lose|won|lost) (yesterday|today|on [a-zA-Z0-9\s]*|last [a-zA-Z0-9\s]*|next [a-zA-Z0-9\s]*)/i, (msg) ->
    team = msg.match[1].match(mlb_teams)[1]
    gameday_date = human_to_gameday_date msg.match[3]
    miniscoreboard_game_data msg, gameday_date, team, (game) ->
      home_team_runs = +"#{game.home_team_runs}"
      away_team_runs = +"#{game.away_team_runs}"
      if home_team_runs > away_team_runs
        msg.send mustache.render(home_team_wins_template, game)
      else
        msg.send mustache.render(away_team_wins_template, game)

  # Ascii Table Boxscore for the game played by the given team on a specified date
  # Usage: hubot box me red sox on April 19th 2013
  robot.respond /box me ([a-zA-Z\s]+) (yesterday|today|for [a-zA-Z0-9\s]*|on [a-zA-Z0-9\s]*|last [a-zA-Z0-9\s]*|next [a-zA-Z0-9\s]*)/i, (msg) ->
    team = msg.match[1]
    gameday_date = human_to_gameday_date msg.match[2]
    gameday_linescore_data msg, gameday_date, team, (linescore) ->
      total_runs_attribute = if is_home_team linescore, team
        'home_team_runs'
      else
        'away_team_runs'
      inning_runs_attribute = if is_home_team linescore, team
        'home_inning_runs'
      else
        'away_inning_runs'
      humanized_linescore =  humanize_linescore linescore.game
      msg.send tablify humanized_linescore, {show_index: false, keys: ['INNING', linescore.game.home_name_abbrev, linescore.game.away_name_abbrev]}

  # Random video highlight for a date
  # Usage: hubot highlights for October 8th 2013
  robot.respond /highlights (yesterday|today|on [a-zA-Z0-9\s]*|for [a-zA-Z0-9\s]*|last [a-zA-Z0-9\s]*|next [a-zA-Z0-9\s]*)/i, (msg) ->
    gameday_date = human_to_gameday_date msg.match[1]
    highlights_data msg, gameday_date, (highlights) ->
      highlight = _.sample(highlights)
      media = _.sample(highlight.media)
      headline = media.headline
      video_url = _.first(media.url)['_']
      thumbnail_url = large_thumbnail media.thumb
      msg.send  "#{thumbnail_url}"
      wait 500, ->
        msg.send "Watch '#{headline}' - #{video_url}"

  # Random video highlight for a game played by the specified team for a given date
  # Usage: hubot highlight red sox for October 8th 2013
  robot.respond /highlight ([a-zA-Z\s]+) (yesterday|today|for [a-zA-Z0-9\s]*|last [a-zA-Z0-9\s]*|on [a-zA-Z0-9\s]*|last [a-zA-Z0-9\s]*|next [a-zA-Z0-9\s]*)/i, (msg) ->
    team = msg.match[1]
    gameday_date = human_to_gameday_date msg.match[2]
    game_highlights_data msg, gameday_date, team, (highlights) ->
      highlight = highlights.highlights
      media = _.sample(highlight.media)
      headline = media.headline
      video_url = _.first(media.url)['_']
      thumbnail_url = large_thumbnail media.thumb
      msg.send "#{thumbnail_url}"
      wait 500, ->
        msg.send "Watch '#{headline}' - #{video_url}"

  #
  # Major League Homage
  #

  # Image of Charlie Sheen as Wild Thing
  # Usage: hubot wild thing
  robot.hear /wild thing/i, (msg) ->
    msg.send "http://wac.450f.edgecastcdn.net/80450F/banana1015.com/files/2011/08/wild-thing-630x417.jpg"

  # Just a bit outside!
  # Usage: hubot eucker
  robot.hear /eucker|doyle|harry|harry doyle/i, (msg) ->
    msg.reply "Just a bit outside ..."

  #
  # Demo examples for core gameday methods, such as getting a GID, boxscore, miniscoreboard, linescore, etc
  #

  # For a team playing on a date, find its GID (gameday id)
  robot.respond /gid ([a-zA-Z\s]+) (yesterday|today|on [a-zA-Z0-9\s]*|last [a-zA-Z0-9\s]*|next [a-zA-Z0-9\s]*)/i, (msg) ->
    team = msg.match[1]
    gameday_date = human_to_gameday_date msg.match[2]
    game_data_directory msg, gameday_date, team, (gid) ->
      msg.send gid

  # For a date, show the Master Scoreboard data
  robot.respond /master_scoreboard (yesterday|today|on [a-zA-Z0-9\s]*|last [a-zA-Z0-9\s]*|next [a-zA-Z0-9\s]*)/i, (msg) ->
    gameday_date = human_to_gameday_date msg.match[1]
    master_scoreboard_data msg, gameday_date, (master_scoreboard) ->
      msg.send JSON.stringify(master_scoreboard)

  # For a date, show the Mini Scoreboard data
  robot.respond /miniscoreboard (yesterday|today|on [a-zA-Z0-9\s]*|last [a-zA-Z0-9\s]*|next [a-zA-Z0-9\s]*)/i, (msg) ->
    gameday_date = human_to_gameday_date msg.match[1]
    miniscoreboard_data msg, gameday_date, (miniscoreboard) ->
      msg.send JSON.stringify(miniscoreboard)

  # For a team playing on a date, show the Linescore data for that game
  robot.respond /linescore ([a-zA-Z\s]+) (yesterday|today|on [a-zA-Z0-9\s]*|last [a-zA-Z0-9\s]*|next [a-zA-Z0-9\s]*)/i, (msg) ->
    team = msg.match[1]
    gameday_date = human_to_gameday_date msg.match[2]
    gameday_linescore_data msg, gameday_date, team, (linescore) ->
      msg.send JSON.stringify(linescore)

  # For a team playing on a date, show the Boxscore data for that game
  robot.respond /boxscore ([a-zA-Z\s]+) (yesterday|today|on [a-zA-Z0-9\s]*|last [a-zA-Z0-9\s]*|next [a-zA-Z0-9\s]*)/i, (msg) ->
    team = msg.match[1]
    gameday_date = human_to_gameday_date msg.match[2]
    gameday_boxscore_data msg, gameday_date, team, (boxscore) ->
      msg.send JSON.stringify(boxscore)


#
# Gameday pseudo-API methods
#

# Take a human expression of a date (today, last Thursday, next Monday, October 2, June 3rd 2013) and creates
# an object with the necessary date components needed when constructing a gameday url
human_to_gameday_date = (text) ->
  date_obj = chrono.parse text
  date = moment(date_obj[0].startDate)
  {year: date.format("YYYY"), month: date.format("MM"), day: date.format("DD"), gid: ''}

# Given a date and a team, return the game events data
game_events_url_template = "http://gd2.mlb.com/components/game/mlb/year_{{year}}/month_{{month}}/day_{{day}}/{{gid}}/game_events.json"
gameday_game_events_data = (msg, gameday_date, team, game_events) ->
  game_data_directory msg, gameday_date, team, (gid) ->
    gameday_date.gid = gid
    game_events_url = mustache.render(game_events_url_template, gameday_date)
    msg.http(game_events_url)
      .get() (err, res, body) ->
        game_events JSON.parse(body).data

# Given a date and a team, return the game linescore
linescore_url_template = "http://gd2.mlb.com/components/game/mlb/year_{{year}}/month_{{month}}/day_{{day}}/{{gid}}/linescore.json"

gameday_linescore_data = (msg, gameday_date, team, linescore) ->
  game_data_directory msg, gameday_date, team, (gid) ->
    gameday_date.gid = gid
    linescore_url = mustache.render(linescore_url_template, gameday_date)
    msg.http(linescore_url)
      .get() (err, res, body) ->
        linescore JSON.parse(body).data

# Given a date and a team, return the game boxscore
boxscore_url_template = "http://gd2.mlb.com/components/game/mlb/year_{{year}}/month_{{month}}/day_{{day}}/{{gid}}/boxscore.json"
gameday_boxscore_data = (msg, gameday_date, team, boxscore) ->
  game_data_directory msg, gameday_date, team, (gid) ->
    gameday_date.gid = gid
    boxscore_url = mustache.render(boxscore_url_template, gameday_date)
    msg.http(boxscore_url)
      .get() (err, res, body) ->
        boxscore JSON.parse(body).data

# Given a date, return the Master Scoreboard
master_scoreboard_url_template = "http://gd2.mlb.com/components/game/mlb/year_{{year}}/month_{{month}}/day_{{day}}/master_scoreboard.json"

master_scoreboard_data = (msg, gameday_date, scoreboard) ->
  master_scoreboard_url = mustache.render(master_scoreboard_url_template, gameday_date)
  msg.http(master_scoreboard_url)
    .get() (err, res, body) ->
      scoreboard JSON.parse(body).data

# Given a date, return the Mini Scoreboard
miniscoreboard_url_template = "http://gd2.mlb.com/components/game/mlb/year_{{year}}/month_{{month}}/day_{{day}}/miniscoreboard.json"

miniscoreboard_data = (msg, gameday_date, scoreboard) ->
  miniscoreboard_url = mustache.render(miniscoreboard_url_template, gameday_date)
  msg.http(miniscoreboard_url)
    .get() (err, res, body) ->
      scoreboard JSON.parse(body).data

# Given a date and a team, return the Master Scoreboard for the game played by the team
miniscoreboard_game_data = (msg, gameday_date, team, game) ->
  miniscoreboard_data msg, gameday_date, (scoreboard) ->
    team_code = mlb_team_code team
    game game_for_team_code scoreboard, team_code

# Given a date, return the Media Highlights (such as video clips)
game_highlights_url_template = "http://gd2.mlb.com/components/game/mlb/year_{{year}}/month_{{month}}/day_{{day}}/{{gid}}/media/highlights.xml"

highlights_data = (msg, gameday_date, highlights) ->
  highlights_url = mustache.render(highlights_url_template, gameday_date)
  msg.http(highlights_url)
    .get() (err, res, body) ->
      parser.parseString body, (error, result) ->
        highlights result.games.highlights

# Given a date and a team, return the Media Highlights (such as video clips) for the game played by the team
highlights_url_template = "http://gd2.mlb.com/components/game/mlb/year_{{year}}/month_{{month}}/day_{{day}}/media/highlights.xml"

game_highlights_data = (msg, gameday_date, team, highlights) ->
  game_data_directory msg, gameday_date, team, (gid) ->
    gameday_date.gid = gid
    game_highlights_url = mustache.render(game_highlights_url_template, gameday_date)
    msg.http(game_highlights_url)
      .get() (err, res, body) ->
        parser.parseString body, (error, result) ->
          highlights result

#
# Utility Methods
#

# Determine the Gameday Data Directory for a date and a team. The directory is where the data (boxscores, linescores, media, etc) for that game is stored.
game_data_directory = (msg, gameday_date, team, gid) ->
  master_scoreboard_data msg, gameday_date, (scoreboard) ->
    team_code = mlb_team_code team
    game = game_for_team_code scoreboard, team_code
    gid game.game_data_directory.match(/(gid\w*)$/i)[0]

# Translates a human expression of a team (Red Sox, Boston, Boston Red Sox, BOS) into the Gameday Team Code

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


gameday_team_lookup = [
              {code: 'lan', nickname: 'dodgers', name: 'los angeles dodgers', location: 'los angeles', abbreviation: 'los'},
              {code: 'ana', nickname: 'angels', name: 'los angeles angels', location: 'los angeles', abbreviation: 'ana'},
              {code: 'tex', nickname: 'rangers', name: 'texas rangers', location: 'texas', abbreviation: 'tex'},
              {code: 'sfn', nickname: 'giants', name: 'san francisco giants', location: 'san francisco', abbreviation: 'sfg'},
              {code: 'kca', nickname: 'royals', name: 'kansas city royals', location: 'kansas city', abbreviation: 'kan'},
              {code: 'mil', nickname: 'brewers', name: 'milwaukee brewers', location: 'milwaukee', abbreviation: 'mil'},
              {code: 'stl', nickname: 'cardinals', name: 'st. louis cardinals', location: 'st. louis', abbreviation: 'stl'},
              {code: 'col', nickname: 'rockies', name: 'colorado rockies', location: 'colorado', abbreviation: 'col'},
              {code: 'tor', nickname: 'blue jays', name: 'toronto blue jays', location: 'toronto', abbreviation: 'tor'},
              {code: 'hou', nickname: 'astros', name: 'houston astros', location: 'houston', abbreviation: 'hou'},
              {code: 'nyn', nickname: 'mets', name: 'new york mets', location: 'new york', abbreviation: 'nym'},
              {code: 'cha', nickname: 'white sox', name: 'chicago white sox', location: 'chicago', abbreviation: 'cws'},
              {code: 'sdn', nickname: 'padres', name: 'san diego padres', location: 'san diego', abbreviation: 'sdp'},
              {code: 'det', nickname: 'tigers', name: 'detroit tigers', location: 'detroit', abbreviation: 'det'},
              {code: 'min', nickname: 'twins', name: 'minnesota twins', location: 'minnesota', abbreviation: 'min'},
              {code: 'cin', nickname: 'reds', name: 'cincinnati reds', location: 'cincinnati', abbreviation: 'cin'},
              {code: 'pit', nickname: 'pirates', name: 'pittsburgh pirates', location: 'pittsburgh', abbreviation: 'pit'},
              {code: 'chn', nickname: 'cubs', name: 'chicago cubs', location: 'chicago', abbreviation: 'chc'},
              {code: 'sea', nickname: 'mariners', name: 'seattle mariners', location: 'seattle', abbreviation: 'sea'},
              {code: 'atl', nickname: 'braves', name: 'atlanta braves', location: 'atlanta', abbreviation: 'atl'},
              {code: 'ari', nickname: 'diamondbacks', name: 'arizona diamondbacks', location: 'arizona', abbreviation: 'ari'},
              {code: 'bal', nickname: 'orioles', name: 'baltimore orioles', location: 'baltimore', abbreviation: 'bal'},
              {code: 'cle', nickname: 'indians', name: 'cleveland indians', location: 'cleveland', abbreviation: 'cle'},
              {code: 'mia', nickname: 'marlins', name: 'miami marlins', location: 'miami', abbreviation: 'mia'},
              {code: 'oak', nickname: 'athletics', name: 'oakland athletics', location: 'oakland', abbreviation: 'oak'},
              {code: 'phi', nickname: 'phillies', name: 'philadelphia phillies', location: 'philadelphia', abbreviation: 'phi'},
              {code: 'was', nickname: 'nationals', name: 'washington nationals', location: 'washington', abbreviation: 'was'},
              {code: 'tba', nickname: 'rays', name: 'tampa bay rays', location: 'tampa bay', abbreviation: 'tam'},
              {code: 'nya', nickname: 'yankees', name: 'new york yankees', location: 'new york', abbreviation: 'nyy'},
              {code: 'bos', nickname: 'red sox', name: 'boston red sox', location: 'boston', abbreviation: 'bos'}
            ]

mlb_team_code = (team) ->
  team_attributes = _.find(gameday_team_lookup, {nickname: team.toLowerCase()}) or _.find(gameday_team_lookup, {abbreviation: team.toLowerCase()}) or _.find(gameday_team_lookup, {name: team.toLowerCase()}) or _.find(gameday_team_lookup, {location: team.toLowerCase()})
  team_attributes.code

# Given Gameday scoreboard game data, find the one played by the requested team
game_for_team_code = (scoreboard, team_code) ->
  home_team_game = _.find(scoreboard.games.game, { 'home_code': team_code })
  away_team_game = _.find(scoreboard.games.game, { 'away_code': team_code })
  home_team_game or away_team_game

# Given game data, determines if specified team is the home team
is_home_team = (data, team_code) ->
  code = _.pluck(data, 'home_code')
  _.contains(code, mlb_team_code team_code)

# Given game data, determines if specified team is the away team
is_away_team = (data, team_code) ->
  code = _.pluck(data, 'away_code')
  _.contains(code, mlb_team_code team_code)

# Given any Gameday thumbail image url, return the large thumbnail image url. Note: Gameday appears to store thumbnail images in a variety of sizes: 6, 7, 8, 22, 43
large_thumbnail = (thumbnail) ->
  "#{thumbnail}".replace /_\d+.jpg/, "_43.jpg"

# lines score with team names
humanize_linescore = (linescore_data) ->
  humanized_linescore = []
  _.forEach linescore_data.linescore, (inning_line) ->
    i = {}
    i[linescore_data.away_name_abbrev] = inning_line.away_inning_runs
    i[linescore_data.home_name_abbrev] = inning_line.home_inning_runs
    i['INNING'] = inning_line.inning
    humanized_linescore.push i

  hits = {}
  hits['INNING'] = 'Hits'
  hits[linescore_data.away_name_abbrev] = linescore_data.away_team_hits
  hits[linescore_data.home_name_abbrev] = linescore_data.home_team_hits
  humanized_linescore.push hits

  runs = {}
  runs['INNING'] = 'Runs'
  runs[linescore_data.away_name_abbrev] = linescore_data.away_team_runs
  runs[linescore_data.home_name_abbrev] = linescore_data.home_team_runs
  humanized_linescore.push runs

  errors = {}
  errors['INNING'] = 'Errors'
  errors[linescore_data.away_name_abbrev] = linescore_data.away_team_errors
  errors[linescore_data.home_name_abbrev] = linescore_data.home_team_errors
  humanized_linescore.push errors

  humanized_linescore
