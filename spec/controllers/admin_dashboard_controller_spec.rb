require 'rails_helper'

RSpec.describe AdminDashboardController, type: :controller do

  describe "GET #all_device" do
    it "returns http success" do
      get :all_device
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #all_invoice" do
    it "returns http success" do
      get :all_invoice
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #individual_device" do
    it "returns http success" do
      get :individual_device
      expect(response).to have_http_status(:success)
    end
  end

end
