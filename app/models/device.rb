class Device
  include Mongoid::Document
  include Mongoid::History::Trackable
  include Mongoid::Timestamps::Created
  # StateMachines::Machine.ignore_method_conflicts = true

  field :device_serial_number, type: String
  field :sim_phone_number, type: Integer
  field :sim_msid_number, type: String
  field :device_make, type: String
  field :device_display, type: String
  field :bank_mmid, type: Integer
  field :device_status, type: String
  field :terminal_id, type: String
  field :setup_cost, type: Integer
  field :monthly_cost, type: Integer
  field :transaction_cost, type: Integer
  field :parent_id, type: String
  field :merchant_id, type: String
  field :version_comments, type: String 
  field :modifier_id, type: String
  
  # New fields added 5th June -Sharthak
  # field :created_at, type: DateTime, :default=> Time.now
  field :updated_at, type: DateTime

  # New fields added 1st July -Archana
  field :pg_merchant_id, type: String
  field :pg_key, type: String
  field :pg_salt, type: String 
  field :tablet_serial_number, type: String

  track_history   :on => [:device_serial_number, :sim_phone_number, :sim_msid_number, 
    :device_make, :device_display, :bank_mmid, :device_status, :terminal_id,
  :setup_cost,:monthly_cost, :transaction_cost, :parent_id, :merchant_id, :version_comments,:modifier_id],  
  :modifier_field => :modifier,
  :version_field  => :version,   
  :track_create   =>  :true,  
  :track_update   =>  :true,  
  :track_destroy  =>  :true    
  #Validations
  validates :device_serial_number, :presence=>true, format: { with:  /\A[a-zA-Z0-9 ]+\z/ }
  # validates :device_serial_number, uniqueness: true
  validates :sim_phone_number, :presence=>true
  validates :sim_phone_number, :numericality=>true
  validates :sim_phone_number, :length => { :minimum => 10, :maximum => 12 }
  # validates :sim_msid_number, :presence=>true
  validates :device_make, :presence=>true
  validates :device_display, :presence=>true
  # validates :bank_mmid, :presence=>true
  # validates :bank_mmid, numericality: true
  validates :setup_cost, :presence=>true
  validates :setup_cost, :numericality=>true
  validates :monthly_cost, :presence=>true
  validates :monthly_cost, :numericality=>true
  validates :transaction_cost, :presence=>true
  validates :transaction_cost, :numericality=>true

  
  #Relationships
  has_one  :invoice, :dependent => :destroy
  has_many :transactions, :dependent => :destroy
  belongs_to :merchant

   state_machine :device_status, initial: :pending do
     after_transition :to => :deactivated, :from => [:inactive,:active], :do => [:transaction_status]
     before_transition :to => :active, :from => :inactive, :do => [:merchant_status_check]
     before_transition :to => :active, :from => :pending, :do => [:device_invoice_status,:merchant_status_check]
    event :activate do
      transition :pending => :active
    end
    event :inactivate do
      transition :active => :inactive
    end
    event :deactivate do
      transition :active => :deactivated
    end
    event :activate do
      transition :inactive => :active
    end
    event :deactivate do
      transition :inactive => :deactivated
    end
  
    state :active do 
    validates_presence_of  :device_serial_number,:sim_phone_number,
    :device_make,:device_display,:bank_mmid,
    :device_status,:terminal_id,:setup_cost,:monthly_cost,
    :transaction_cost,:merchant_id
    end
  end

  def to_param
    terminal_id
  end

  def merchant_status_check
   return false if !(["pending","active"].include?(self.merchant.status))
  end

  def transaction_status
    self.transactions.where(:transaction_status=>"pending").update_all(:transaction_status=>"cancelled")
  end
  
  def device_invoice_status
    if self.parent_id.blank?
      return false if !(self.invoice && ["paid","waived"].include?(self.invoice.status))
    else
      d = Device.where(:id=>self.parent_id).first
      return false if !(d.invoice && ["paid","waived"].include?(d.invoice.status))
    end
  end

  # def device_invoice_status
  #   return false if !(self.invoice && ["paid","waived"].include?(self.invoice.status))
  #   return true if self.parent_id.blank?
  #   d = Device.where(:id=>self.parent_id).first
  #   return false if !(["inactive","deactivated"].include?(d.device_status)) 
  # end

end
