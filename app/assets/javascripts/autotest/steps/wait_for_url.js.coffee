class Autotest.Steps.WaitForUrlStep

  constructor: (@step) ->
    @url = @step.get("text")


  perform: ->
    # Wait until page is loaded???
    if document.location.href == @url
      return true
    else
      return false

Autotest.Developer.Steps.add("waitForCurrentUrl", (step) ->
  waitForUrlStep = new Autotest.Steps.WaitForUrlStep(step)
  waitForUrlStep.perform()
)