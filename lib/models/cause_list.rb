class CauseList
  include Mongoid::Document
  include Mongoid::Timestamps

  field :es_index, type: String
  field :es_type, type: String
  field :es_id, type: String

  field :cl_id, type: String
  field :storage_id, type: String
  field :judges, type: Array, default: []
  field :start_date, type: Date
  field :end_date, type: Date
  field :base_uri, type: String
  field :uri, type: String
  field :dated, type: Date
  field :inserted_at, type: DateTime
  field :category, type: String
  field :extension, type: String
  field :court_location, type: String
  field :court, type: String

  alias_attribute :causelist_type, :category
  alias_attribute :clauselist_type, :category
  alias_attribute :insert_time, :inserted_at

  validates :cl_id, :storage_id, :inserted_at, presence: true

  belongs_to :state, inverse_of: :cause_lists
  belongs_to :court_group, inverse_of: :cause_lists
  has_many :cases, inverse_of: :cause_list, dependent: :destroy, autosave: true
end
