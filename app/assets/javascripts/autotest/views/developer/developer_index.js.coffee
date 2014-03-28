class Autotest.Views.DeveloperIndex extends Backbone.View

  el: "#button-bar"
  events: {
    "click #play": "play"
    "click #stop": "stop"
    "click #pause": "pause"
    "click #forward": "forward"
    "click #backward": "backward"
  }

  showCurrentScenario: (featureName, scenarioName) ->
    scenario = "&nbsp;&nbsp;<strong>Developer Mode:</strong> #{featureName} - #{scenarioName}"
    $("#current-scenario").html(scenario)
    $("#current-scenario").show()

  showPlayStep: (message) ->
    console.log("Playing Step: #{message}")

  play: ->
    @showHidePlayButtons()
    @postMessage({messageType: "startPlayback"})

  stop: ->
    @showHidePlayButtons()
    @postMessage({messageType: "stopPlayback"})

  pause: ->
    @showHidePlayButtons
    @postMessage({messageType: "pausePlayback"})

  forward: ->
    @postMessage({messageType: "forwardPlayback"})

  backward: ->
    @postMessage({messageType: "backwardPlayback"})

  stopPlayback: ->
    @showHidePlayButtons()

  showHidePlayButtons: ->
    if $("#play").is(":visible")
      $("#play").hide()
      $("#pause").show()
      $("#stop").show()
    else
      $("#stop").hide()
      $("#pause").hide()
      $("#play").show()

  postMessage: (message) ->
    Autotest.Messages.Iframe.post(message)