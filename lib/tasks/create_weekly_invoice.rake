namespace :invoice do
	desc "create weekly invoice"
	task :send_weekly_invoices => :environment do
		Merchant.where(:status => "active").each do |m|
			UserMailer.send_weekly_invoice(m).deliver
		end
	end
end
