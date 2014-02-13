class FeatureTestRun

  include TestRun

  field :name, type: String

  belongs_to :feature

  embeds_many :browser_tests, class_name: 'FeatureBrowserTest'
  embeds_many :scenarios, class_name: 'FeatureTestRunScenario'

  before_create :set_name
  before_create :create_scenarios

  def run
    update_attribute(:run_at, Time.now)
    # Create scenarios

    platforms.each do |p|
      browser_test = browser_tests.create!({browser: p.split('_').last,
                                            platform: p.split('_').first})
      TestWorker.perform_async("run_test", "Feature", self.id.to_s, browser_test.id.to_s)
    end
  end

  def project
    feature.project
  end

  def start_notification_message
    notification = "Test Run Started For: "
    notification += "#{self.project.name} - #{self.feature.name} - #{self.number}"
    url = project_feature_test_run_url(project, feature, self, host: ENV["API_URL"])
    notification += " "
    notification += url
  end

  def complete_notification_message
    notification += "Test Run #{status}ed for #{self.project.name}- #{self.feature.name} - #{number}:"
    url = project_feature_test_run_url(project, feature, self, host: ENV['API_URL'])
    notification += " "
    notification += url
  end

  private

  def set_name
    self.name = feature.name
  end

  def set_number
    self.number = feature.feature_test_runs.size + 1
  end

  def create_scenarios
    feature.scenarios.each do |scenario|
      scenarios << FeatureTestRunScenario.new(scenario: scenario)
    end
  end

end