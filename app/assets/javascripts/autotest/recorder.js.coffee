class @AutoTestRecorder
  constructor: (@projectId) ->
    @authToken = window.autoTestAuthToken
    if window.sessionStorage
      @sessionStorage = window.sessionStorage
    else
      alert("You can't record on this browser")
    @isRecording = @sessionStorage.getItem("autoTestRecorder.isRecording") == "true" ? true : false
    @currentScenario = null
    @currentFeature = null
    @features = new Array

  start: ->
    @features = AutoTestFeature.findAll(@projectId)
    _this = this
    if @isRecording == true
      console.log("You are presently recording a scenario")
      # load the current scenario
      scenarioId = @sessionStorage.getItem("autoTestRecorder.currentScenario")
      featureId = @sessionStorage.getItem("autoTestRecorder.currentFeature")
      options = new Array
      if featureId != null
        @currentFeature = AutoTestFeature.find(@projectId, featureId)
        # Figure out where to move this!!!
        $("select#features").val(featureId)
      if scenarioId != null
        @currentScenario = AutoTestScenario.find(@projectId, @currentFeature.id, scenarioId)
      # Record step of redirected to -> current window location href
      $("iframe").load ->
        window.postMessageToIframe({messageType: "recording", recording: _this.isRecording, message: {scenarioName: _this.currentScenario.name, featureName: _this.currentFeature.name}})
        step = _this.currentScenario.addStep("waitForCurrentUrl", {}, window.location.href)
      # This isn't actually starting recording
      console.log("Restarting Recording")
      $.each(@currentScenario.autoTestSteps, (i, autoTestStep) ->
        console.log(i)
        $("ul#autotest-steps").append("<li step-number=#{i}>#{autoTestStep.to_s}</li>")
      )

      this.record()
    else
      # Figure out where to move this
      $("button#stop-recording").hide()
      $("button#record-text-highlight").hide()

  record: ->
    console.log("We are currently recording")
    # Collect actions to a JSON structure
    @isRecording = true
    @sessionStorage.setItem("autoTestRecorder.isRecording", @isRecording)
    console.log("Binding DOM events")
    AutoTestEvent.bind()
    AutoTestEvent.bindDomNodeInsert()
    # $(".recording-bar").unbind("DOMNodeInserted", AutoTestEvent.bindDomNodeInsert)
    # $(".recording-bar button").unbind("click", AutoTestEvent.bindClick)

    autoTestGuiController.recording(this)
    return

  stop: ->
    @isRecording = false
    @sessionStorage.setItem("autoTestRecorder.isRecording", false)
    @sessionStorage.removeItem("autoTestRecorder.currentFeature")
    @sessionStorage.removeItem("autoTestRecorder.currentScenario")
    # Unbind all events
    autoTestGuiController.removeStepsList()
    AutoTestEvent.unbind()
    window.location.href = window.location.href

  setCurrentFeature: (featureId) ->
    console.log("Setting current feature")
    @currentFeature = AutoTestFeature.find(@projectId, featureId)
    @sessionStorage.setItem("autoTestRecorder.currentFeature", featureId)

  addScenario: (name) ->
    newScenario = AutoTestScenario.create(@projectId, @currentFeature.id, name, window.location.href, $(window).width(), $(window).height())
    if newScenario.status == "success"
      @currentScenario = newScenario.scenario
      @sessionStorage.setItem("autoTestRecorder.currentScenario", @currentScenario.id)
    return newScenario

  recordHighlight: (text)->
    scenario = this.currentScenario
    stepLocator = {type: "text highlight on page", value: window.location.pathname}
    scenario.addStep("Highlight Text", stepLocator, text)
