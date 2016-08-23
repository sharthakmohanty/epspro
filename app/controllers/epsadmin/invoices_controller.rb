class Epsadmin::InvoicesController < ApplicationController
  # GET /invoices
  # GET /invoices.json
  before_action :get_merchant, :get_subscription
  before_filter :check_not_merchant
  

  def index
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@merchant.first_name}", epsadmin_merchant_path(@merchant.merchant_uniq_id)
    @epsadmin_invoices = @subscription.invoices.order("invoice_date DESC")
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @epsadmin_invoices }
    end
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
    @epsadmin_invoice = Invoice.where(:invoice_number => params[:invoice_number]).first
    @history_records = Invoice.where(:id => @epsadmin_invoice.id).first.history_tracks
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@merchant.first_name}", epsadmin_merchant_path(@merchant.merchant_uniq_id)
    add_breadcrumb "Invoices", epsadmin_merchant_invoices_path
    respond_to do |format|
      format.html
      format.json { render json: @epsadmin_invoice}
    end
  end


  # GET /invoices/new
  # GET /invoices/new.json
  def new
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@merchant.first_name}", epsadmin_merchant_path(@merchant.merchant_uniq_id)
    add_breadcrumb "Invoices",epsadmin_merchant_invoices_path
    @epsadmin_invoice = Invoice.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @epsadmin_invoice }
    end
  end

  # GET /invoices/1/edit
  def edit
    @epsadmin_invoice = Invoice.where(:invoice_number => params[:invoice_number]).first
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@merchant.first_name}", epsadmin_merchant_path(@merchant.merchant_uniq_id)
    add_breadcrumb "Invoices",epsadmin_merchant_invoices_path(@merchant.merchant_uniq_id)
    add_breadcrumb "#{@epsadmin_invoice.invoice_number}",epsadmin_merchant_invoice_path
  end

  # POST /invoices
  # POST /invoices.json
  def create
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@merchant.first_name}", epsadmin_merchant_path(@merchant.merchant_uniq_id)
    add_breadcrumb "Invoices",epsadmin_merchant_invoices_path
    @epsadmin_invoice = Invoice.new(invoice_params)
    @epsadmin_invoice.modifier_id=current_user.id
    @epsadmin_invoice.tax = params[:invoice][:tax]
    @epsadmin_invoice.invoice_amount = params[:invoice][:invoice_amount]

     #if params[:invoice][:invoice_amount] != ""
     unless (params["select"].blank? || params["desc"].blank? || params["amt"].blank?) 
      unless ((params["select"].values.any? &:blank?) || (params["desc"].values.any? &:blank?) || (params["amt"].values.any? &:blank?))
      respond_to do |format|
        if @epsadmin_invoice.save
          (0...params[:select].values.length).each do |l|
            InvoiceLineItem.create(:description => params[:desc].values[l] ,:amount => params[:amt].values[l], :line_item_type =>  params[:select].values[l], :invoice_id => @epsadmin_invoice.id, :modifier_id=>current_user.id)
          end
          format.html { redirect_to epsadmin_merchant_invoices_path, notice: 'Invoice was successfully created.' }
          format.json { render json: epsadmin_merchant_invoices_path, status: :created, location: @epsadmin_invoice }
        else
          format.html { render action: "new" }
          format.json { render json: epsadmin_invoice.errors, status: :unprocessable_entity }
        end
      end
      else
      respond_to do |format|
        format.html { render action: "new" }
        @epsadmin_invoice.errors.add(:base,  'All the fields are mandatory.Enter all the field values')
      end
    end
    else
      respond_to do |format|
        format.html { render action: "new" }
        @epsadmin_invoice.errors.add(:base,  'Atleast one invoice line item should be added')
      end
    end
  end


  # PUT /invoices/1
  # PUT /invoices/1.json
  def update
    @epsadmin_invoice = Invoice.where(:invoice_number => params[:invoice_number]).first
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@merchant.first_name}", epsadmin_merchant_path(@merchant.merchant_uniq_id)
    add_breadcrumb "Invoices",epsadmin_merchant_invoices_path(@merchant.merchant_uniq_id)
    add_breadcrumb "#{@epsadmin_invoice.invoice_number}"

      unless (params["select"].blank? || params["desc"].blank? || params["amt"].blank?) 
      unless ((params["select"].values.any? &:blank?) || (params["desc"].values.any? &:blank?) || (params["amt"].values.any? &:blank?))
       respond_to do |format|
      if !params[:version_comments].blank?
        @epsadmin_invoice[:version_comments] = params[:version_comments]
        @epsadmin_invoice[:modifier_id] = current_user.id
      if @epsadmin_invoice.update_attributes(invoice_params)

        if params[:select].present?
          @epsadmin_invoice.invoice_line_items.delete_all
          (0...params[:select].values.length).each do |l|
            InvoiceLineItem.create(:description => params[:desc].values[l] ,:amount => params[:amt].values[l], :line_item_type =>  params[:select].values[l], :invoice_id => @epsadmin_invoice.id, :modifier_id=>current_user.id)
          end
        end

        format.html { redirect_to epsadmin_merchant_invoice_path, notice: 'Invoice was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: epsadmin_merchant_invoice_path.errors, status: :unprocessable_entity }
      end
      else
              format.html { render action: "edit" }
              @epsadmin_invoice.errors.add(:version_comments, 'must be provided')
      end
      end
      else
      respond_to do |format|
        format.html { render action: "new" }
        @epsadmin_invoice.errors.add(:base,  'All the fields are mandatory.Enter all the field values')
      end
    end
    else
      respond_to do |format|
        format.html { render action: "new" }
        @epsadmin_invoice.errors.add(:base,  'Atleast one invoice line item should be added')
      end
    end
    
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.json
  def destroy
    @epsadmin_invoice = Invoice.where(:invoice_number => params[:invoice_number]).first
    @epsadmin_invoice.destroy

    respond_to do |format|
      format.html { redirect_to epsadmin_merchant_invoices_path, notice: 'Invoice was successfully deleted'}
      format.json { head :no_content }
    end
  end

  def invoice_status_check
    mid = Invoice.where(:invoice_number => params[:tid]).first
    mid.modifier_id=current_user.id
    if params[:cls].include?"waive"
    mid.update_attribute("remarks",params['details'])
    @res=mid.waive
    elsif params[:cls].include?"popup"
    mid.update_attributes(:paid_date => params[:date] ,:payment_details => params[:details], :paid_via =>  params[:type])
    @res=mid.pay
  elsif params[:cls].include?"cancel"
    mid.update_attribute("remarks",params['details'])
    @res=mid.cancel
  end
    respond_to do |format|
     format.html
     format.json { render :json=>@res} 
    end
  end

  def invoice_print
    @epsadmin_invoice = Invoice.where(:invoice_number => params[:invoice_number]).first
    respond_to do |format|
      format.html { render :layout => false }
      format.json { render json: @epsadmin_invoice}
    end
  end

  def invoice_pdf
    if (params[:start_date] != "" && params[:end_date] !="")
      @epsadmin_invoices = @subscription.invoices.where(:created_at.gte => params[:start_date], :created_at.lte => params[:end_date]).order("created_at DESC")
    else
      @epsadmin_invoices = @subscription.invoices.order("created_at DESC")
    end
    respond_to do |format|
      format.html { render :layout => false }
      format.json { render json: @epsadmin_invoices}
    end
  end

  private

  def invoice_params
    params.require(:invoice).permit(:invoice_number, :invoice_date, :business_name, :address, :amount, :tax, :invoice_type, :status, :paid_date, :payment_details, :remarks, :paid_via, :device_id, :subscription_id,:invoice_amount,:modifier_id,:version_comments)
  end

  def get_merchant
    @merchant = Merchant.where(:merchant_uniq_id => params[:merchant_merchant_uniq_id]).first
  end

  def get_subscription
    @subscription = Subscription.where(:merchant_id => @merchant.id).first
  end


end
