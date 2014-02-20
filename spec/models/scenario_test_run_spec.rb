require 'spec_helper'

describe ScenarioTestRun do

  describe 'relations' do

    it { should belong_to(:scenario) }
    it { should embed_many(:browser_tests) }

  end

  describe 'methods' do

    let(:project) { create(:project) }
    let(:feature) { create(:feature, project: project) }
    let(:scenario) { create(:scenario, feature: feature) }
    let(:test_run) { create(:scenario_test_run, scenario: scenario) }

    it "should have a name" do
      expect(test_run.name).should eq(scenario.name)
    end

    it "should have a project" do
      expect(test_run.project).should eq(project)
    end

    it "should have a feature" do
      expect(test_run.feature).should eq(feature)
    end

    it "should have a start_notification_message" do
          msg = "Test Run started for #{project.name} - #{feature.name} - #{scenario.name} - #{test_run.number}: "
          msg += "#{ENV['API_URL']}/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/test_runs/#{test_run.id}"
      expect(test_run.start_notification_message).to eq(msg)
    end

    describe 'complete_notification_message' do

      context 'with fail status' do

        before do
          test_run.stub(:status).and_return('fail')
        end

        it "should have a failed complete_notification_message" do
          msg = "Test Run failed for #{project.name} - #{feature.name} - #{scenario.name} - #{test_run.number}: "
          msg += "#{ENV['API_URL']}/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/test_runs/#{test_run.id}"
          expect(test_run.complete_notification_message).to eq(msg)
        end

      end

      context 'with pass status' do

        before do
          test_run.stub(:status).and_return('pass')
        end

        it "should have a passed complete_notification_message" do
          msg = "Test Run passed for #{project.name} - #{feature.name} - #{scenario.name} - #{test_run.number}: "
          msg += "#{ENV['API_URL']}/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/test_runs/#{test_run.id}"
          expect(test_run.complete_notification_message).to eq(msg)
        end

      end

    end

  end

  describe 'status' do

    let(:scenario) { create(:scenario)}
    let(:test_run) { create(:scenario_test_run, scenario: scenario) }

    context "all tests passed" do
      before do
        2.times do
          create(:scenario_browser_test, status: "pass", test_run: test_run)
        end
      end

      it "status returns true iZf all tests passed" do
        expect(test_run.status).to eq "pass"
      end
    end

    context "one test failed" do
      before do
        create(:scenario_browser_test, status: "pass", test_run: test_run)
        create(:scenario_browser_test, status: "fail", test_run: test_run)
      end

      it "returns fail" do
        expect(test_run.status).to eq "fail"
      end
    end

    context "no status on tests" do
      before do
        create(:scenario_browser_test, status: nil, test_run: test_run)
        create(:scenario_browser_test, status: "pass", test_run: test_run)
        create(:scenario_browser_test, status: "fail", test_run: test_run)
      end

      it "return running" do
        expect(test_run.status).to eq "running"
      end
    end

  end

end