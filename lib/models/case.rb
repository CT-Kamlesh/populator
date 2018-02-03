class Case
  include Mongoid::Document
  include Mongoid::Timestamps

  field :es_index, type: String
  field :es_type, type: String
  field :es_id, type: String

  field :number, type: String
  field :cnr, type: String
  field :code, type: String
  field :category, type: String

  alias_attribute :case_type, :category

  #validates :number, uniqueness: { scope: [:cause_list_id, :category] }

  #index({ number: 1, category: 1, cause_list_id: 1 }, { unique: true })

  belongs_to :cause_list, inverse_of: :cases
  has_one :case_information, inverse_of: :case, dependent: :destroy, autosave: true
  has_many :parties, inverse_of: :case, dependent: :destroy, autosave: true
end
