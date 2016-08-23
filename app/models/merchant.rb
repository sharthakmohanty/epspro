class Merchant
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::History::Trackable
  include Mongoid::Timestamps::Created

  field :first_name, type: String
  field :last_name, type: String
  field :email_address, type: String
  field :phone_number, type: Integer
  field :age, type: Integer
  field :sex, type: String
  field :business_name, type: String
  field :business_type, type: String
  field :industry_type, type: String
  field :business_address, type: String
  field :is_kyc_submitted, type: Boolean, default: false
  field :address_proof_file_name, type: String
  field :address_proof_content_type, type: String
  field :address_proof_file_size, type: Integer
  field :given_address_proof, type: String
  field :id_proof_file_name, type: String
  field :id_proof_content_type, type: String
  field :id_proof_file_size, type: Integer
  field :given_id_proof, type: String
  field :alloted_devices, type: Integer, :default=>1
  field :merchant_uniq_id, type: String
  field :subscription_date, type: DateTime
  field :status, type: String, :default => "pending"

  # field :state, type: String
  # New fields added 20th May -Sharthak
  field :business_address_proof_file_name, type: String
  field :business_address_proof_content_type, type: String
  field :business_address_proof_file_size, type: Integer
  field :given_business_address_proof, type: String
  field :business_id_proof_file_name, type: String
  field :business_id_proof_content_type, type: String
  field :business_id_proof_file_size, type: Integer
  field :given_business_id_proof, type: String
  field :version_comments, type: String
  field :modifier_id, type: String

  # New fields added 5th June -Sharthak
  #field :created_at, type: DateTime, :default=> Time.now
  field :updated_at, type: DateTime

  attr_accessor :start_subscription_date

 track_history   :on => [:version_comments, :first_name,:last_name,:email_address,:phone_number,:age,:sex,:business_name,
:business_type,:industry_type,:business_address,:is_kyc_submitted,
:address_proof_file_name,:address_proof_content_type,:address_proof_file_size,
:given_address_proof,:id_proof_file_name,:id_proof_content_type,
:id_proof_file_size,:given_id_proof,:alloted_devices,:merchant_uniq_id,:status,
:business_address_proof_file_name,:business_address_proof_content_type,:business_address_proof_file_size,
:given_business_address_proof,:business_id_proof_file_name,:business_id_proof_content_type,
:business_id_proof_file_size,:given_business_id_proof,:modifier_id],     
:modifier_field => :modifier, 
:version_field => :version,  
:track_create   =>  true,   
:track_update   =>  true,
:track_destroy  =>  true 

  #Validations
  validates :first_name, :presence=>true
  validates :last_name, :presence=>true
  validates :email_address, :presence=>true
  validates :email_address, uniqueness: true
  validates_format_of :email_address,:with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  validates :phone_number, :presence=>true
  validates :phone_number, :numericality => true
  validates :phone_number, :length => { :minimum => 10, :maximum => 12 }
  validates :age, :numericality => { :greater_than_or_equal_to => 18, :less_than_or_equal_to => 99 }
  validates :sex, :presence=>true
  validates :business_name, :presence=>true
  validates :business_type, :presence=>true
  validates :industry_type, :presence=>true
  validates :business_address, :presence=>true


  #Relationships
  has_one :subscription, :dependent => :destroy
  has_many :transactions, :dependent => :destroy
  has_many :devices,:dependent => :destroy
  has_many :invoices,:dependent => :destroy

  #Generation of merchant unique code
  before_create :generate_merchant_uniq_code

  # For image upload
  has_mongoid_attached_file :address_proof
  has_mongoid_attached_file :id_proof
  has_mongoid_attached_file :business_address_proof
  has_mongoid_attached_file :business_id_proof
  validates_attachment_content_type :address_proof, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  validates_attachment_content_type :id_proof, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  validates_attachment_content_type :business_address_proof, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  validates_attachment_content_type :business_id_proof, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  

   state_machine :status, initial: :pending do
    
    before_transition :to => :active, :from => :pending, :do => [:device_status_and_presence]
      after_transition :to => :active, :from => :pending, :do => [:create_user]
      after_transition :to => [:closed,:cancelled], :from => [:active,:inactive], :do => [:device_invoice_login_status]
      after_transition :to => :inactive, :from => :active, :do => [:device_status_inactive]
    event :activate do
      transition :pending => :active
    end
    event :inactivate do
      transition :active => :inactive
    end
    event :close do
      transition :active => :closed
    end
    event :cancel do
      transition :active => :cancelled
    end
    event :activate do
      transition :inactive => :active
    end
    event :close do
      transition :inactive => :closed
    end
    event :cancel do
      transition :inactive => :cancelled
    end
 
    state :active do 
     validates_presence_of  :first_name,:last_name,:email_address,:phone_number,
    :age,:sex,:business_name,:business_type,:industry_type,
    :business_address,:is_kyc_submitted,:address_proof_file_name,
    :address_proof_content_type,:address_proof_file_size,
    :given_address_proof,:id_proof_file_name,:id_proof_content_type,
    :id_proof_file_size,:given_id_proof,:alloted_devices,
    :merchant_uniq_id,:status,:business_address_proof_file_name,
    :business_address_proof_content_type,:business_address_proof_file_size,
    :given_business_address_proof,:business_id_proof_file_name,
    :business_id_proof_content_type,:business_id_proof_file_size,
    :given_business_id_proof,:subscription_date

    #addded for activating merchant - sharthak -9th June
    validates_format_of :is_kyc_submitted, :with => /True/i
    end
  end

  def to_param
    merchant_uniq_id
  end
 
  def device_status_and_presence
    return false if(self.devices.where(:device_status=>"active").count == 0)
  end

  def create_user
    full_name=self.first_name << " " << self.last_name
    user = User.create(:email=>self.email_address,:password => User.generate_password,:merchant_id=>self.id,:role=>"merchant",:full_name=>full_name)
    UserMailer.sms_user(user).deliver
  end

  def device_status_inactive
    self.devices.where(:device_status=>"active").update_all(:device_status=>"inactive")
  end

  def device_invoice_login_status
    self.devices.where(:device_status.in=> ["active","inactive"]).all.each{|d| d.deactivate}
    self.devices.where(:device_status=>"pending").delete_all
    self.subscription.invoices.where(:status=>"pending").update_all(:status=>"cancelled")
    User.where(:merchant_id=>self.id).first.update_attributes(:disabled=>true)
  end
  
  #Generation of merchant unique code 6 digit random
  def generate_merchant_uniq_code
    self.merchant_uniq_id = rand.to_s[2..7]
    #SecureRandom.hex(4)
  end

end
