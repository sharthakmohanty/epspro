class Invoice
  include Mongoid::Document
  include Mongoid::History::Trackable
  include Mongoid::Timestamps::Created
  attr_accessor :description, :amount, :line_item_type

  field :invoice_number, type: String
  field :invoice_date, type: DateTime
  field :business_name, type: String
  field :address, type: String
  field :invoice_amount, type: Integer
  field :tax, type: Integer
  field :invoice_type, type: String
  field :status, type: String, :default=> "pending"
  field :paid_date, type: DateTime
  field :payment_details, type: String
  field :remarks, type: String
  field :paid_via, type: String
  field :device_id, type: String
  field :subscription_id, type: String
  field :version_comments, type: String
  field :modifier_id, type: String
  # field :state, type: String

  # New fields added 5th June -Sharthak
  #field :created_at, type: DateTime
  field :updated_at, type: DateTime

  #Validation
  validates :invoice_number, :presence=>true
  validates :invoice_date, :presence=>true
  validates :business_name, :presence=>true
  validates :address, :presence=>true
  # validates :amount, :presence=>true
  # validates :amount, :numericality=>true
  # validates :tax, :presence=>true
  # validates :tax, :numericality=>true
  # validates :invoice_type, :presence=>true


  #Relationships
  belongs_to :subscription
  has_many   :invoice_line_items, :dependent => :destroy
  belongs_to :device

  track_history   :on => [:invoice_number,:invoice_date,:business_name,:address,:invoice_amount,:tax,
    :invoice_type,:status,:paid_date,:payment_details,:remarks,
    :paid_via,:device_id,:subscription_id,:version_comments,:modifier_id],      
    :modifier_field => :modifier,
    :version_field => :version,  
    :track_create   =>  true,   
    :track_update   =>  true,    
    :track_destroy  =>  true    
  state_machine :status, initial: :pending do
    before_transition :to => :paid, :from => :pending, :do => [:invoice_fields_validation]
    before_transition :to => [:cancelled,:waived], :from => :pending, :do => [:remarks_validation]
    event :pay do
      transition :pending => :paid
    end
    event :cancel do
      transition :pending => :cancelled
    end
    event :waive do
      transition :pending => :waived
    end
    
  end

  def to_param
    invoice_number
  end

  def invoice_fields_validation
     validates_presence_of  :paid_date,:payment_details,:paid_via
  end

  def remarks_validation
    validates_presence_of  :remarks
  end
end
