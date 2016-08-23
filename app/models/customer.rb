class Customer
  include Mongoid::Document
    include Mongoid::History::Trackable
  field :phone_number, type: Integer
  field :bank_codes, type: String
 
  #Relationships
  has_many :transactions, :dependent => :destroy
   track_history   :on => [:phone_number,:bank_codes,:modifier_id],   
                  :modifier_field => :modifier, 
                
                  :version_field => :version, 
                  :track_create   =>  true,   
                  :track_update   =>  true,   
                  :track_destroy  =>  true   
end
