# jobu quotes
jobu_quotes = [
                "Is very bad to steal Jobu's rum. Is very bad.",
                "I gotta wake up my bat.",
                "I'm pissed off now, Jobu. Look, I go to you. I stick up for you. You don't help me now. I say \"Fuck you,\" Jobu, I do it myself.",
                "Bats, they are sick. I cannot hit curveball. Straightball I hit it very much. Curveball, bats are afraid. I ask Jobu to come, take fear from bats. I offer him cigar, rum. He will come.",
                "Jesus, I like him very much, but he no help with curveball.",
                "Hats for bats, keep bats warm"
              ]

# Jobu Quotes!
# Usage: hubot jobu me
module.exports = (robot) ->
  robot.hear /jobu me/i, (msg) ->
    msg.send msg.random jobu_quotes
