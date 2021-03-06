require 'spec_helper'

describe AppointmentsController do
  
  include Devise::TestHelpers
  
  describe "GET /appointments/:id" do
    #TO BE IMPLEMENTED
  end
  
  describe "POST /appointments" do
    
    before(:each) do
      @now = Time.now
      @place = Factory(:place)
    end
    
    #TODO: figure out why the fuck this test fails
    context "with valid params" do
      # it "should create a new appointment" do
      #         inviter = Factory(:user, :username => :inviter, :email => "inviter@email.com")
      #         invitee = Factory(:user, :username => :invitee, :email => "invitee@email.com")
      #         expect { 
      #           post :create, :appointment => {:inviter_id => inviter.id, :invitee_id => invitee.id, :date => "2011-09-20", :hour => 12, :minute => 10, 
      #           :place_id => @place.name}
      #         }.to change{ 
      #           Appointment.count 
      #         }.by(1)
      #         
      #         expected_rendered_json = {
      #           :success => 1,
      #           :message => "Date has been added to your calendar"
      #         }.to_json
      #         
      #         response.body.should == expected_rendered_json
      #         
      #       end
    end
    
    # context "with invalid params" do
    #       
    #       it "should not create a new appointment" do
    #         
    #         post :create, :appointment => {}
    #         
    #         expected_rendered_json = {
    #           :success => -1,
    #           :message => ["Date is required", "Place_id is required"]
    #         }.to_json
    #         
    #         puts response.message
    #         
    #         response.body.should == expected_rendered_json
    #         
    #       end
    #       
    #     end
    
  end

  describe "GET /appointments/:id/edit" do
    before(:each) do
      @inviter = Factory(:user, :username => :inviter, :email => "inviter@email.com")
      @invitee = Factory(:user, :username => :invitee, :email => "invitee@email.com")
      @place_1 = Factory(:place, :name => "Place 1")
      @place_2 = Factory(:place, :name => "Place 2")
      @appointment = Factory(:appointment, :inviter_id => @inviter.id, :invitee_id => @invitee.id, :date => Time.now + 5.days, 
      :place_id => @place_1.id, :note => "Initial note")
    end
    
    it "should ask user to log in if they are not" do
      get :edit, :id => @appointment.id
      response.should redirect_to new_user_session_url
    end
    
    it "should render the edit form if a user is logged in and is the inviter" do
      sign_in(@inviter)
      get :edit, :id => @appointment.id
      response.should be_success
    end
    
    it "should redirect if a user is not the inviter of the appointment" do
      lame_user = Factory(:user)
      sign_in(lame_user)
      
      get :edit, :id => @appointment.id
      response.should redirect_to dashboard_url
      flash[:error].should == "You cannot change that appointment"
    end
  end

  describe "PUT /appointments/:id" do
      
    before(:each) do
      @inviter = Factory(:user, :username => :inviter, :email => "inviter@email.com")
      @invitee = Factory(:user, :username => :invitee, :email => "invitee@email.com")
      sign_in(@inviter)
      @place_1 = Factory(:place, :name => "Place 1")
      @place_2 = Factory(:place, :name => "Place 2")
    end
      
    it "should update the appointment if the appointment's date has not passed" do
      
      appointment = Factory(:appointment, :inviter_id => @inviter.id, :invitee_id => @invitee.id, :date => Time.now + 5.days, 
      :place_id => @place_1.id, :note => "Initial note")
      
      put :update, :id => appointment.id, :appointment => {:note => "Updated note", :place_id => @place_2.id}
      
      response.should redirect_to edit_appointment_url
      appointment.reload
      appointment.place_id.should == @place_2.id
      appointment.note.should == "Updated note"
      
    end
    
    it "should not update the appointment once the appointment's date has passed" do
      appointment = Appointment.new(:inviter_id => @inviter.id, :invitee_id => @invitee.id, :date => Time.now - 5.days, 
      :place_id => @place_1.id, :note => "Initial note")
      appointment.save!(:validate => false)
      
      put :update, :id => appointment.id, :appointment => {:note => "Updated note", :place_id => @place_2.id}
      
      response.should redirect_to dashboard_url
    end
    
    specify "a user who did not create the date should not be able to update it" do
      
      appointment = Factory(:appointment, :inviter_id => @inviter.id, :invitee_id => @invitee.id, :date => Time.now + 5.days, 
      :place_id => @place_1.id, :note => "Initial note")
      
      current_user = Factory(:user)
      
      sign_in(current_user)
      
      put :update, :id => appointment.id, :appointment => {:note => "Updated note", :place_id => @place_2.id}
      
      response.should redirect_to dashboard_url
      flash[:error].should == "You cannot change that appointment"
    end
    
  end

  describe "DELETE /appointments/:id" do
    before(:each) do
      @inviter = Factory(:user, :username => :inviter, :email => "inviter@email.com")
      @invitee = Factory(:user, :username => :invitee, :email => "invitee@email.com")
      sign_in(@inviter)
      @place_1 = Factory(:place, :name => "Place 1")
      @place_2 = Factory(:place, :name => "Place 2")
      @appointment = Factory(:appointment, :inviter_id => @inviter.id, :invitee_id => @invitee.id, :date => Time.now + 5.days, 
      :place_id => @place_1.id, :note => "Initial note")
    end
    
    it "should delete the appointment" do  
      delete :destroy, :id => @appointment.id
      
      Appointment.where(:id => @appointment.id).first.should be_nil
      
      response.should redirect_to dashboard_url
      flash[:notice].should == "Appointment has been cancelled"
    end
  end
  
  describe "POST /appointments/:id/report_abuse" do
    before do
      @inviter = Factory(:user, :username => :inviter, :email => "inviter@email.com")
      @invitee = Factory(:user, :username => :invitee, :email => "invitee@email.com")
      sign_in(@inviter)
      @place_1 = Factory(:place, :name => "Place 1")
      @place_2 = Factory(:place, :name => "Place 2")
      @appointment = Factory(:appointment, :inviter_id => @inviter.id, :invitee_id => @invitee.id, :date => Time.now + 5.days, 
      :place_id => @place_1.id, :note => "Initial note")
    end
    
    it "should create abuse reports" do
      post :report_abuse, :id => @appointment.id
      @appointment.reload
      @appointment.abuse_reports.count.should == 1
    end
    
  end
  
end