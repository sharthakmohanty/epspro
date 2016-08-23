class InvoiceLineItem
  include Mongoid::Document
  include Mongoid::History::Trackable
  include Mongoid::Timestamps::Created

  field :description, type: String
  field :amount, type: Integer
  field :line_item_type, type: String
  field :invoice_id, type: String
  field :modifier_id, type: String
  # New fields added 5th June -Sharthak
  #field :created_at, type: DateTime, :default=> Time.now
  field :updated_at, type: DateTime
  
  validates :line_item_type, :presence=>true
  validates :description, :presence=>true
  validates :amount, :presence=>true

  belongs_to :invoice
   track_history   :on => [:description,:amount,:line_item_type,:invoice_id,:modifier_id],      
  :modifier_field => :modifier,
  :version_field => :version,  
  :track_create   =>  true,   
  :track_update   =>  true,   
  :track_destroy  =>  true    
end
