Rails.application.routes.draw do

  get 'frontend/index'

  root 'home#index'
  devise_for :users, :controllers => { :registrations => "users/registrations"}

  namespace :epsadmin do 
    resources :merchants, param: :merchant_uniq_id do
      #post '/merchant_status' => "merchants#merchant_status_check"
      get '/download_pdf' => "merchants#download_pdf"
      get '/transaction' => "merchants#transaction",:as => :transaction
      get '/transaction_status' => "merchants#transaction_status_check"
      get '/transaction_range' => "merchants#transaction_range"
      get '/transaction/details/:id' => "merchants#transaction_show",:as => :transaction_details
      get '/device_pdf' => "devices#device_pdf", :as => :device_pdf
      get '/transaction_pdf' => "merchants#transaction_pdf", :as => :transaction_pdf
      resources :invoices, param: :invoice_number
        get '/invoice_pdf' => "invoices#invoice_pdf", :as => :invoice_pdf
        get '/invoice_status' => "invoices#invoice_status_check"
        get '/invoices/:invoice_number/invoice_print'=>"invoices#invoice_print",:as => :print_invoice
        resources :devices, param: :terminal_id do 
          get '/device_status' => "devices#device_status_check"
        end
    end
    post 'merchants/merchant_status_check' => "merchants#merchant_status_check"
    post 'devices/autocreate_invoice' => 'devices#autocreate_invoice'
    post 'admins/update_user_status' => 'admins#update_user_status'
    resources :admins
  end


  get 'admin_dashboard/all_device'
  get 'admin_dashboard/all_invoice'
  get 'admin_dashboard/individual_device/:terminal_id' => "admin_dashboard#individual_device",:as => :individual_device, via: [:get,:post]
  get 'admin_dashboard/all_device_pdf' => "admin_dashboard#all_device_pdf", :as => :all_device_pdf
  get 'admin_dashboard/all_invoice_pdf' => "admin_dashboard#all_invoice_pdf", :as => :all_invoice_pdf

  get 'dashboard/transaction_range'
  get 'dashboard/index'
  get 'dashboard/transaction'
  get 'dashboard/billing'
  get '/dashboard/billing_individual/:invoice_number' => 'dashboard#billing_individual', :as => :dashboard_billing_individual 
  get 'dashboard/merchant_detail'
  post '/dashboard/update_transaction' => 'dashboard#update_transaction'
  get '/dashboard/transaction_cancel/:id' => 'dashboard#transaction_cancel', :as => :dashboard_transaction_cancel


  ##API RELATED ROUTES
  namespace :api do
    namespace :v1 do
      post "/falconplus/send_otp"=>"falcon_plus#send_otp"
      post "/falconplus/save_customer"=>"falcon_plus#save_customer"
      post "/falconplus/create_transaction"=>"falcon_plus#create_transaction"
      get "/falconplus/get_transaction_by_id"=>"falcon_plus#get_transaction_by_id"
      post "/falconplus/update_transaction_by_id"=>"falcon_plus#update_transaction_by_id"
      get "/leopard/validate_device" => "leopard#validate_device"
      post "/leopard/create_card_transaction" => "leopard#create_card_transaction"
      post "/leopard/create_cash_transaction" => "leopard#create_cash_transaction"
      get "/leopard/get_transaction_by_id" => "leopard#get_transaction_by_id"
      post "/leopard/update_transaction_by_id" => "leopard#update_transaction_by_id"
      #get "/falconplus/pending_transaction_by_code"=>"falcon_plus#pending_transaction_by_code"
      #get "/falconplus/pending_transaction_by_terminal_id"=>"falcon_plus#pending_transaction_by_terminal_id"
      #get "/falconplus/pending_transaction_by_id"=>"falcon_plus#pending_transaction_by_id"
      
     # match "/falconplus/update_transaction_by_terminal_id"=>"falcon_plus#update_transaction_by_terminal_id", via: [:put,:post]
    end
  end
end
