class Epsadmin::DevicesController < ApplicationController
  # GET /devices
  # GET /devices.json
  before_action :get_merchant
  before_filter :check_not_merchant
  def index
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@merchant.first_name}", epsadmin_merchant_path(@merchant.merchant_uniq_id)
    @epsadmin_devices = @merchant.devices.order("created_at DESC")
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @epsadmin_devices }
    end
  end

  # GET /devices/1
  # GET /devices/1.json
  def show
    @epsadmin_device = Device.where(:terminal_id => params[:terminal_id]).first
    @history_records = Device.where(:id => @epsadmin_device.id).first.history_tracks
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@merchant.first_name}", epsadmin_merchant_path(@merchant.merchant_uniq_id)
    add_breadcrumb "Devices",epsadmin_merchant_devices_path(@merchant.merchant_uniq_id)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @epsadmin_device }
    end
  end

  # GET /devices/new
  # GET /devices/new.json
  def new
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@merchant.first_name}", epsadmin_merchant_path(@merchant.merchant_uniq_id)
    add_breadcrumb "Devices",epsadmin_merchant_devices_path(@merchant.merchant_uniq_id)
    @epsadmin_device = Device.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @epsadmin_device }
    end
  end

  # GET /devices/1/edit
  def edit
    @epsadmin_device = Device.where(:terminal_id => params[:terminal_id]).first
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@epsadmin_device.merchant.first_name}", epsadmin_merchant_path(@epsadmin_device.merchant.merchant_uniq_id)
    add_breadcrumb "Devices",epsadmin_merchant_devices_path(@merchant.merchant_uniq_id)
    add_breadcrumb "#{@epsadmin_device.terminal_id}",epsadmin_merchant_device_path
  end

  # POST /devices
  # POST /devices.json
  def create
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@merchant.first_name}", epsadmin_merchant_path(@merchant.merchant_uniq_id)
    add_breadcrumb "Devices",epsadmin_merchant_devices_path(@merchant.merchant_uniq_id)
    @epsadmin_device = Device.new(device_params)
    @epsadmin_device.modifier_id=current_user.id
    @epsadmin_device.device_make = params[:device_make]
    #Generation of terminal id
    @epsadmin_device.terminal_id = rand.to_s[2..5] + params[:device][:merchant_id].first(2)
    #End
    dev=Device.not_in(:device_status=>"deactivated").map(&:device_serial_number)

    if (params[:device_make] == "Falcon Plus" && params[:device][:bank_mmid] != "") || (params[:device_make] == "Leopard" && params[:device][:pg_merchant_id] != "" && params[:device][:pg_key] != "" && params[:device][:pg_sat] != "" && params[:device][:tablet_serial_number] != "")
      if !(dev.include?(params[:device][:device_serial_number]))
        respond_to do |format|
          if @epsadmin_device.save
            format.html { redirect_to epsadmin_merchant_devices_path, notice: 'Device was successfully created.' }
            format.json { render json: epsadmin_merchant_devices_path, status: :created, location: @epsadmin_device }
          else
            format.html { render action: "new" }
            format.json { render json: @epsadmin_device.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          format.html { render action: "new" }
          @epsadmin_device.errors.add(:device_serial_number, 'is already allocated to some device')
        end
      end
    else
      respond_to do |format|
        format.html { render action: "new" }
        @epsadmin_device.errors.add(:base, 'All the fields in Bank Details section must be filled')
      end
    end

  end

  # PUT /devices/1
  # PUT /devices/1.json
  def update
    @epsadmin_device = Device.where(:terminal_id => params[:terminal_id]).first
    add_breadcrumb "Merchants", epsadmin_merchants_path
    add_breadcrumb "#{@epsadmin_device.merchant.first_name}", epsadmin_merchant_path(@epsadmin_device.merchant.merchant_uniq_id)
    add_breadcrumb "Devices",epsadmin_merchant_devices_path(@merchant.merchant_uniq_id)
    add_breadcrumb "#{@epsadmin_device.terminal_id}",""
    if (params[:device_make] == "Falcon Plus" && params[:device][:bank_mmid] != "") || (params[:device_make] == "Leopard" && params[:device][:pg_merchant_id] != "" && params[:device][:pg_key] != "" && params[:device][:pg_sat] != "" && params[:device][:tablet_serial_number] != "")
      respond_to do |format|
        if !params[:version_comments].blank?
          @epsadmin_device[:version_comments] = params[:version_comments]
          @epsadmin_device[:modifier_id] = current_user.id
        if @epsadmin_device.update_attributes(device_params)
          @epsadmin_device.update_attributes(:device_make => params[:device_make])
          format.html { redirect_to epsadmin_merchant_device_path, notice: 'Device was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: epsadmin_merchant_device_path.errors, status: :unprocessable_entity }
        end
        else
          format.html { render action: "edit" }
          @epsadmin_device.errors.add(:version_comments, 'must be provided')
        end
      end
    else
      respond_to do |format|
        format.html { render action: "new" }
        @epsadmin_device.errors.add(:base, 'All the fields in Bank Details section must be filled')
      end
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.json
  def destroy
    @epsadmin_device = Device.where(:terminal_id => params[:terminal_id]).first
    if @epsadmin_device.device_status == "pending"
      @epsadmin_device.destroy
      respond_to do |format|
        format.html { redirect_to epsadmin_merchant_devices_path, notice: 'Device was successfully deleted' }
        format.json { head :no_content }
      end
    else
        respond_to do |format|
          format.html { redirect_to epsadmin_merchant_device_path, notice: 'Device status must be in pending state to delte/remove it'}
          format.json { head :no_content }
        end
    end
  end

  def device_status_check
    mid=Device.where(:id=>params[:device_terminal_id]).first
    mid.modifier_id=current_user.id
    mid.updated_at=Time.now
    if params[:st] == "activate"
      @res=mid.activate
    elsif params[:st] == "inactivate"
      @res=mid.inactivate
    elsif params[:st] == "deactivate"
      @res=mid.deactivate
    else
      @res=mid
    end 
    respond_to do |format|
      format.html
      format.json { render :json=>@res} 
    end
  end

  def autocreate_invoice
    @subscription = Subscription.where(:merchant_id => params[:id]).first
    @tax = params[:cst].to_i * 0.15
    @amt = params[:cst].to_i + @tax
    @autocreate_invoice = Invoice.new(:device_id => params[:dev_id], :subscription_id => @subscription.id ,:status => "pending", :invoice_number => params[:inv_no], :invoice_date => params[:inv_dt], :business_name => params[:bus_nam], :address => params[:bus_add], :invoice_type => params[:inv_typ], :invoice_amount => @amt.round, :tax => @tax.round)
    if @autocreate_invoice.save
      InvoiceLineItem.create(:description => "Device setup cost" ,:amount => params[:cst].to_i.round, :line_item_type =>  "Setup Charges", :invoice_id => @autocreate_invoice.id)
    end
    respond_to do |format|
      format.html
      format.json { head :no_content }  
    end
  end

  def device_pdf
    if (params[:start_date] != "" && params[:end_date] !="")
      @epsadmin_devices = @merchant.devices.where(:created_at.gte => params[:start_date], :created_at.lte => params[:end_date]).order("created_at DESC")
    else
      @epsadmin_devices = @merchant.devices.order("created_at DESC")
    end
    respond_to do |format|
      format.html { render :layout => false }
      format.json { render json: @epsadmin_devices}
    end
  end

  private

  def device_params
    params.require(:device).permit(:device_serial_number, :sim_phone_number, :sim_msid_number, :device_make, :device_display, :bank_mmid, :device_status, :terminal_id, :setup_cost, :monthly_cost, :transaction_cost, :parent_id, :merchant_id,:modifier_id,:pg_merchant_id,:pg_key,:pg_salt,:tablet_serial_number,:version_comments)
  end

  def get_merchant
    @merchant = Merchant.where(:merchant_uniq_id => params[:merchant_merchant_uniq_id]).first
  end

end
