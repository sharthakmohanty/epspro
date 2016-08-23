module DashboardHelper

def get_transaction_amount(st,en)
stcol = "["
trns = Transaction.collection.aggregate([{"$match"=>{"transaction_timestamp"=>{"$gt"=>Time.now-1.month,"$lt"=>Time.now},"transaction_status" => "paid", "merchant_id" => current_user.merchant.id}},{"$group"=>{"_id"=>{"year"=>{"$year"=>"$transaction_timestamp"},"month"=>{ "$month"=>"$transaction_timestamp"},"day"=>{"$dayOfMonth"=>"$transaction_timestamp"}},"total" => {"$sum" => "$amount"}}}])
trns.each_with_index do |t,i|
   stcol << (i==0 ? "[" : ",[")
   stcol << "Date.UTC(#{t["_id"]["year"]},#{((t["_id"]["month"]).to_i - 1)},#{t["_id"]["day"]}), #{t["total"]}"
   stcol << "]"
end 
stcol << "]"
end

def get_transaction_amount_total(st,en)
	amt = Transaction.where(:merchant_id => current_user.merchant.id).where(:transaction_timestamp => st..en).where(:transaction_status => "paid").sum :amount
	return amt
end

def get_transaction_count(st,en)
stcol = "["
trns = Transaction.collection.aggregate([{"$match"=>{"transaction_timestamp"=>{"$gt"=>Time.now-1.month,"$lt"=>Time.now}, "merchant_id" => current_user.merchant.id}},{"$group"=>{"_id"=>{"year"=>{"$year"=>"$transaction_timestamp"},"month"=>{ "$month"=>"$transaction_timestamp"},"day"=>{"$dayOfMonth"=>"$transaction_timestamp"}},"total" => {"$sum" => 1}}}])
trns.each_with_index do |t,i|
   stcol << (i==0 ? "[" : ",[")
   stcol << "Date.UTC(#{t["_id"]["year"]},#{((t["_id"]["month"]).to_i - 1)},#{t["_id"]["day"]}), #{t["total"]}"
   stcol << "]"
end 
stcol << "]"
end

def get_transaction_count_total(st,en)
	cnt = Transaction.where(:merchant_id => current_user.merchant.id).where(:transaction_timestamp => st..en).count
	return cnt
end

end
