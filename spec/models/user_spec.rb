require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before(:each) do
    empty_database
    @user = User.new(valid_user_attributes)
  end
  
  it "should be valid when new" do
    @user.should be_valid
  end
  
  it "should be invalid when cell is empty" do
    @user.cell = ""
    @user.should_not be_valid
  end
  
  it "should be invalid when provider is empty" do
    @user.provider = ""
    @user.should_not be_valid
  end
  
  it "should have a unique 5551239876@provider.com" do
    # save the user
    @user.save!
    # try to create a not unique user
    @user2 = User.new(valid_second_user_attributes)
    @user2.cell = @user.cell
    @user2.provider = @user.provider
    @user2.save
    @user2.should_not be_valid
    # @user2.errors.on(:cell).to_s.should include("Cell is already taken")
  end
  
  it "should be valid if number is not unique but provider is" do
    # save the user
    @user.save
    @user.should be_valid
    # try to create a not unique user
    @user2 = User.new(valid_second_user_attributes)
    @user2.cell = @user.cell
    @user2.should be_valid
  end
  
  it "should have a cell # with length of exactly 10 when with_cell" do
    @user.cell = "123456789"
    @user.valid?.should eql(false)
    @user.cell = "12345678912"
    @user.valid?.should eql(false)
  end
  
  it "should have a cell # with only digits" do
    @user.cell = "123456789-"
    @user.valid?.should eql(false)
  end
  
  it "should strip numbers like 951-657-4222 & 951.657.4222 to 9516574222" do
    @user.cell = "951-657-4222"
    input_cell = @user.cell
    @user.save
    @user.cell.should_not eql(input_cell)
  end
  
  it "should not be active after initial save" do
    @user.active?.should eql(false)
    @user.save
    @user.active?.should eql(false)
  end
  
  it "should be active after activated" do
    pending # something seems wrong here. shouldn't it be 'true'?
    @user.activate!
    @user.reload
    puts @user.inspect
    @user.reload.active?.should == true
    # @user.active?.should eql(true)
  end
  
  it "should match activate? with whether activation_code is empty or not" do
    # inactive user
    @user.active?.should eql(false) if @user.activation_code != nil
    # active_user
    @user.activate!
    @user.active?.should eql(true) if @user.activation_code == nil
  end
  
  it "should not have an empty activation_code after saving" do
    @user.activation_code = ""
    @user.save
    @user.activation_code.should_not eql("")
  end
  
  it "should list only activated users when using 'activated' scope" do
    User.where(:activation_code => nil).count.should eql(User.active.count)
    User.all.count.should_not eql(User.active.count) unless User.where(:activation_code => nil).count == User.all.count
  end
  
  it "should not have an empty private_url" do
    @user.private_url = ""
    @user.save!
    @user.private_url.should_not == ""
  end
  
  it "should be able to change the private_url to something simpler" do
    @user.save
    @user.private_url = 'daveisreallyawesome'
    @user.should be_valid
    @user.private_url.should eql('daveisreallyawesome')
  end
  
  it "should have a unique private_url" do
    @user.save
    @user2 = User.new(valid_second_user_attributes)
    @user2.should be_valid
    @user2.save
    # update attributes first user
    @user.private_url = 'daveisreallyawesome'
    @user.should be_valid
    @user.save!
    # update attributes second user
    @user2.private_url = 'daveisreallyawesome'
    @user2.should_not be_valid
  end
end

