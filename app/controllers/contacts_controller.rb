class ContactsController < ApplicationController

  include ApplicationHelper

  before_action :current_page

  def new
    @contact = Contact.new
    @contact.cprefix =  (params[:contact_type] == "company") ? "Contact " : ""
    add_breadcrumb "Contacts"
    add_breadcrumb "Add Contact #{(params[:contact_type] || "contact").titleize}"
    render layout: false, template: "contacts/new" if request.xhr?
  end

  def create
    @contact = Contact.new(contact_params)
    params[:contact_type] = "company" if !@contact.company_name.nil?
    @contact.legal_ending = nil if @contact.company_name.nil?
    @contact.user_id = current_user.id
    @contact.cprefix =  (params[:contact_type] == "company") ? "Contact " : ""
    @contact.role = "Counter-Party"
    if @contact.contact_type == "Client Participant"
      @contact.role = @contact.cp_role
    elsif @contact.contact_type == "Personnel"
      @contact.role = @contact.per_role
    end

    respond_to do |format|
      if @contact.save
        flash[:success] = "Congratulations, you have just created a record for #{@contact.name}"
        format.html { redirect_to edit_contact_path(@contact) }
        format.js {render layout: false, template: "contacts/new"}
        format.json { render json: @contact }
      else
        format.html { render action: 'new' }
        format.js {render layout: false, template: "contacts/new"}
        format.json { render json: false }
      end
    end
  end

  def update
    @contact = Contact.find_by(id: params[:id])
    if @contact.nil?
      # flash[:error] = "Specified contact not found."
      return redirect_to contacts_path
    end
    prior_contact_name = @contact.name
    params[:contact_type] = "company" if !@contact.company_name.nil?
    @contact.legal_ending = nil if @contact.company_name.nil?
    @contact.cprefix =  (params[:contact_type] == "company") ? "Contact " : ""
    @contact.assign_attributes(contact_params)
    @contact.role = "Counter-Party"
    if @contact.contact_type == "Client Participant"
      @contact.role = @contact.cp_role
    elsif @contact.contact_type == "Personnel"
      @contact.role = @contact.per_role
    end

    respond_to do |format|
      if @contact.save
        flash[:success] = "Congratulations, you have just made a change in the record for #{prior_contact_name}"
        format.html { redirect_to contacts_path }
        format.js {render layout: false, template: "contacts/new"}
        format.json { render json: @contact }
      else
        format.html { render action: 'edit' }
        format.js {render layout: false, template: "contacts/new"}
        format.json { render json: false }
      end
    end
  end

  def index
    @contacts = Contact.with_deleted
    @contacts = @contacts.where(deleted_at: nil) unless params[:trashed].to_b
    @contacts = @contacts.where.not(deleted_at: nil) if params[:trashed].to_b
    @contacts = @contacts.where(user_id: current_user.id)
    @contacts = @contacts.order(created_at: :desc).paginate(page: params[:page], per_page: sessioned_per_page)
    @activeId = params[:active_id]
    add_breadcrumb "Contacts"
    add_breadcrumb "List View"
  end

  def show
    @contact = Contact.find_by(id: params[:id])

    if @contact.nil?
      # flash[:error] = "Specified contact not found."
      return redirect_to contacts_path
    else
      @ctype_ = "Individual"
      @ctype_ = "Company" if @contact.is_company
      add_breadcrumb "Contacts"
      add_breadcrumb "#{@ctype_} Show: #{@contact.name}", contact_path(@contact.id)
    end
  end

  def edit
    @contact = Contact.find_by(id: params[:id])
    params[:contact_type] = "company" if !@contact.company_name.nil?
    @contact.cprefix =  (params[:contact_type] == "company") ? "Contact " : ""
    if @contact.nil?
      # flash[:error] = "Specified contact not found."
      return redirect_to contacts_path
    end
    if @contact.contact_type == "Client Participant"
      @contact.cp_role = @contact.role
    elsif @contact.contact_type == "Personnel"
      @contact.per_role = @contact.role
    end
    ctype_ = "Individual"
    ctype_ = "Company" if @contact.is_company
    add_breadcrumb "Contacts", contacts_path
    add_breadcrumb "#{ctype_} Edit: #{@contact.name}", edit_contact_path(@contact.id)
  end

  def destroy
    @contact = Contact.find_by(id: params[:id])
    contacts_delete(@contact)
    @contact.try(:destroy)
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render json: {success: true} }
    end
  end

  def multi_delete
    common_multi_delete
  end

  private

  def current_page
    @current_page = 'contacts'
  end


  def contact_params
    params.require(:contact).permit!
  end

end
