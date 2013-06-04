class Wing
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :amount_of_rooms, type: Integer, default: 0

  has_many :rooms

  def instantiate_rooms
    if self.rooms.count != amount_of_rooms && self.rooms.count == 0
      amount_of_rooms.times do |index|
        self.rooms.create(number: index + 1)
      end
    end 
  end

  def update_rooms(new_amount_of_rooms)
    if rooms.count < new_amount_of_rooms
      add_rooms(new_amount_of_rooms - rooms.count)
    elsif new_amount_of_rooms < rooms.count
      destroy_rooms(rooms.count - new_amount_of_rooms)
    end

    return 'sucessfully updated'
  end

  def add_rooms(number_of_rooms_to_add)
    number_of_rooms_to_add.times do |index|
      self.rooms.create(number: index + 1)
      self.save!
    end
  end

  def destroy_rooms(number_of_rooms_to_destroy)
    number_of_rooms_to_destroy.times do |index|
      self.rooms.last.destroy
      self.save
    end
  end

  def color
    rooms_color = []
    rooms.each do |room|
      rooms_color << room.color
    end

    if rooms_color.include?("redDark")
      return "redDark"
    else
      return "green"
    end
  end
end
