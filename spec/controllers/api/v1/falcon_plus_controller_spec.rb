require 'rails_helper'
require 'json'
RSpec.describe Api::V1::FalconPlusController, type: :controller do
	describe "GET #validate_device" do
		before :each do
     	@device = Device.create(:name => "test123",:terminal_id => "123")
  	end
    it "responds successfully with an HTTP 200 status code" do
      get :validate_device
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "fails to execute without terminal id in header" do
      get :validate_device
      jsonobj = JSON.parse(response.body)
      expect(jsonobj["status"]).to eq("FAILED")
      expect(jsonobj["code"]).to eq("AUTHENTICATION_FAILED")
    end


    it "Fails with wrong terminal id" do
      headers={}
      headers.merge!('terminalID' => "SDFLSKDFS")
      puts headers
      get :validate_device, nil, headers
      jsonobj = JSON.parse(response.body)
      expect(jsonobj["status"]).to eq("FAILED")
      expect(jsonobj["code"]).to eq("INVALID_DEVICE")
    end

	end
	describe "POST #save_customer" do
    it "responds successfully with an HTTP 200 status code" do
      post :save_customer,
       { :customers => { :phone_number => "9967845638",:bank_codes=>"11,13,45" } } 
       expect(response.content_type) == "application/json"  
   	end
   end
end

 