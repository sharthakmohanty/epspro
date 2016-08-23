class Api::V1::FalconPlusController < Api::V1::BaseController
	require 'net/http'

    #POST
	def send_otp
	status = "FAILED"
	code ="UNKNOWN"
	message="Something went wrong and not able to complete the request"
		begin
			unless check_browser
				code = "INVALID_REQUEST"
				message = "Not a valid request"	
			else
			 	bphone = false 
	            ph = params['phoneNumber']
	            if((is_a_number? ph) and (ph.length == 10))
	            	bphone = true
	            end
	            otpcode = false
	            code = params['otpCode']
	           	if((is_a_number? code) and (code.length == 6))
	            	otpcode = true
	            end 
				if !bphone or !otpcode 
					code = "FORMAT_ERROR"
					message = "Phone number is in wrong format" if !bphone && otpcode
					message = "OTP Code is in wrong format" if !otpcode && bphone
					message = "Phone number and OTP Code are in wrong format" if !bphone and !otpcode
				else
				 	smstext = "Your One Time EPS Registration Code is #{code}"
				 	smsurl ="http://login.redsms.in/API/SendMessage.ashx"	
				 	begin
						#uri = URI(smsurl)
						#args = { :user=>"redsms",:password=>"123",:type=>"t",:senderid=>"INFORM",:phone => "#{ph}", :text => "#{smstext}" }
						#uri.query = URI.encode_www_form(args)
						#resp = Net::HTTP.get_response(uri)
	          			if true #resp.body == "Sent"
	            			status = "SUCCESS"
							code ="SUCCESS"
							message="SUCCESS"
	          			else
	            			code="SMS_FAILED"
							message= resp.body
	          			end	
	        		rescue
	          			code="GATEWAY_ERROR"
						message="Gateway Failed to send sms"
	        		end
				end
			end	
		rescue  StandardError => se
			logger.info se.message
		end
		response = {:status=>status,:message=>message,:code=>code}
		render :json=>response
	end 

	#POST
	def save_customer
		status = "FAILED"
		code ="UNKNOWN"
		message="Something went wrong and not able to complete the request"
		customer=nil
		begin
			unless check_browser
				code = "INVALID_REQUEST"
				message = "Not a valid request"	
			else
            	bphone = false 
            	ph = params['phoneNumber']
            	if((is_a_number? ph) and (ph.length == 10))
            		bphone = true
            	end
            	bbc = false
            	bc = params['bankCodes']
            	if !bc.blank?
               		if(comma_seperated_num? bc)
               			bbc = true
               		end
            	end 
				if !bphone or !bbc 
					code = "FORMAT_ERROR"
					message = "Phone number is in wrong format" if !bphone && bbc
					message = "Bank Codes are in wrong format" if !bbc && bphone
					message = "Phone number and Bank Code are in wrong format" if !bphone and !bbc
				else
					customer = Customer.where(:phone_number=>params['phoneNumber']).first
					if customer.nil?
						customer = Customer.new
						customer.phone_number = ph
						customer.bank_codes = bc
						unless customer.save
                      		code = "SAVE_ERROR"
				      		message = customer.errors.full_messages.join(",")
				      	else
				      		status = "SUCCESS"
							code ="SUCCESS"
							message="SUCCESS"
						end
					else
						unless customer.update_attribute("bank_code",bc)
                      		code = "SAVE_ERROR"
				      		message = customer.errors.full_messages.join(",")
				      	else
				      		status = "SUCCESS"
							code ="SUCCESS"
							message="SUCCESS"
						end
					end
				end	
			end	
		rescue  StandardError => se
			logger.info se.message
		end
		response = {:status=>status,:message=>message,:code=>code,:customerID=>"#{(customer.nil? ? "" : customer.id)}"}
		render :json=>response
	end 

	#POST
	def create_transaction
		status = "FAILED"
		code ="UNKNOWN"
		message="Something went wrong and not able to complete the request"
		transactionHash={}
		deviceHash={}
		begin
			if !check_browser or !auth_user
				code = "INVALID_REQUEST"
				message ="Not a valid request"
			else
	            validdata = create_tran_msg(params)
				unless validdata.blank?
					code = "FORMAT_ERROR"
					message = validdata
				else
					device=Device.where(:terminal_id=>params['terminalID'],:device_status => "active").first
					if device.nil?  or device.merchant.status != "active"
						code="DEVICE_NOT_VALID"
						message="The device not found or not in Active status to process the transaction"				
					else
						#tpk=device.transactions.where(:transaction_status=>"pending").first
					    #if !tpk.blank?
						#  code="PENDING_TRANSACTION_FOUND"
						#  message="Previous Pending Transaction available"
					    #else 
						new_tran=device.transactions.create(:invoice_number=>params['invoiceNumber'],
							:amount=>params['amount'],:transaction_type=>'IMPS',
							:transaction_timestamp=>params['transactionDate'],
							:transaction_status=>"pending",:merchant_id=>device.merchant_id,
							:customer_id=>request.headers['AUTHTOKEN'])
						if new_tran.errors.empty?
							status = "SUCCESS"
							code ="SUCCESS"
							message="SUCCESS"
							transactionHash={:id=> "#{new_tran.id}", :invoiceNumber=>new_tran.invoice_number,
								:amount=>new_tran.amount,:transactionType=>new_tran.transaction_type,
								:transactionTimestamp=>new_tran.transaction_timestamp,
								:paymentTimestamp=>"",:transactionDetails=>"",
								:transactionStatus=>new_tran.transaction_status} 
							deviceHash={:terminalID=>device.terminal_id, :displayName=>device.device_display,
							 :mmid=>device.bank_mmid,:phoneNumber=>device.sim_phone_number}
						else
							code = "TRANSACTION_FAILED"
							message = new_tran.errors.full_messages.join(",")
						end	
						#end
					end
				end
			end	
		rescue  StandardError => se
			logger.info se.message
		end
		response = {:status=>status,:message=>message,:code=>code,:transaction=>transactionHash,:device=>deviceHash}
		render :json=>response
	end 


	#GET
	def get_transaction_by_id
		status = "FAILED"
		code ="UNKNOWN"
		message="Something went wrong and not able to validate the error"
		transactionHash={}
		deviceHash={}
		begin
			if !check_browser or !auth_user
				code = "INVALID_REQUEST"
				message ="Not a valid request"
			else
				t=Transaction.where(:id=>params['transactionId']).first
				if t.nil?
					code="TRANSACTION_NOT_FOUND"
					message="No Transaction Found"
				else
					d=t.device
					status = "SUCCESS"
					code ="SUCCESS"
					message="SUCCESS"
					transactionHash={:id=> t.id, :invoiceNumber=>t.invoice_number,
						:amount=>t.amount,:transactionType=>t.transaction_type,
						:transactionTimestamp=>t.transaction_timestamp,
						:paymentTimestamp=>t.payment_timestamp,:transactionDetails=>t,
						:transaction_status=>t.transaction_status} 
					deviceHash={:terminalID=>d.terminal_id, :displayName=>d.device_display,
						:mmid=>d.bank_mmid,:phoneNumber=>d.sim_phone_number}
				end
			end
		rescue  StandardError => se
			logger.info se.message
		end
		response = {:status=>status,:message=>message,:code=>code,:transaction=>transactionHash,:device=>deviceHash}
		render :json=>response
	end


	#POST
	def update_transaction_by_id
		status = "FAILED"
		code ="UNKNOWN"
		message="Something went wrong and not able to complete the request"
		transaction_status=["paid","cancelled","declined","timeout"]
		begin
			if !check_browser or !auth_user
				code = "INVALID_REQUEST"
				message ="Not a valid request"
			elsif !transaction_status.include?(params['status']) or !is_a_datetime?(params['paymentDate']) or !is_bool(params['forceUpdate'])
				code = "FORMAT_ERROR"
				message = "Status is invalid"
			else
				transaction=Transaction.where(:id=>params['transactionID']).first
				if transaction.nil?
					code="TRANSACTION_NOT_FOUND"
					message="No Transaction found"
				elsif !["pending","timeout"].include?(transaction.transaction_status) and params['forceUpdate'] == "false"
					code="TRANSACTION_NOT_PENDING"
					message="Transaction not in pending status to update"
				elsif !["pending","timeout"].include?(transaction.transaction_status) and params['forceUpdate'] == "true"
					if transaction.transaction_status != 'paid'
						if params['status'] == 'paid'
							transaction.payment_timestamp = params['paymentDate']
							transaction.transaction_details= params['details']
						end
						transaction.transaction_status = params['status']
						if transaction.save
							status = "SUCCESS"
							code ="SUCCESS"
							message="SUCCESS"
						else
							code="TRANSACTION_UPDATE_FAILED"
							message = "Transaction update Not allowed"
						end
					end
				else
					bstatus = true
					case params['status']
					when "paid"
						transaction.payment_timestamp = params['paymentDate']
						transaction.transaction_details= params['details']
						bstatus = transaction.pay
					when "cancelled"
						bstatus = transaction.cancel
					when "declined"
						bstatus = transaction.decline
					when "timeout"
						bstatus = transaction.timedout
					else 
						bstatus = false
					end
					if bstatus
						status = "SUCCESS"
						code ="SUCCESS"
						message="SUCCESS"
					else
						code="TRANSACTION_UPDATE_FAILED"
						message = "Transaction update Not allowed"
					end
				end
			end		
		rescue  StandardError => se
			logger.info se.message
		end
		response = {:status=>status,:message=>message,:code=>code}
		render :json=>response
	end

	
	private
	
	def create_tran_msg val
		msg=Array.new
        msg << "Amount" if !(is_a_number? val['amount'])
        msg << "Invoice Number" if !(is_a_number? val['invoiceNumber'])
        msg << "Transaction Date" if !(is_a_datetime? val['transactionDate'])
        msg << "Device Info" if !(is_a_number? val['terminalID'])
        if msg.size == 0
        	return ""
        elsif msg.size == 1
          return "#{msg} is in wrong format"
        else 
          return "#{msg.join(",")} are in wrong format"
        end 
	end
	def is_a_number?(s)
	  s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
	end
	def is_a_datetime?(s)
		s.to_s.match(/(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2})/) == nil ? false : true 
		# s.to_s.match(/^\d{1,2}\/\d{1,2}\/\d{4} \d{1,2}:\d{1,2}:\d{1,2} [AaPp][Mm]\z/) == nil ? false : true 
	end
	def comma_seperated_num?(s)
	s.split(',').all? {|val|  val =~ /\A-?\d+(\.\d+)?\Z/}
	end
	def is_bool(string)
		return true if string =~ (/(true|t|yes|y|1|false|f|no|n|0)$/i)
		return false
  	end
	def check_browser
		return !(request.headers['User-Agent'].blank? or request.headers['User-Agent'] != "EPSFalconPlus/1.0")
	end
	def auth_user
		return  !(request.headers['AUTHTOKEN'].blank? or Customer.where(:id=>request.headers['AUTHTOKEN']).first.nil?)
	end 
end
	
	
	
