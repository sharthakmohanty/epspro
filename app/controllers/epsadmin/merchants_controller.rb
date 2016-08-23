class Epsadmin::MerchantsController < ApplicationController
  # GET /merchants
  # GET /merchants.json
  before_action :get_merchant, :get_device, :get_transc_merchant
  before_filter :check_not_merchant
  skip_before_filter :check_not_merchant, :only => [:transaction_status_check]
  

  def index
    add_breadcrumb "Merchants Management", epsadmin_merchants_path
    @epsadmin_merchants = Merchant.all.order("created_at DESC")
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @epsadmin_merchants }
    end
  end

  # GET /merchants/1
  # GET /merchants/1.json
  def show
    @epsadmin_merchant = Merchant.where(:merchant_uniq_id => params[:merchant_uniq_id]).first
    @history_records = Merchant.where(:id => @merchant.id).first.history_tracks
    add_breadcrumb "Merchants", epsadmin_merchants_path
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @epsadmin_merchant }
    end
  end

  # GET /merchants/new
  # GET /merchants/new.json
  def new
    add_breadcrumb "Merchants", epsadmin_merchants_path
    @epsadmin_merchant = Merchant.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @epsadmin_merchant }
    end
  end

  # GET /merchants/1/edit
  def edit
    @epsadmin_merchant = Merchant.where(:merchant_uniq_id => params[:merchant_uniq_id]).first
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@epsadmin_merchant.first_name}", epsadmin_merchant_path
  end

  # POST /merchants
  # POST /merchants.json
  def create
    @monthly_date = params[:start_subscription_date].split("/")
    add_breadcrumb "Merchants", epsadmin_merchants_path
    @epsadmin_merchant = Merchant.new(merchant_params)
    @epsadmin_merchant.modifier_id = current_user.id
    @epsadmin_merchant.subscription_date = params[:start_subscription_date]
    if params[:merchant][:is_kyc_submitted] == "1"
      if !(User.all.map(&:email).include?(params[:merchant][:email_address]))
      if !params[:merchant][:address_proof].blank? && !params[:merchant][:given_address_proof].blank? && !params[:merchant][:id_proof].blank? && !params[:merchant][:given_id_proof].blank? && !params[:merchant][:business_id_proof].blank? && !params[:merchant][:given_business_id_proof].blank? && !params[:merchant][:business_address_proof].blank? && !params[:merchant][:given_business_address_proof].blank?
        respond_to do |format|
          if @epsadmin_merchant.save
            @subscription = Subscription.new(:start_subscription_date => params[:start_subscription_date],:monthly_invoice_date => @monthly_date[1], :merchant_id =>  @epsadmin_merchant.id )
            @subscription.save if @subscription
            create_user(params[:merchant][:status],@epsadmin_merchant)
            format.html { redirect_to epsadmin_merchants_path, notice: 'Merchant was successfully created.' }
            format.json { render json: @epsadmin_merchant, status: :created, location: @epsadmin_merchant }
          else
            format.html { render action: "new" }
            format.json { render json: @epsadmin_merchant.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          format.html { render action: "new" }
          @epsadmin_merchant.errors.add(:is_kyc_submitted, 'must be unchecked due to some documents not uploaded/seleted')
        end
      end
    else
      respond_to do |format|
          format.html { render action: "new" }
          @epsadmin_merchant.errors.add(:email_address, 'is already exist')
        end
      end
    else
       if !(User.all.map(&:email).include?(params[:merchant][:email_address]))
      respond_to do |format|
        if @epsadmin_merchant.save
          @subscription = Subscription.new(:start_subscription_date => params[:start_subscription_date] ,:monthly_invoice_date => @monthly_date[1], :merchant_id =>  @epsadmin_merchant.id )
          @subscription.save if @subscription
          create_user(params[:merchant][:status],@epsadmin_merchant)
          format.html { redirect_to epsadmin_merchants_path, notice: 'Merchant was successfully created.' }
          format.json { render json: @epsadmin_merchant, status: :created, location: @epsadmin_merchant }
        else
          format.html { render action: "new" }
          format.json { render json: @epsadmin_merchant.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
          format.html { render action: "new" }
          @epsadmin_merchant.errors.add(:email_address, 'is already exist')
        end
      end
    end
  end

  # PUT /merchants/1
  # PUT /merchants/1.json
  def update
    @monthly_date = params[:start_subscription_date].split("/")
    @epsadmin_merchant = Merchant.where(:merchant_uniq_id => params[:merchant_uniq_id]).first
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@epsadmin_merchant.first_name}", epsadmin_merchant_path
    if params[:merchant][:is_kyc_submitted] == "1"    
      if (!params[:merchant][:address_proof].blank? || !@epsadmin_merchant.address_proof.blank?) && !params[:merchant][:given_address_proof].blank? && (!params[:merchant][:id_proof].blank? || !@epsadmin_merchant.id_proof.blank?) && !params[:merchant][:given_id_proof].blank? && (!params[:merchant][:business_id_proof].blank? || !@epsadmin_merchant.business_id_proof.blank?) && !params[:merchant][:given_business_id_proof].blank? && (!params[:merchant][:business_address_proof].blank? || !@epsadmin_merchant.business_address_proof.blank?) && !params[:merchant][:given_business_address_proof].blank?
        respond_to do |format|
          if !params[:version_comments].blank?
              @epsadmin_merchant[:version_comments] = params[:version_comments]
              @epsadmin_merchant[:modifier_id] = current_user.id
            if @epsadmin_merchant.update_attributes(merchant_params)
              @sub_date = @epsadmin_merchant.update_attributes(:subscription_date =>params[:start_subscription_date])
              @subscription_update = @epsadmin_merchant.subscription.update_attributes(:start_subscription_date => params[:start_subscription_date] ,:monthly_invoice_date => @monthly_date[1], :merchant_id =>  @epsadmin_merchant.id )
              create_user(params[:merchant][:status],@epsadmin_merchant)
              format.html { redirect_to epsadmin_merchant_path, notice: 'Merchant was successfully updated.' }
              format.json { head :no_content }
            else
              format.html { render action: "edit" }
              format.json { render json: @epsadmin_merchant_path.errors, status: :unprocessable_entity }
            end
          else
            format.html { render action: "edit" }
            @epsadmin_merchant.errors.add(:version_comments, 'must be provided')
          end
        end
      else
        respond_to do |format|
          format.html { render action: "edit" }
          @epsadmin_merchant.errors.add(:is_kyc_submitted, 'must be unchecked due to some documents not uploaded/seleted')
        end
      end
    else
      respond_to do |format|
        if !params[:version_comments].blank?
            @epsadmin_merchant[:version_comments] = params[:version_comments]
            @epsadmin_merchant[:modifier_id] = current_user.id
          if @epsadmin_merchant.update_attributes(merchant_params)
            @subscription_update = @epsadmin_merchant.subscription.update_attributes(:start_subscription_date => params[:start_subscription_date] ,:monthly_invoice_date => @monthly_date[1], :merchant_id =>  @epsadmin_merchant.id )
            create_user(params[:merchant][:status],@epsadmin_merchant)
            format.html { redirect_to epsadmin_merchant_path, notice: 'Merchant was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: "edit" }
            format.json { render json: @epsadmin_merchant_path.errors, status: :unprocessable_entity }
          end
        else
          format.html { render action: "edit" }
          @epsadmin_merchant.errors.add(:version_comments, 'must be provided')
        end
      end
    end   
  end

  # DELETE /merchants/1
  # DELETE /merchants/1.json
  def destroy
    @epsadmin_merchant = Merchant.where(:merchant_uniq_id => params[:merchant_uniq_id]).first
    @epsadmin_merchant.destroy
    respond_to do |format|
      format.html { redirect_to epsadmin_merchants_url, notice: 'Merchant was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  #For getting transaction list
  def transaction
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@transc_merchant.first_name}", epsadmin_merchant_path(@transc_merchant.merchant_uniq_id)
    @epsadmin_transaction_list = @transc_merchant.transactions.order("created_at DESC")
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @epsadmin_transaction_list }
    end
  end
  #For individual transaction details
  def transaction_show
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@transc_merchant.first_name}", epsadmin_merchant_path(@transc_merchant.merchant_uniq_id)
    add_breadcrumb "Transaction", epsadmin_merchant_transaction_path
    @epsadmin_transaction_indiv = Transaction.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @epsadmin_transaction_indiv }
    end
  end

  def transaction_range
    d = params[:to].split("-")
    td = (d[2].to_i+1)
    if td.to_s != "32"
      to_date = d[0].to_s + "-" + d[1].to_s + "-" + td.to_s
    else
      to_date = params[:to]
    end
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@transc_merchant.first_name}", epsadmin_merchant_path(@transc_merchant.merchant_uniq_id)
    @epsadmin_transaction_list = @transc_merchant.transactions.where(:created_at.gt => params[:from], :created_at.lt => to_date).order("created_at DESC")
    render :partial => "transaction"
  end

  def smart_listing_resource
    @merchant ||= params[:id] ? Merchant.where(:merchant_uniq_id=>params[:merchant_uniq_id]).first : Merchant.new(params[:merchant])
  end

  helper_method :smart_listing_resource

  def smart_listing_collection
    @merchants ||= Merchant.all
  end

  helper_method :smart_listing_collection

  def merchant_status_check
    mid = Merchant.find(params[:id])
    mid.modifier_id=current_user.id
    if params[:st] == "activate"
      @res = mid.activate
    elsif params[:st] == "inactivate"
      @res = mid.inactivate
    elsif params[:st] == "close"
      @res = mid.close
    elsif params[:st] == "cancel"
      @res = mid.cancel
    else
      @res=mid
    end 
    respond_to do |format|
      format.html
      format.json {render json: @res} 
    end
  end

  def transaction_status_check
    mid=Transaction.where(:id=>params[:tid]).first
    if params[:cls] == "btn btn-danger cancel"
      @res=mid.cancel
    else 
      mid.update_attributes(:payment_timestamp => params[:date] ,:transaction_details => params[:details], :transaction_type =>  params[:type])
      @res=mid.pay
    end
    respond_to do |format|
      format.html
      format.json { render :json=>@res} 
    end
  end

  def transaction_pdf
    if (params[:start_date] != "" && params[:end_date] !="")
      @epsadmin_transaction_list = @transc_merchant.transactions.where(:created_at.gte => params[:start_date], :created_at.lte => params[:end_date]).order("created_at DESC")
    else
      @epsadmin_transaction_list = @transc_merchant.transactions.order("created_at DESC")
    end
    respond_to do |format|
      format.html { render :layout => false }
      format.json { render json: @epsadmin_transaction_list}
    end
  end

  
  private
    # Use callbacks to share common setup or constraints between actions.
  def set_merchant
    @epsadmin_merchant = Merchant.where(:merchant_uniq_id => params[:merchant_uniq_id]).first
  end

    # Never trust parameters from the scary internet, only allow the white list through.
  def merchant_params
    params.require(:merchant).permit(:first_name,:last_name, :version_comments,:email_address,:phone_number, :modifier_id, :age,:sex,:business_name,:business_type,:industry_type,:subscription_date,:business_address,:is_kyc_submitted,:start_subscription_date,:address_proof,:given_address_proof,:id_proof,:given_id_proof,:business_id_proof, :business_address_proof,:given_business_address_proof,:given_business_id_proof,:alloted_devices, :merchant_id, :status, photos_attributes: :id_proof, photos_attributes: :address_proof, photos_attributes: :business_address_proof, photos_attributes: :business_id_proof)
  end
  
  def create_user(status,merchant)
    if status.gsub(" ","").downcase == "approve"
      if epsadmin_merchant.user.nil?
        user = User.create(:email => epsadmin_merchant.email_address,:password => EpsAdmin::User.generate_password)
        # epsadmin_merchant.update_attributes(:user_id => user.id)
       UserMailer.sms_user(user).deliver
      end
    end
  end

  def get_merchant
    @merchant = Merchant.where(:merchant_uniq_id => params[:merchant_uniq_id]).first
  end

  def get_transc_merchant
    @transc_merchant = Merchant.where(:merchant_uniq_id => params[:merchant_merchant_uniq_id]).first
  end

  def get_device
    @device = Device.where(:merchant_id => params[:merchant_id]).first
  end

end


