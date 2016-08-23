class Api::V1::BaseController < ActionController::Base
	#GET
	def validate_device
		puts request.headers.inspect
		status = "FAILED"
		code ="UNKNOWN"
		message="Something went wrong and not able to validate the error"
		begin
			tid = request.headers['terminalId']
			if tid.blank?
				code="AUTHENTICATION_FAILED"
				message="Did not find Terminal ID as part of request"
			else
				device=Device.where(:terminal_id=>tid).first
				error_codes = {"invalid_device"=>"The device is not found", "pending"=>"Device is not yet activated","inactive"=>"The device is in in-active state","deactivated"=>"The device has been deactivated"}
				if device.blank?
					code="INVALID_DEVICE"
					message=error_codes["invalid_device"]
				elsif device.device_status != "active"
					code=device.device_status.upcase
					message=error_codes[device.device_status.downcase]
				else
					status = "SUCCESS"
					code ="SUCCESS"
					message="SUCCESS"
				end
			end  
		rescue  StandardError => se
			logger.info se.message
		end
		response = {:status=>status,:message=>message,:code=>code}
		render :json=>response
	end 
	#GET
	def pending_transaction_by_code
		status = "FAILED"
		code ="UNKNOWN"
		message="Something went wrong and not able to validate the error"
		transaction={}
		begin
		transaction=Transaction.where(:pairing_token=>request.headers['pairingToken'],:transaction_status=>"pending").first
		tid = nil
		tid = transaction.device unless transaction.blank?
		status,code,message,transaction	=pending_transaction_details(transaction,tid)
		rescue  StandardError => se
			logger.info se.message
		end
		response = {:status=>status,:message=>message,:code=>code,:transaction=>transaction}
		render :json=>response
	end 

	#GET
	def pending_transaction_by_terminal_id
		status = "FAILED"
		code ="UNKNOWN"
		message="Something went wrong and not able to validate the error"
		transaction={}
		begin
		device=Device.where(:terminal_id=>request.headers['terminalId']).first
		transaction = nil
		transaction = device.transactions.where(:status=>"pending").first unless device.nil?
		status,code,message,transaction	=pending_transaction_details(transaction,device)
		rescue  StandardError => se
			logger.info se.message
		end
		response = {:status=>status,:message=>message,:code=>code,:transaction=>transaction}
		render :json=>response
	end

	#GET
	def pending_transaction_by_id
		code ="UNKNOWN"
		message="Something went wrong and not able to validate the error"
		transaction={}
		begin
		transaction=Transaction.where(:id=>request.headers['transactionId'],:transaction_status=>"pending").first
		tid = nil
		tid = transaction.device unless transaction.blank?
		status,code,message,transaction	=pending_transaction_details(transaction,tid)
		rescue  StandardError => se
			logger.info se.message
		end
		response = {:status=>status,:message=>message,:code=>code,:transaction=>transaction}
		render :json=>response
	end
	#GET
	def get_transaction_status
		status = "FAILED"
		code ="UNKNOWN"
		message="Something went wrong and not able to validate the error"
		transaction_status=""
		statuses=["pending","paid","cancelled","declined"]
		begin
			transaction=Transaction.where(:id=>request.headers['transactionId'],:transaction_status=>statuses)
			if transaction.blank?
				code="TRANSACTION_NOT_FOUND"
				message="Transaction not found"
			else
				status = "SUCCESS"
				code ="SUCCESS"
				message="SUCCESS"
				transaction_status = transaction.status
			end
		rescue  StandardError => se
			logger.info se.message
		end
		response = {:status=>status,:message=>message,:code=>code,:transactionstatus=>transaction_status}
		render :json=>response
	end
#POST
	def update_transaction_by_terminal_id
		status = "FAILED"
		code ="UNKNOWN"
		message="Something went wrong and not able to complete the request"
		transaction_status=["paid","cancelled","declined"]
		begin
			if !transaction_status.include? params['status']
				code = "FORMAT_ERROR"
				message = "Status is invalid status"
			else	
				device=Device.where(:terminal_id=>request.headers['terminalId']).first
				if device.blank?
					code ="DEVICE_NOT_FOUND"
					qmessage="device not found for the given transcation"
				else
					transaction=device.transactions.where(:status=>"pending").first
					if transaction.blank?
						code="TRANSACTION_NOT_PENDING"
						message="Requested transaction is not in Waiting state"
					else
						transaction.update_attributes(:transaction_status => params['status'])
						status = "SUCCESS"
						code ="SUCCESS"
						message="SUCCESS"
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

	def pending_transaction_details(transaction,tid)
		status = "FAILED"
		transaction={}
			if transaction.blank?
				code="TRANSACTION_NOT_FOUND"
				message="Transaction associated to the DTMF code is not found"
			elsif tid.blank? || tid.status != "active"
				code="DEVICE_NOT_VALID"
				message="Device not valid to process"
			elsif transaction.transaction_status != "pending"
				code="TRANSACTION_NOT_PENDING"
				message="Requested transaction is not in Waiting state"
			else
				status = "SUCCESS"
				code ="SUCCESS"
				message="SUCCESS"
				transaction={:id=> transaction.id, :terminalId=>tid.terminal_id, :invoiceAmount=>transaction.amount, :displayName=>tid.device_display,:mmid=>tid.bank_mmid,:phoneNumber=>tid.sim_phone_number} 
			end
		return status,code,message,transaction	 
	end
end
