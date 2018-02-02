class Party
  include Mongoid::Document
  include Mongoid::Timestamps

  field :category, type: String
  field :name, type: String
  field :address, type: String
  field :advocate, type: String

  belongs_to :case, inverse_of: :parties

  validates :category, presence: true
end
