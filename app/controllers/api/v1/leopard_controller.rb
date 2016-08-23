class Api::V1::LeopardController <  Api::V1::BaseController
require 'net/http'
	#GET
	def validate_device
		status = "FAILED"
		code ="UNKNOWN"
		message="Something went wrong and not able to validate the error"
		device_details={}
		begin
			if !check_browser or !device_tid_hsn
				code = "INVALID_REQUEST"
				message ="Did not find Terminal ID as part of request or user agent failed"
			else
				device= Device.where(:terminal_id=>request.headers['TerminalID']).where(:device_serial_number=>request.headers['HardwareSerial']).first
				if device.blank?
					code="DEVICE_NOT_VALID"
					message="The Device is not found"
				else
					status = "SUCCESS"
					code ="SUCCESS"
					message="SUCCESS"
					device_details={:displayName=>device.device_display,:hardwareSerial=>device.device_serial_number,:tabletSerial=>device.tablet_serial_number,:phoneNumber=>device.sim_phone_number,:msidNumber=>device.sim_msid_number,:status=>device.device_status}
				end
			end 
		rescue  StandardError => se
			logger.info se.message
		end
		response = {:status=>status,:message=>message,:code=>code,:device=>device_details}
		render :json=>response
	end 

	#POST
	def create_card_transaction
		status = "FAILED"
		code ="UNKNOWN"
		message="Something went wrong and not able to complete the request"
		transactionInfo={}
		deviceInfo={}
		begin
			if !check_browser or !device_tid
				code = "INVALID_REQUEST"
				message ="User agent Failed or TerminalID data is not found"
			else
				validdata = create_tran_msg(params)
				unless validdata.blank?
					code = "FORMAT_ERROR"
					message = validdata
				else
					device=Device.where(:terminal_id=>request.headers['TerminalID']).where(:device_status=>"active").first
					if device.blank?
						code="DEVICE_NOT_VALID"
						message="The device from which transaction is being created is not valid or in  Active status to process the transaction"
					else
						new_tran=device.transactions.create(:invoice_number=>params['invoiceNumber'],
						:amount=>params['amount'],:transaction_type=>'CARD',
						:transaction_timestamp=>params['transactionDate'],
						:transaction_status=>"pending",:merchant_id=>device.merchant_id)
						if new_tran.errors.empty?
							status = "SUCCESS"
							code ="SUCCESS"
							message="SUCCESS"
							transactionInfo={:id=> "#{new_tran.id}", :invoiceNumber=>new_tran.invoice_number,
							:amount=>new_tran.amount,:transactionType=>new_tran.transaction_type,
							:transactionTimestamp=>new_tran.transaction_timestamp,
							:paymentTimestamp=>"",:transactionDetails=>"",
							:transactionStatus=>new_tran.transaction_status} 
							deviceInfo={:pgID=>device.pg_merchant_id,:pgKey=>device.pg_key,:pgSalt=>device.pg_salt}
						else
							code = "TRANSACTION_FAILED"
							message = new_tran.errors.full_messages.join(",")
						end	
					end
				end
			end	
		rescue  StandardError => se
			logger.info se.message
		end
		response = {:status=>status,:message=>message,:code=>code,:transaction=>transactionInfo,:device=>deviceInfo}
		render :json=>response
	end 

	#POST
	def create_cash_transaction
		status = "FAILED"
		code ="UNKNOWN"
		message="Something went wrong and not able to complete the request"
		transactionInfo={}
		begin
			if !check_browser or !device_tid
				code = "INVALID_REQUEST"
				message ="Not a valid request"
			else
				validdata = create_tran_msg(params)
				unless validdata.blank?
					code = "FORMAT_ERROR"
					message = validdata
				else
					device=Device.where(:terminal_id=>request.headers['TerminalID']).where(:device_status=>"active").first
					if device.blank?
						code="DEVICE_NOT_VALID"
						message="The device from which transaction is being created is not valid or in  Active status to process the transaction"
					else
						new_tran=device.transactions.create(:invoice_number=>params['invoiceNumber'],
						:amount=>params['amount'],:transaction_type=>'CASH',
						:transaction_timestamp=>params['transactionDate'],:payment_timestamp=>params['transactionDate'],:transaction_details=>'CASH PAYMENT',
						:transaction_status=>"paid",:merchant_id=>device.merchant_id)
						status = "SUCCESS"
						code ="SUCCESS"
						message="SUCCESS"
						transactionInfo={:id=> "#{new_tran.id}", :invoiceNumber=>new_tran.invoice_number,
						:amount=>new_tran.amount,:transactionType=>new_tran.transaction_type,
						:transactionTimestamp=>new_tran.transaction_timestamp,
						:paymentTimestamp=>new_tran.payment_timestamp,:transactionDetails=>new_tran.transaction_details,
						:transactionStatus=>new_tran.transaction_status} 
					end
				end
			end	
		rescue  StandardError => se
			logger.info se.message
		end
		response = {:status=>status,:message=>message,:code=>code,:transaction=>transactionInfo}
		render :json=>response
	end 


	#GET
	def get_transaction_by_id
		status = "FAILED"
		code ="UNKNOWN"
		message="Something went wrong and not able to validate the error"
		transactionInfo={}
		begin
			if !check_browser or !device_tid
				code = "INVALID_REQUEST"
				message ="Not a valid request"
			else
				device=Device.where(:terminal_id=>request.headers['TerminalID']).where(:device_status=>"active").first
				if device.blank?
					code="DEVICE_NOT_VALID"
					message="The device from which transaction is being created is not valid or in  Active status to process the transaction"
				else
					t=Transaction.where(:id=>params['transactionId']).first
					if t.nil?
						code="TRANSACTION_NOT_FOUND"
						message="No Transaction found for given details"
					else
						status = "SUCCESS"
						code ="SUCCESS"
						message="SUCCESS"
						transactionInfo={:id=> t.id, :invoiceNumber=>t.invoice_number,
						:amount=>t.amount,:transactionType=>t.transaction_type,
						:transactionTimestamp=>t.transaction_timestamp,
						:paymentTimestamp=>t.payment_timestamp,:transactionDetails=>t.transaction_details,
						:transaction_status=>t.transaction_status} 
					end
				end
			end
		rescue  StandardError => se
			logger.info se.message
		end
		response = {:status=>status,:message=>message,:code=>code,:transaction=>transactionInfo}
		render :json=>response
	end

