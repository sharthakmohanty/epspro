class Subscription
  include Mongoid::Document
  include Mongoid::History::Trackable
  include Mongoid::Timestamps::Created
  
  field :start_subscription_date, type: String
  field :monthly_invoice_date, type: String
  field :merchant_id, type: String

  # New fields added 5th June -Sharthak
  #field :created_at, type: DateTime, :default=> Time.now
  field :updated_at, type: DateTime
  
  has_many :invoices, :dependent => :destroy
  belongs_to :merchant
  track_history   :on => [:start_subscription_date,:monthly_invoice_date,:merchant_id,:modifier_id],     
                  :modifier_field => :modifier,
                
                  :version_field => :version,  
                  :track_create   =>  true,   
                  :track_update   =>  true,    
                  :track_destroy  =>  true    
end
