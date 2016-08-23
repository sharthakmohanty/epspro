require 'rails_helper'

RSpec.describe DashboardController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #transaction" do
    it "returns http success" do
      get :transaction
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #billing" do
    it "returns http success" do
      get :billing
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #billing_individual" do
    it "returns http success" do
      get :billing_individual
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #merchant_detail" do
    it "returns http success" do
      get :merchant_detail
      expect(response).to have_http_status(:success)
    end
  end

end
