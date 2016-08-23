namespace :invoice do
  desc "create monthly invoice"
    task :send_monthly_invoices => :environment do
      invoices = []
      Subscription.where(:monthly_invoice_date => (Time.now).strftime("%d")).each do |s|
       m = s.merchant
      if m.status  == "active"
        devices =  m.devices.where(:device_status => "active")
        no_of_trsc = []
        trancst = []
        devices.each do |d|
          trsccnt = d.transactions.where(:transaction_status => "paid", :created_at => Time.now-1.month..Time.now ).count
          cost = d.transaction_cost
          no_of_trsc << trsccnt
          trancst << (cost * trsccnt)
        end
        noof_tos = no_of_trsc.inject(0){|sum,x| sum + x }
        trans_cst = trancst.inject(0){|sum,x| sum + x }
        unless devices.empty?
          dc_mnthly_cst = 0
          days_cost=[]
          no_of_days=0
          devices.collect do |i|
                  no_of_days=(Date.parse(Time.now.strftime("%d-%m-%Y"))-Date.parse(i.updated_at.strftime("%d-%m-%Y"))).to_i unless i.updated_at.nil?
               if no_of_days >= 30
                days_cost << i.monthly_cost
               else
                if no_of_days==0
                  no_of_days=1
                end
                  days_cost << ((i.monthly_cost * ((no_of_days.to_i).to_f/30.to_f))).round
               end  
        end
          dc_mnthly_cst = days_cost.inject(:+)
          subtotal = 0
          subtotal = (dc_mnthly_cst+trans_cst).round
          tax = 0
          tax = (subtotal*0.15).round
          total = 0
          total = (subtotal+tax).round
          invoices << m.merchant_uniq_id+"|"+m.first_name+"|"+m.business_name+"|"+rand.to_s[2..7].to_s+"|"+devices.count.to_s+"|"+dc_mnthly_cst.to_s+"|"+noof_tos.to_s+"|"+trans_cst.to_s+"|"+subtotal.to_s+"|"+tax.to_s+"|"+total.to_s
        end
      end
    end
    UserMailer.send_invoice_admin(invoices).deliver
  end
end

