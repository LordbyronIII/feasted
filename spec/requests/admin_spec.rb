require 'spec_helper'

describe 'Wing Management' do
  before do
    visit admin_path
  end

  it 'creates wing' do
    Wing.count.should == 0

    click_link 'Floor Management'
    current_path.should == admin_wings_path
    click_link 'Add a Floor'
    current_path.should == new_admin_wing_path
    fill_in 'Name', with: 'Saint Nicholas Wing'
    click_button 'Save'
    

    Wing.count.should == 1
    Wing.first.reload
    Wing.first.name.should == 'Saint Nicholas Wing'
  end
  
  context 'with a wing' do
    before do
      @wing = FactoryGirl.create :wing, amount_of_rooms: 0
      @wing.update_rooms(10)
      @wing.reload
      @wing.update_attribute('amount_of_rooms', 10)
      @wing.reload
      @room = @wing.rooms.first
      click_link 'Floor Management'
    end

    it 'edits a wing' do
      click_link 'North'

      current_path.should == admin_wing_path(@wing)

      click_link 'Edit Name'

      current_path.should == edit_admin_wing_path(@wing)

      fill_in 'Name', with: 'Saint Nicholas Win'
      click_button 'Save'  

      @wing.reload
      @wing.name.should == 'Saint Nicholas Win'
    end

    it 'deletes a wing' do
      Wing.count.should == 1

      click_link 'North'
      current_path.should == admin_wing_path(@wing)

      click_link 'Delete'
      current_path.should == admin_wings_path

      Wing.count.should == 0
    end

    it 'updates the size of rooms in the wing' do
      click_link 'North'
      current_path.should == admin_wing_path(@wing)

      click_link 'Number of Rooms'
      current_path.should == update_room_count_admin_wing_path(@wing)
      #-within '3' do
        #-click_link 'Rooms'
      #-end
      #-@wing.reload
      #-@wing.room.count.should == 10
    end

    context 'with a rooms' do
      before do
        @room = @wing.rooms.first
      end

      it 'creates the amount of patients in a rooms' do
        visit url_for([:update_patient_count, :admin, @wing, @room])
        click_link '2 Patients'

        @room.patients.count.should == 2
        @room.patients.last.number.should == 2
      end

      it 'changes the room number' do
        visit url_for([:admin, @wing, @room])
        click_link 'Edit Room Number'
        current_url.should == url_for([:update_room_number, :admin, @wing, @room])
        click_link '403'
        #@room.reload
        #@room.number.should == 403
        #current_path.should == url_for([:admin, @wing, @room])
      end
   end

    context 'diet management' do
      before do
        visit url_for([:admin])
      end

      it 'creates a diet' do
        Diet.count.should == 0
        click_link 'Diet Management'
        current_url.should == url_for([:admin, :diets])
        click_link 'Add a Diet'
        current_url.should == url_for([:new, :admin, :diet])

        fill_in 'Name', with: 'Diabetic'
        click_button 'Save'

        Diet.count.should == 1
        Diet.first.name.should == 'Diabetic'
      end

      context 'with a diet' do
        before do 
          @diet = FactoryGirl.create :diet
          visit url_for([:admin, :diets])
        end

        it 'edits a diet' do
          click_link 'Diabetic'

          current_path.should == show_admin_diet_path(@diet)

          fill_in 'Name', with: 'Light Salt Diabetic'
          click_button 'Save'  

          @diet.reload
          @diet.name.should == 'Light Salt Diabetic'
        end

        it 'deletes a diet' do
          Diet.count.should == 1

          click_link 'Diabetic'
          current_path.should == edit_admin_diet_path(@diet)

          click_link 'Delete Diet'
          current_path.should == admin_diets_path

          Diet.count.should == 0
        end
      end
    end

    context 'food management' do
      before do
        visit url_for([:admin])
      end

      it 'creates a Food Item' do
        Food.count.should == 0
        click_link 'Food Management'
        current_url.should == url_for([:admin, :foods])
        click_link 'Add a Food'
        current_url.should == url_for([:new, :admin, :food])

        fill_in 'Name', with: 'Pizza'
        select 'Lunch', from: 'food_kind' 
        click_button 'Save'

        Food.count.should == 1
        Food.first.name.should == 'Pizza'
      end

      context 'with a Food Item' do
        before do 
          @food = FactoryGirl.create :food
          visit url_for([:admin, :foods])
        end

        it 'edits a Food Item' do
          click_link 'Pizza'

          current_path.should == edit_admin_food_path(@food)

          fill_in 'Name', with: 'Chicken Pizza'
          click_button 'Save'  

          @food.reload
          @food.name.should == 'Chicken Pizza'
        end

        it 'deletes a Food Item' do
          Food.count.should == 1

          click_link 'Pizza'
          current_path.should == edit_admin_food_path(@food)

          click_link 'Delete Food'
          current_path.should == admin_foods_path

          Food.count.should == 0
        end
      end

      context 'adding food to a Diet' do
        before do
          @food = FactoryGirl.create :food
          @diet = FactoryGirl.create :diet
          visit url_for([:edit, :admin, @diet])
        end

        it 'adds a food item to a diet' do
          click_link 'Add Food'
          current_url.should == url_for([:admin, @diet, :foods])
          click_link @food.name
          @diet.foods.count.should == 1
        end

        context 'diet with a food item' do
          before do
            @diet.foods << @food
            @diet.save!
            click_link 'Add Food'
          end

          it 'views the food items attached to the diet' do
            page.should have_content(@diet.foods.first.name)
          end
        end

        context 'adding a diet to a patient' do 
          before do
            
            @wing = FactoryGirl.create :wing, amount_of_rooms: 0
            @wing.update_rooms(10)
            @wing.reload
            @wing.update_attribute('amount_of_rooms', 10)
            @wing.reload
            @room = @wing.rooms.first
            @room.patients << FactoryGirl.create(:patient) 
            @room.reload
            @patient = @room.patients.first
            visit url_for([:admin, @wing, @room])
          end

          it 'adds a diet to a patient' do
            @patient.diets.count.should == 0
            click_link 'Patient Management'
            current_url.should == url_for([:admin, @wing, @room, :patients])
            click_link @patient.number
            current_url.should == url_for([:edit, :admin, @wing, @room, @patient])
            click_link @diet.name
            @patient.diets.count.should == 1
          end

          context 'diet with a patient' do
            before do
              @patient.diets << FactoryGirl.create(:diet)
              visit url_for([:edit, :admin, @wing, @room, @patient])
            end

            it 'views the diets' do
              page.should have_content(@patient.diets.first.name)
            end
          end
        end
      end
    end
  end
end
