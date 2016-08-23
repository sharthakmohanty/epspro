module ApplicationHelper

	def is_merchant_editable?(status)
	    status = Merchant.where(:status=>status).first.status
	    if status.include?('pending') || status.include?('inactive')
	    	return true
	    else
	    	return false
	    end
  	end

  	def is_merchant_deletable?(status)
	    status = Merchant.where(:status=>status).first.status
	    if status.include?('pending')
	    	return true
	    else
	    	return false
	    end
  	end

  	def is_device_addable?(status)
	    status = Merchant.where(:status=>status).first.status
	    if status.include?('pending') || status.include?('active')
	    	return true
	    else
	    	return false
	    end
	end

	def is_invoice_addable?(status)
		status = Merchant.where(:status=>status).first.status
	    if status.include?('pending') || status.include?('active') || status.include?('inactive')
	    	return true
	    else
	    	return false
	    end
	end
	
	def is_device_editable?(status)
		status = Device.where(:device_status=>status).first.device_status
	    if status.include?('pending')
	    	return true
	    else
	    	return false
	    end
	end

	def is_device_invoice_addable?(status)
		status = Device.where(:device_status=>status).first.device_status
	    if status.include?('pending')
	    	return true
	    else
	    	return false
	    end
	end

	def is_device_deletable?(status)
		status = Device.where(:device_status=>status).first.device_status
	    if status.include?('pending')
	    	return true
	    else
	    	return false
	    end
	end

	def is_invoice_editable?(status)
		status = Invoice.where(:status=>status).first.status
	    if status.include?('pending')
	    	return true
	    else
	    	return false
	    end
	end

	def is_invoice_deletable?(status)
		status = Invoice.where(:status=>status).first.status
	    if status.include?('pending')
	    	return true
	    else
	    	return false
	    end
	end

	def get_total_amount(m)
	    total_no = 0
	    total_amt = 0
	    paid_no = 0
	    paid_amt = 0
	    cancel_no = 0
	    cancel_amt = 0
	    declined_no = 0
	    declined_amt = 0
	    pending_no = 0
	    pending_amt = 0
	    m.devices.each do |d|
		    t = d.transactions
		    total_no = t.count
		    total_amt = t.collect{|x|x.amount}.inject(:+)
		    paid_no = t.where(:transaction_status => "paid").count
		    paid_amt = t.where(:transaction_status => "paid").collect{|x|x.amount}.inject(:+)
		    cancel_no = t.where(:transaction_status => "cancelled").count
		    cancel_amt = t.where(:transaction_status => "cancelled").collect{|x|x.amount}.inject(:+)
		    declined_no = t.where(:transaction_status => "declined").count
		    declined_amt = t.where(:transaction_status => "declined").collect{|x|x.amount}.inject(:+)
		    pending_no = t.where(:transaction_status => "pending").count
		    pending_amt = t.where(:transaction_status => "pending").collect{|x|x.amount}.inject(:+)
		    return total_no,total_amt,paid_no,paid_amt,cancel_no,cancel_amt,pending_no,pending_amt 
	  	end
 
   end


end
