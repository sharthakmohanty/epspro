module Epsadmin::MerchantsHelper

	def check_version_field(k)
      disallow_fields = ["address_proof_file_size", "address_proof_content_type", "business_address_proof_content_type", "business_address_proof_file_size", "business_id_proof_content_type", "business_id_proof_file_size", "id_proof_content_type", "id_proof_file_size"]
      return !disallow_fields.include?(k)
	end
end