#POST
	def update_transaction_by_id
		status = "FAILED"
		code ="UNKNOWN"
		message="Something went wrong and not able to complete the request"
		transaction_status=["paid","cancelled","declined","timeout"]
		begin
			if !check_browser or !device_tid
				code = "INVALID_REQUEST"
				message ="Not a valid request"
			else
				device=Device.where(:terminal_id=>request.headers['TerminalID']).first
				if device.blank?
					code="DEVICE_NOT_VALID"
					message="The device from which transaction is being created is not valid to process the transaction"
				elsif !transaction_status.include?(params['status']) or !is_a_datetime?(params['paymentDate']) or !is_bool(params['forceUpdate'])
				code = "FORMAT_ERROR"
				message = "Data received in wrong format"
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
	msg << "Transaction Date" if !(is_a_datetime? val['transactionDate'])
	msg << "Invoice Number" if !(is_a_number? val['invoiceNumber'])
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
	end
	def is_bool(string)
	return true if string =~ (/(true|t|yes|y|1|false|f|no|n|0)$/i)
	return false
	end
	def check_browser
	return !(request.headers['User-Agent'].blank? or request.headers['User-Agent'] != "EPSLeopardOmni/1.0")
	end
	def device_tid
	return  !(request.headers['TerminalID'].blank? or is_a_number?(request.headers['TerminalID']))
	end 
	def device_tid_hsn
	return  !(request.headers['TerminalID'].blank? or !request.headers['HardwareSerial'].blank? or is_a_number?(request.headers['TerminalID']) or is_a_number?(request.headers['HardwareSerial']))
	end
end
