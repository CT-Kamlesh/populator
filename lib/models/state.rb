class State
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :district, type: String

  has_many :cause_lists, inverse_of: :state, autosave: true, dependent: :destroy

  validates :name, presence: true
  #validates :name uniqueness: { scope: :district }
  #index({ name: 1, district: 1 }, { unique: true })
end
