class Entities::TenancyInCommonController < ApplicationController

  before_action :current_page
  # before_action :check_xhr_page
  before_action :set_entity, only: [:basic_info]
  # before_action :add_breadcrum

  def basic_info
    #key = params[:entity_key]
    if request.get?
      #@entity = Entity.find_by(key: key)
      #if @entity.present?
      #  entity_check()
      #  @entity = EntityTenancyInCommon.find_by(key: key)
      #end
      @entity       ||= EntityTenancyInCommon.new(type_: params[:type])
      if @entity.new_record?
        add_breadcrumb "Clients", clients_path, :title => "Clients"
        add_breadcrumb "Tenancy in Common", '',  :title => "Tenancy in Common"
        add_breadcrumb "Create", '',  :title => "Create"
      else
        add_breadcrumb "Clients", clients_path, :title => "Clients"
        add_breadcrumb "Tenancy in Common", '',  :title => "Tenancy in Common"
        add_breadcrumb "Edit: #{@entity.name}", '',  :title => "Edit"
        add_breadcrumb "Basic Info", '',  :title => "Basic Info"
      end
    elsif request.post?
      @entity                 = EntityTenancyInCommon.new(entity_tenancy_in_common_params)
      @entity.type_           = MemberType.getTenancyinCommonId
      @entity.basic_info_only = true
      @entity.user_id         = current_user.id

      if @entity.save
        AccessResource.add_access({ user: current_user, resource: Entity.find(@entity.id) })
        flash[:success] = "Congratulations, you have just created a record for #{@entity.name}, a Tenancy in Common"
        return redirect_to entities_tenancy_in_common_basic_info_path(@entity.key)
      end
    elsif request.patch?
      #@entity                 = EntityTenancyInCommon.find_by(key: key)
      prior_entity_name = @entity.name
      @entity.type_           = MemberType.getTenancyinCommonId
      @entity.basic_info_only = true
      if @entity.update(entity_tenancy_in_common_params)
        flash[:success] = "Congratulations, you have just made a change in the record for #{prior_entity_name}, a Tenancy in Common"
        return redirect_to entities_tenancy_in_common_basic_info_path(@entity.key)
      end
    else
      raise UnknownRequestFormat
    end
    render layout: false if request.xhr?
  end

  # tenants_in_common
  def tenant_in_common
    unless request.delete?
      @entity = Entity.find_by(key: params[:entity_key])
      id      = params[:id]
      raise ActiveRecord::RecordNotFound if @entity.blank?
      @tenant_in_common                 = TenantInCommon.find(id) if id.present?
      @tenant_in_common                 ||= TenantInCommon.new
      @tenant_in_common.super_entity_id = @entity.id
      if request.get?
        if @tenant_in_common.new_record?
          add_breadcrumb "Clients", clients_path, :title => "Clients"
          add_breadcrumb "Tenancy in Common", '',  :title => "Tenancy in Common"
          add_breadcrumb "Edit: #{@entity.name}", '',  :title => "Edit"
          add_breadcrumb "Tenant in Common Create", '',  :title => "Tenant in Common Create"
        else
          add_breadcrumb "Clients", clients_path, :title => "Clients"
          add_breadcrumb "Tenancy in Common", '',  :title => "Tenancy in Common"
          add_breadcrumb "Edit: #{@entity.name}", '',  :title => "Edit"
          add_breadcrumb "Tenant in Common", '',  :title => "Tenant in Common"
        end
      end
    end
    if request.post?
      @tenant_in_common                 = TenantInCommon.new(tenant_in_common_params)
      @tenant_in_common.super_entity_id = @entity.id
      @tenant_in_common.class_name      = "TenantInCommon"
      @tenant_in_common.use_temp_id
      if @tenant_in_common.save
        @tenants_in_common = @tenant_in_common.super_entity.tenants_in_common
        flash[:success] = "Congratulations, you have just created a record for #{@tenant_in_common.first_name} #{@tenant_in_common.last_name}, a Tenant in Common of #{@entity.name}"
        return redirect_to entities_tenancy_in_common_tenants_in_common_path(@entity.key)
      else
        @tenant_in_common.gen_temp_id
        return redirect_to entities_tenancy_in_common_tenant_in_common_path(@entity.key, @tenant_in_common.id)
      end
    elsif request.patch?
      prior_tic_name = "#{@tenant_in_common.first_name} #{@tenant_in_common.last_name}"
      if @tenant_in_common.update(tenant_in_common_params)
        @tenant_in_common.use_temp_id
        if @tenant_in_common.save
          @tenants_in_common = @tenant_in_common.super_entity.tenants_in_common
          flash[:success] = "Congratulations, you have just made a change in the record for #{prior_tic_name}, a Tenant in Common of #{@entity.name}"
          return redirect_to entities_tenancy_in_common_tenants_in_common_path(@entity.key)
        end
      else
        @tenant_in_common.gen_temp_id
        return redirect_to entities_tenancy_in_common_tenant_in_common_path(@entity.key, @tenant_in_common.id)
      end
    elsif request.delete?
      tenant_in_common = TenantInCommon.find(params[:id])
      tenant_in_common.delete
      @entity            = tenant_in_common.super_entity
      @tenants_in_common = @entity.tenants_in_common
      return redirect_to entities_tenancy_in_common_tenants_in_common_path(@entity.key)
    end
    @tenant_in_common.gen_temp_id
    render layout: false if request.xhr?
  end

  def tenants_in_common
    @entity = Entity.find_by(key: params[:entity_key])
    add_breadcrumb "Clients", clients_path, :title => "Clients"
    add_breadcrumb "Tenancy in Common", '',  :title => "Tenancy in Common"    
    add_breadcrumb "Edit: #{@entity.name}", '',  :title => "Edit"
    add_breadcrumb "Tenants in Common List View", '',  :title => "Tenants in Common List View"
    
    raise ActiveRecord::RecordNotFound if @entity.blank?
    @tenants_in_common = @entity.tenants_in_common
    render layout: false if request.xhr?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  private
  def entity_tenancy_in_common_params
    params.require(:entity_tenancy_in_common).permit(:name, :name2, :address, :type_, :jurisdiction,
                                                     :number_of_assets, :first_name, :last_name, :phone1, :phone2,
                                                     :fax, :email, :property_id, :postal_address, :postal_address2,
                                                     :city, :city2, :state, :state2, :zip, :zip2, :date_of_formation,
                                                     :m_date_of_formation, :ein_or_ssn, :s_corp_status,
                                                     :not_for_profit_status, :legal_ending, :honorific, :is_honorific,
                                                     :date_of_appointment, :m_date_of_appointment, :country,
                                                     :date_of_commission, :m_date_of_commission, :index)
  end

  def tenant_in_common_params
    params.require(:tenant_in_common).permit(:temp_id, :member_type_id, :name, :name2, :address, :type_, :jurisdiction,
                                             :number_of_assets, :first_name, :last_name, :phone1, :phone2, :fax,
                                             :email, :property_id, :postal_address, :postal_address2, :city, :city2,
                                             :state, :state2, :zip, :zip2, :date_of_formation, :m_date_of_formation,
                                             :ein_or_ssn, :s_corp_status, :not_for_profit_status, :legal_ending,
                                             :honorific, :is_honorific, :date_of_appointment, :m_date_of_appointment,
                                             :country, :date_of_commission, :m_date_of_commission, :index, :country2,
                                             :part, :my_percentage, :contact_id, :is_person)
  end

  def current_page
    @current_page = "entity"
  end

  def check_xhr_page
    unless request.xhr?
      if params[:action] != "basic_info"
        return redirect_to entities_tenancy_in_common_basic_info_path(params[:entity_key], xhr: request.env["REQUEST_PATH"])
      end
    end
  end

  def set_entity
    key = params[:entity_key]
    @entity = Entity.find_by(key: key)
    if @entity.present?
      entity_check()
      @entity = EntityTenancyInCommon.find_by(key: key)
    end
  end

  def add_breadcrum
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">Clients </a></h4></div>".html_safe
    if params[:entity_key] and @entity.present? and !@entity.new_record?
      add_breadcrumb ("<div class=\"pull-left\"><h4><a href=\"#{edit_entity_path(@entity.key)}\">Edit Tenancy In Common: <span id='edit-title-tic'>#{@entity.name}</span></a><span id='int-action-tic'></span></h4></div>").html_safe
    else
      add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">#{params[:action] == "basic_info" ? "Add" : "" } Tenancy In Common </a></h4></div>".html_safe
    end

    if params[:action] != "basic_info"
      add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">#{params[:action].titleize}</a></h4></div>".html_safe
    end
  end
end
