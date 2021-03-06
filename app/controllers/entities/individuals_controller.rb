class Entities::IndividualsController < ApplicationController
  before_action :current_page
  before_action :check_xhr_page
  before_action :set_entity, only: [:basic_info]
  # before_action :add_breadcrum

  def basic_info
    key = params[:entity_key]
    if request.get?
      @entity = Entity.find_by(key: key)
      entity_check() if @entity.present?
      @entity       ||= Entity.new(type_: params[:type])
      if @entity.new_record?
        individual_breadcrumb
      else
        add_breadcrumb "Clients", clients_path, :title => "Clients" 
        add_breadcrumb "Individual", '',  :title => "Individual"
        add_breadcrumb "Edit: #{@entity.name}", '',  :title => "edit"
        add_breadcrumb "Basic Info", '',  :title => "Basic Info"
      end
    elsif request.post?
      @entity                 = Entity.new(individuals_params)
      @entity.type_           = MemberType.getIndividualId
      @entity.basic_info_only = true
      @entity.user_id         = current_user.id
      @entity.name = @entity.first_name + ' ' + @entity.last_name
      if @entity.save
        AccessResource.add_access({user: current_user, resource: Entity.find(@entity.id)})
        flash[:success] = "Congratulations, you have just created a record for #{@entity.name}"
        return redirect_to entities_individuals_basic_info_path(@entity.key)
      else
        individual_breadcrumb
      end
    elsif request.patch?
      @entity                 = Entity.find_by(key: key)
      prior_entity_name = @entity.name
      @entity.type_           = MemberType.getIndividualId
      @entity.basic_info_only = true
      @entity.assign_attributes(individuals_params)
      @entity.name = @entity.first_name + ' ' + @entity.last_name
      if @entity.save
        flash[:success] = "Congratulations, you have just made a change in the record for #{prior_entity_name}"
        return redirect_to entities_individuals_basic_info_path(@entity.key)
      end
    else      
      raise UnknownRequestFormat
    end
    render layout: false if request.xhr?
  end
  
  def individual_breadcrumb
    add_breadcrumb "Clients", clients_path, :title => "Clients" 
    add_breadcrumb "Individual", '',  :title => "Individual"
    add_breadcrumb "Create", '',  :title => "Create"
  end

  def owns
    @entity = Entity.find_by(key: params[:entity_key])
    @ownership_ = @entity.build_ownership_tree_json
    @owns_available = (@ownership_[0][:nodes] == nil) ? false : true
    @ownership = @ownership_.to_json
    add_breadcrumb "Clients", clients_path, :title => "Clients" 
    add_breadcrumb "Individual", '',  :title => "Individual"
    add_breadcrumb "Edit: #{@entity.name}", '',  :title => "edit"
    add_breadcrumb "Owns", '',  :title => "Owns"
    
    raise ActiveRecord::RecordNotFound if @entity.blank?
    render layout: false if request.xhr?
  end

  private

  def individuals_params
    params.require(:entity).permit(:address, :type_, :jurisdiction, :number_of_assets,
                                   :first_name, :last_name, :phone1, :phone2, :fax, :email,
                                   :postal_address, :city, :state, :zip, :date_of_formation, :m_date_of_formation,
                                   :ein_or_ssn, :s_corp_status, :not_for_profit_status, :legal_ending, :honorific, :is_honorific, :notes).merge({ name: "Individual", date_of_formation: Time.zone.now })
  end

  def current_page
    @current_page = "entity"
  end

  def check_xhr_page
    unless request.xhr?
      if params[:action] != "basic_info"
        return redirect_to entities_individuals_basic_info_path(params[:entity_key], xhr: request.env["REQUEST_PATH"])
      end
    end
  end

  def set_entity
    key = params[:entity_key]
    @entity = Entity.find_by(key: key)
  end

  def add_breadcrum
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">Clients </a></h4></div>".html_safe
    if params[:entity_key] and @entity.present? and !@entity.new_record?
      add_breadcrumb ("<div class=\"pull-left\"><h4><a href=\"#{edit_entity_path(@entity.key)}\">Edit Individual: #{@entity.name}</a><span id='int-action-indv'></span></h4></div>").html_safe
    else
      add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">#{params[:action] == "basic_info" ? "Add" : "" } Individual </a></h4></div>".html_safe
    end

    if params[:action] != "basic_info"
      add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">#{params[:action].titleize}</a></h4></div>".html_safe
    end
  end

end
