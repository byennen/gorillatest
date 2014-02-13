class Scenario

  attr_accessor :driver

  include Mongoid::Document
  include Mongoid::Paranoia

 field :name, type: String

 field :window_x, type: Integer
 field :window_y, type: Integer
 field :start_url, type: String

 #embedded_in :feature
 belongs_to :feature

 embeds_many :steps

 has_many :scenario_test_runs

 validates :name, presence: true, uniqueness: {conditions: -> { where(deleted_at: nil)}, scope: :feature}

end
