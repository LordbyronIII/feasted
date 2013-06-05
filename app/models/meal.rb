class Meal
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type

  belongs_to :patient
  has_many :orders
  has_and_belongs_to_many :foods

  def create_order meal
    order = Order.create(meal_id: meal.id, patient_id: meal.patient.id, type: meal.type)
    order.foods = meal.foods
    order.save!
    return order
  end
end
