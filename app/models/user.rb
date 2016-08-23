class User
  include Mongoid::Document
  include Mongoid::History::Trackable
  include Mongoid::Timestamps::Created
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :lockable, :recoverable,
       :rememberable, :trackable, :timeoutable, :validatable

  attr_accessor :password_confirmation
  ## Database authenticatable
  field :email, type: String
  field :encrypted_password, type: String
  field :password_salt, type: String
  field :full_name, :type => String
  field :role, :type => String
  field :disabled, :type => Boolean, :default=>false
  field :merchant_id, :type => String
  field :modifier_id, type: String
  # New fields added 5th June -Sharthak
  #field :created_at, type: DateTime, :default=> Time.now
  field :updated_at, type: DateTime

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Lockable
  field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  field :locked_at,       type: Time

  #Relationships
  belongs_to :merchant
  #has_many   :created_merchants, :class_name => "User", :foreign_key => :admin_id, :dependent => :destroy

  #Validations
  validates :full_name, :presence=>true
  validates :role, :presence=>true

 track_history   :on => [:email,:password_salt,:full_name,:role,:disabled,:merchant_id,:modifier_id],   
                  :modifier_field => :modifier, 
                  :version_field => :version,   
                  :track_create   =>  true,
                  :track_destroy  =>  true

  ROLES=%w[superadmin admin manager executive merchant]

  def self.generate_password
    return (0...8).map { ('a'..'z').to_a[rand(26)]}.join.upcase
  end

  def is_admin?
    [ROLES[0],ROLES[1]].include?(self.role)
  end

  def is_manager?
    self.role == ROLES[2]
  end

  def is_executive?
    self.role == ROLES[3]
  end

  def is_merchant?
    self.role == ROLES[4]
  end

  def not_merchant?
    [ROLES[0],ROLES[1],ROLES[2],ROLES[3]].include?(self.role)
  end

  state_machine :disabled, initial: false do
    after_transition :to => true, :from => false, :do => [:user_no_status]
    after_transition :to => false, :from => true, :do => [:user_yes_status]
    event :yes do
      transition  false=> true
    end
    event :no do
      transition true => false
    end
  end

  def user_no_status
    self.update_attribute("disabled",false)
  end

  def user_yes_status
    self.update_attribute("disabled",true)
  end

  #condition for checking user disabled
  def active_for_authentication?
    super and !self.disabled?
  end

end
