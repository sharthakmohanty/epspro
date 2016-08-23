class Transaction
  include Mongoid::Document
  include Mongoid::History::Trackable
  include Mongoid::Timestamps::Created

  field :invoice_number, type: Integer
  field :amount, type: Integer
  field :transaction_type, type: String
  field :transaction_timestamp, type: DateTime
  field :payment_timestamp, type: DateTime
  field :transaction_details, type: String
  field :transaction_status, type: String
  field :device_id, type: String
  field :merchant_id, type: String
  field :customer_id, type: String
  # field :state, type: String
  field :modifier_id, type: String 
  
  # New fields added 5th June -Sharthak
  #field :created_at, type: DateTime, :default=> Time.now
  field :updated_at, type: DateTime

  belongs_to :device
  belongs_to :merchant
  belongs_to :customer

  track_history   :on => [:invoice_number,:amount,:transaction_type,:transaction_timestamp,:payment_timestamp,:transaction_details,:transaction_status,:device_id,:merchant_id,:customer_id,:modifier_id],     
                  :modifier_field => :modifier,
                  :version_field => :version,  
                  :track_create   =>  true,   
                  :track_update   =>  true,    
                  :track_destroy  =>  true 

  state_machine :transaction_status, initial: :pending do
    before_transition :to => :paid, :from => [:pending,:timeout], :do => [:transaction_field_validation]
    event :pay do
      transition :pending => :paid
    end
    event :cancel do
      transition :pending => :cancelled
    end
    event :decline do
      transition :pending => :declined
    end
    event :timedout do
      transition :pending => :timeout
    end
    event :pay do
      transition :timeout => :paid
    end
    event :cancel do
      transition :timeout => :cancelled
    end
  end
  
  def transaction_field_validation
    validates_presence_of  :transaction_details,:payment_timestamp
  end

end
