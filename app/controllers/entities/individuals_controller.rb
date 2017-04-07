class Entities::IndividualsController < ApplicationController
  before_action :current_page
  before_action :check_xhr_page
  before_action :add_breadcrum

	def basic_info
    key = params[:entity_key]
    if request.get?
      @entity       = Entity.find_by( key: key )
      entity_check() if @entity.present?
      @entity     ||= Entity.new( type_: params[:type] )
      @just_created = params[:just_created].to_b
    elsif request.post?
      @entity                 = Entity.new( individuals_params )
      @entity.type_           = MemberType.new.getIndividualId
      @entity.basic_info_only = true
      if @entity.save
        AccessResource.add_access({user: current_user, resource: Entity.find(@entity.id)})
        return render json: {redirect: view_context.entities_individuals_basic_info_path( @entity.key ), just_created: true}
      end
    elsif request.patch?
      @entity                 = Entity.find_by(key: key)
      @entity.type_           = MemberType.new.getIndividualId
      @entity.basic_info_only = true
      @entity.update( individuals_params )
    else
      raise UnknownRequestFormat
    end
    render layout: false if request.xhr?
  end

  private

    def individuals_params
      params.require(:entity).permit(:address, :type_, :jurisdiction, :number_of_assets,
                                   :first_name, :last_name, :phone1, :phone2, :fax, :email,
                                   :postal_address, :city, :state, :zip, :date_of_formation, :m_date_of_formation,
                                   :ein_or_ssn, :s_corp_status, :not_for_profit_status, :legal_ending, :honorific, :is_honorific, :notes).merge({name: "Individual",date_of_formation: DateTime.now })
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
  
  def add_breadcrum
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">Clients </a></h4></div>".html_safe
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">#{params[:action] == "basic_info" ? "Add" : "" } Individual </a></h4></div>".html_safe
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">#{params[:action].titleize}</a></h4></div>".html_safe unless params[:action] == "basic_info"
  end
end
