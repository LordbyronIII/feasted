class Dislike
  include Mongoid::Document
  include Mongoid::Timestamps

  field :description

  belongs_to :patient
end
