class TermFindForm
  include ActiveModel::Model

  attr_accessor :from, :to

  validates :from, presence: true
  validates :to, presence: true
end
