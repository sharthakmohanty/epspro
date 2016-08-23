class AdminDashboardController < ApplicationController

  # before_filter :check_not_merchant
  before_action :get_merchant

  def all_device
    @all_device = Device.all.order("created_at DESC")
    respond_to do |format|
      format.html
      format.json { render json: @all_device }
    end
  end

  def individual_device
    @individual_device = Device.where(:terminal_id => params[:terminal_id]).first
    respond_to do |format|
      format.html
      format.json { render json: @individual_device }
    end
  end

  #For admin viewing all invoices
  def all_invoice
    @all_invoice = Invoice.all.order("invoice_date DESC")
    respond_to do |format|
      format.html
      format.json { render json: @all_invoice }
    end
  end

  def all_device_pdf
    if (params[:start_date] != "" && params[:end_date] !="")
      @all_device = Device.where(:created_at.gte => params[:start_date], :created_at.lte => params[:end_date])
    else
      @all_device = Device.all.order("created_at DESC")
    end
    respond_to do |format|
      format.html { render :layout => false }
      format.json { render json: @all_device}
    end
  end

  def all_invoice_pdf
    if (params[:start_date] != "" && params[:end_date] !="")
      @all_invoice = Invoice.where(:created_at.gte => params[:start_date], :created_at.lte => params[:end_date])
    else
      @all_invoice = Invoice.all.order("created_at DESC")
    end
    respond_to do |format|
      format.html { render :layout => false }
      format.json { render json: @all_invoice}
    end
  end

  private

  def get_merchant
    @merchant = Merchant.where(:id => params[:merchant_id]).first
  end

end
