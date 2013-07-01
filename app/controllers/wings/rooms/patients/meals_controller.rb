class Wings::Rooms::Patients::MealsController < Wings::Rooms::PatientsController
  before_filter :find_patient
  before_filter :find_meal, except: [:new, :index]

  def index

  end

  def new
    @meal = Meal.create(params)
    @meal.update_attribute(:kind, params[:id])
    redirect_to select_option_for_patients_wing_room_patient_meal_path(wing_id: @wing, room_id: @room, patient_id: @patient, id: @meal) 
  end

  def edit
    @foods = @patient.foods(@meal)
  end

  def create
    @food = Food.find(params[:food_id])
    @meal.foods << @food
    @meal.save!
    redirect_to [:edit, @wing, @room, @patient, @meal]
  end

  def destroy
    @food = find_food
    @meal.foods = @meal.foods.reject {|food| food == @food}
    @meal.save!
    redirect_to [:edit, @wing, @room, @patient, @meal] 
  end

  def place_order
    orders = @meal.orders.select {|order| order.created_at.today?}
    orders = orders.select {|order| order.kind == @meal.kind }
    unless orders.length >= 1 
      if @meal.foods.count <= 0 
        redirect_to [:edit, @wing, @room, @patient, @meal], flash: {error: "Please Add food to the Order!"}
        return
      end

      order = @meal.create_order(@meal)

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

      redirect_to [@wing, @room, @patient, :meals], flash: {notice: "Your Order for #{@meal.kind} has been placed"}
      return
    end
    redirect_to [:edit, @wing,@room, @patient, @meal], flash: {notice: "Your Order has already been placed! You are now Editing that Order!"}
  end

  def select_option_for_patients
  
  end
  
  private

  def find_meal
    meal_id = params[:meal_id].present? ? params[:meal_id] : params[:id]
    @meal = Meal.find(meal_id)
  end

  def find_food
    food_id = params[:food_id]
    @food = Food.find(food_id)
  end

  def orders_all_placed_for_today patient
    number_of_meals = []
    number_of_meals = patient.meals.select {|meal| meal.created_at.today?}
    if number_of_meals.count >= 3
      return true
    else
      return false
    end
  end

  def patients_all_placed_for_today room
    patients_orders_placed = []
    room.patients.each do |patient|
      patients_orders_placed << orders_all_placed_for_today(patient)
    end

    if patients_orders_placed.include?(false)
      return false
    else 
      return true
    end
  end

  def rooms_all_placed_for_today
    rooms_orders_placed = []
    @wing.rooms.each do |room|
      rooms_orders_placed << patients_all_placed_for_today(room)
    end

    if rooms_orders_placed.include?(false)
      return false
    else
      return true
    end
  end
end
