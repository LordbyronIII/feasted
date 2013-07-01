class Wings::Rooms::Patients::Meals::OrdersController < Wings::Rooms::Patients::MealsController
  before_filter :find_order, except: [:index, :new]
  before_filter :find_patient
  before_filter :find_meal

  def index
    @orders = []
    @orders = @patient.orders.select {|order| order.family_member}
    @orders = @orders.select {|order| order.created_at.today?}
    @orders = @orders.select {|order| order.kind == @meal.kind}
  end

  def new
    @orders = []
    @orders = @patient.orders.select {|order| order.completed?}
    @orders = @orders.select {|order| order.kind == @meal.kind}
    @orders = @orders.select {|order| order.created_at.today?}
    if @orders.count >= 1
      redirect_to edit_wing_room_patient_meal_order_path(@wing, @room, @patient, @meal, @orders.first)
      
    else
      @order = Order.create(params)
      @order.update_attribute(:kind, @meal.kind)
      redirect_to edit_wing_room_patient_meal_order_path(@wing, @room, @patient, @meal, @order)
    end
  end

  def edit
    @foods = Food.all
    @destroy_foods = @order.foods
  end

  def edit_order
    @food = find_food
    @order.foods += [@food]
    redirect_to [:edit, @wing, @room, @patient, @meal, @order]
  end

  def destroy
    @food = find_food
    @order.foods = @order.foods.delete_if {|food| food == @food}
    redirect_to [:edit, @wing, @room, @patient, @meal, @order] 
  end

  def place_order
    @order.update_attribute(:completed, true)
    @order.update_attribute(:meal_id, @meal.id)
    @order.update_attribute(:patient_id, @patient.id)
    @order.meal_ids << @meal.id
    @order.save

    if rooms_all_placed_for_today
      redirect_to [:wings]
      return
    end

    if patients_all_placed_for_today(@room)
      redirect_to [@wing, :rooms]
      return
    end

    if orders_all_placed_for_today(@patient)
      redirect_to [@wing, @room, :patients]
      return
    end
    
    if params[:family_member]
      redirect_to select_option_for_patients_wing_room_patient_meal_path(@wing, @room, @patient, @meal), flash: {notice: "Your Order for #{@meal.kind} has been placed"}
      return
    end

    redirect_to wing_room_patient_meals_path(@wing, @room, @patient)
  end

  private

  def find_order
    order_id = params[:order_id].present? ? params[:order_id] : params[:id]
    @order = Order.find(order_id)
  end

  def find_food
    food_id = params[:food_id]
    @food = Food.find(food_id)
  end

  def orders_all_placed_for_today patient
    number_of_orders = []
    number_of_orders = patient.orders.select {|order| order.created_at.today?}
    number_of_orders = number_of_orders.select {|order| order.completed}
    if number_of_orders.count >= 3
      return true
    else
      return false
    end
  end
end
