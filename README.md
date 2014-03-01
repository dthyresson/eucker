# Eucker

Eucker is a set of scripts for [Hubot][hubot], a version of GitHub's Campfire bot, that responds to Major League Baseball requests to return scores, boxscores, stats and other tidbits of baseball info to sprinkle into your workday.

He's inspired by [Bob Eucker][bob_eucker], a retired American Major League Baseball player, later a sportscaster, comedian and actor. Uecker was given the title of "Mr. Baseball" by TV talk show host Johnny Carson. 

He made lots of Miller Light Ads in the early 1980's.

[![Miller Light Ads](http://img.youtube.com/vi/mUPeO0MbBgc/0.jpg)](http://www.youtube.com/watch?v=mUPeO0MbBgc)

And became immortalized in the classic film Major League with this quote:

[![Just a Bit Outside](http://img.youtube.com/vi/dalrphHivOs/0.jpg)](http://www.youtube.com/watch?v=dalrphHivOs)

Oh, he also played the dad in 80's sitcom, Mr. Belvedere.  

[bob_eucker]: http://en.wikipedia.org/wiki/Bob_Uecker

## What can Eucker do?

He can respond to 'natural language-like' queiriues with baseball game and stat updates within your Campfire room.

**Question:** Did a team win or lose on a given date?
**Usage:** hubot did the red sox win on April 19th 2013?

**Question:** Ascii Table Boxscore for the game played by the given team on a specified date
**Usage:** hubot box me red sox on April 19th 2013

**Question:** Lists a game's events
**Usage:** hubot events red sox on April 19th 2013

**Question:** Random video highlight for a date
**Usage:** hubot highlights for October 8th 2013

**Question:** Random video highlight for a game played by the specified team for a given date
**Usage:** hubot highlight red sox for October 8th 2013

Since he understands dates like "today" or "yesterday" last Tuesday" or "next Friday" or "on may 11 2013", your inquiries can sounded human.

Eucker's capabilities will be expanded during [Baseball Hackday - Boston][hackday] which takes place March 2nd 2014, 9:30am – 6pm.

## Why Eucker?

Eucker is a project for Baseball Hackday for [Baseball Hackday - Boston][hackday] which takes place March 2nd 2014, 9:30am – 6pm.

[hackday]: http://www.baseballhackday.com/boston/

## Using Eucker 

### Commands

TODO: Final Commands

### MLB Gameday Structure

TODO

## Acknowledgements

### MLB Gameday and Terms of Use

These scripts access MLB Gameday data which is copyrighted by MLB Advanced Media, L.P.  Use of any content acknowledges agreement to the terms posted here http://gdx.mlb.com/components/copyright.txt

### Hubot

[Hubot][hubot]  is your company's robot. Install him in your company to dramatically improve and reduce employee efficiency. [Hubot][hubot] 

[hubot]: http://hubot.github.com/

# Installing Eucker on Hubot

Eucker is built on a version of GitHub's Campfire bot, hubot. He's pretty cool.

This version is designed to be deployed on [Heroku][heroku]. This README was generated for you by hubot to help get you started. Definitely update and improve to talk about your own instance, how to use and deploy, what functionality he has, etc!

[heroku]: http://www.heroku.com

### Testing Hubot Locally

You can test your hubot by running the following.

    % bin/hubot

You'll see some start up output about where your scripts come from and a
prompt.

    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading adapter shell
    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading scripts from /home/tomb/Development/hubot/scripts
    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading scripts from /home/tomb/Development/hubot/src/scripts
    Hubot>

Then you can interact with hubot by typing `hubot help`.

    Hubot> hubot help

    Hubot> animate me <query> - The same thing as `image me`, except adds a few
    convert me <expression> to <units> - Convert expression to given units.
    help - Displays all of the help commands that Hubot knows about.
    ...


### Scripting

Take a look at the scripts in the `./scripts` folder for examples.
Delete any scripts you think are useless or boring.  Add whatever functionality you
want hubot to have. Read up on what you can do with hubot in the [Scripting Guide](https://github.com/github/hubot/blob/master/docs/scripting.md).

### Redis Persistence

If you are going to use the `redis-brain.coffee` script from `hubot-scripts`
(strongly suggested), you will need to add the Redis to Go addon on Heroku which requires a verified
account or you can create an account at [Redis to Go][redistogo] and manually
set the `REDISTOGO_URL` variable.

    % heroku config:add REDISTOGO_URL="..."

If you don't require any persistence feel free to remove the
`redis-brain.coffee` from `hubot-scripts.json` and you don't need to worry
about redis at all.

[redistogo]: https://redistogo.com/

## Adapters

Adapters are the interface to the service you want your hubot to run on. This
can be something like Campfire or IRC. There are a number of third party
adapters that the community have contributed. Check
[Hubot Adapters][hubot-adapters] for the available ones.

If you would like to run a non-Campfire or shell adapter you will need to add
the adapter package as a dependency to the `package.json` file in the
`dependencies` section.

Once you've added the dependency and run `npm install` to install it you can
then run hubot with the adapter.

    % bin/hubot -a <adapter>

Where `<adapter>` is the name of your adapter without the `hubot-` prefix.

[hubot-adapters]: https://github.com/github/hubot/blob/master/docs/adapters.md

## hubot-scripts

There will inevitably be functionality that everyone will want. Instead
of adding it to hubot itself, you can submit pull requests to
[hubot-scripts][hubot-scripts].

To enable scripts from the hubot-scripts package, add the script name with
extension as a double quoted string to the `hubot-scripts.json` file in this
repo.

[hubot-scripts]: https://github.com/github/hubot-scripts

## external-scripts

Tired of waiting for your script to be merged into `hubot-scripts`? Want to
maintain the repository and package yourself? Then this added functionality
maybe for you!

Hubot is now able to load scripts from third-party `npm` packages! To enable
this functionality you can follow the following steps.

1. Add the packages as dependencies into your `package.json`
2. `npm install` to make sure those packages are installed

To enable third-party scripts that you've added you will need to add the package
name as a double quoted string to the `external-scripts.json` file in this repo.

## Deployment

    % heroku create --stack cedar
    % git push heroku master
    % heroku ps:scale app=1

If your Heroku account has been verified you can run the following to enable
and add the Redis to Go addon to your app.

    % heroku addons:add redistogo:nano

If you run into any problems, checkout Heroku's [docs][heroku-node-docs].

You'll need to edit the `Procfile` to set the name of your hubot.

More detailed documentation can be found on the
[deploying hubot onto Heroku][deploy-heroku] wiki page.

### Deploying to UNIX or Windows

If you would like to deploy to either a UNIX operating system or Windows.
Please check out the [deploying hubot onto UNIX][deploy-unix] and
[deploying hubot onto Windows][deploy-windows] wiki pages.

[heroku-node-docs]: http://devcenter.heroku.com/articles/node-js
[deploy-heroku]: https://github.com/github/hubot/blob/master/docs/deploying/heroku.md
[deploy-unix]: https://github.com/github/hubot/blob/master/docs/deploying/unix.md
[deploy-windows]: https://github.com/github/hubot/blob/master/docs/deploying/unix.md

## Campfire Variables

If you are using the Campfire adapter you will need to set some environment
variables. Refer to the documentation for other adapters and the configuraiton
of those, links to the adapters can be found on [Hubot Adapters][hubot-adapters].

Create a separate Campfire user for your bot and get their token from the web
UI.

    % heroku config:add HUBOT_CAMPFIRE_TOKEN="..."

Get the numeric IDs of the rooms you want the bot to join, comma delimited. If
you want the bot to connect to `https://mysubdomain.campfirenow.com/room/42` 
and `https://mysubdomain.campfirenow.com/room/1024` then you'd add it like this:

    % heroku config:add HUBOT_CAMPFIRE_ROOMS="42,1024"

Add the subdomain hubot should connect to. If you web URL looks like
`http://mysubdomain.campfirenow.com` then you'd add it like this:

    % heroku config:add HUBOT_CAMPFIRE_ACCOUNT="mysubdomain"

[hubot-adapters]: https://github.com/github/hubot/blob/master/docs/adapters.md

## Restart the bot

You may want to get comfortable with `heroku logs` and `heroku restart`
if you're having issues.
