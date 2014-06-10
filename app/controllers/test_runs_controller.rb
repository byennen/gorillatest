class TestRunsController < ApplicationController

  before_filter :authenticate_user!

  before_filter :find_project, :find_scenario

  def index
    @test_runs = @scenario.test_runs.all
  end

  def show
    @test_run = @scenario.test_runs.find_by(number: params[:id])

    if params[:test] == "run"
      @test_run.browser_tests.each do |test|
        puts "*" * 100
        DemoWorker.perform_async(@test_run.id.to_s, test.id.to_s)
      end
    end
  end


  private

  def find_scenarios
    @scenario = @project.scenarios.find(param[:test_id])
  end

end
