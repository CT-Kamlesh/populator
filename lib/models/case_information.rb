class CaseInformation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :information, type: String

  belongs_to :case, inverse_of: :case_information

  validates :information, presence: true
end
