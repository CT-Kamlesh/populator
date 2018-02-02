class CourtGroup
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :category, type: String

  has_many :cause_lists, inverse_of: :court_group, autosave: true, dependent: :destroy

  #validates :name, presence: true
  validates :category, presence: true
  #validates :category, uniqueness: true

  #index({ category: 1 }, { unique: true, drop_dups: true })
end
