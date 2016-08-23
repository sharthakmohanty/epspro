class UserMailer < ApplicationMailer
 
  def sms_user(user)
	  @email = user.email
	  @password = user.password
    mail(:to => user.email, :subject => "Welcome Email", :from => ADMINEMAIL) 
  end

  def welcome_admin(admin)
  	@name = admin.full_name
	  @email = admin.email
    @password = admin.password
    mail(:to => admin.email, :subject => "Welcome Email", :from => ADMINEMAIL)
  end

   def send_invoice_admin(invoice)
    @invoices = invoice
    @admin_mail = "evolutesystems4@gmail.com"
    mail(:to => @admin_mail, :subject => "Monthly Invoice", :from => ADMINEMAIL)
  end
  
  def send_weekly_invoice(merchant)
    @merchant = merchant
    mail(:to => merchant.email_address, :subject => "Weekly Report", :from => ADMINEMAIL)
  end


end
