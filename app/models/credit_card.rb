class CreditCard
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessor :stripe_token

  field :stripe_id, type: String
  field :name, type: String
  field :last4, type: String
  field :cc_type, type: String
  field :exp_month, type: String
  field :exp_year, type: String

  belongs_to :user

  validates :stripe_id, :name, :last4, :cc_type, presence: true

  before_validation :update_data_from_stripe, on: :create

  private

  def update_data_from_stripe
    Rails.logger.debug("creating card for #{stripe_token}")
    stripe_customer = user.create_or_retrieve_stripe_customer
    card = stripe_customer.cards.create({card: self.stripe_token})
    self.stripe_id = card.id
    self.last4 = card.last4
    self.cc_type = card.type
    self.name = card.name
    self.exp_month = card.exp_month
    self.exp_year = card.exp_year
    self.stripe_token = nil
   end

   def stripe_card
    stripe_customer = user.create_or_retrieve_stripe_customer
    credit_card = stripe_customer.cards.retrieve(stripe_id)
  end

end
