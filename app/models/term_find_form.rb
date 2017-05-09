class TermFindForm
  include ActiveModel::Model

  attr_accessor :post_from, :post_to

  validates :post_from, presence: true
  validates :post_to, presence: true

  def initialize(params = {})
    if params.is_a?(ActionController::Parameters)
      [:post_from, :post_to].each do |attribute|
        datetime_parts = (1..5).map { |i| params.delete("#{attribute}(#{i}i)") }
        params[attribute] = Time.zone.local(*datetime_parts) if datetime_parts.any?
      end
    end
    super
  end
end
