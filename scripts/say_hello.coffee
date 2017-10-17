module.exports = (robot) ->

  robot.respond /hello/i, (res) ->
    res.reply "Hello to you too."
