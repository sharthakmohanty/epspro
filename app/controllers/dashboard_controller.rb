class DashboardController < ApplicationController

  before_action :get_merchant
  
  def index
    @transaction = @merchant.transactions.where(:transaction_status => 'pending').order("created_at DESC")
    respond_to do |format|
      format.html
      format.json { render json: @transaction }
    end
  end

  def transaction
    @merchant_transaction = @merchant.transactions.order("created_at DESC")
    respond_to do |format|
      format.html
      format.json { render json: @merchant_transaction }
    end
  end

  def billing
    @subscription = @merchant.subscription
    @merchant_billing = @subscription.invoices.order("created_at DESC")
    respond_to do |format|
      format.html
      format.json { render json: @merchant_billing }
    end
  end
  
  def billing_individual
    @billing_individual = Invoice.where(:invoice_number => params[:invoice_number]).first
    respond_to do |format|
      format.html
      format.json { render json: @billing_individual }
    end
  end

  def merchant_detail
    @merchant_device = @merchant.devices.order("created_at DESC")
    respond_to do |format|
      format.html
      format.json { render :json => {:merchant_detail => @merchant, merchant_device => @merchant_device }}
    end
  end

  def update_transaction
    @update_transaction = Transaction.find(params[:tid])
    @update_transaction.update_attributes(:payment_timestamp => params[:date] ,:transaction_details => params[:details], :transaction_type =>  params[:type],:transaction_status => "paid")
    respond_to do |format|
      format.html { redirect_to dashboard_transaction_path, notice: 'Status was successfully updated.'}
      format.json { head :no_content }
      end
  end

  def transaction_cancel
    @transaction_cancel = Transaction.find(params[:id])
    @transaction_cancel.update_attributes(:transaction_status => "cancelled")
    respond_to do |format|
      format.html { redirect_to dashboard_transaction_path, notice: 'Status was successfully updated.'}
      format.json { head :no_content }
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
    @merchant_transaction = @merchant.transactions.where(:created_at.gt => params[:from], :created_at.lt => to_date).order("created_at DESC")
    render :partial => "transaction_list"
  end


  private

  def get_merchant
    @merchant = current_user.merchant
    if @merchant.nil?
      redirect_to "/", :notice => "Sorry you are not authorized for this page."
      return
    end
  end
  

end
