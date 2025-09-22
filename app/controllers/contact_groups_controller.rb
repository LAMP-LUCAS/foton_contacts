class ContactGroupsController < ApplicationController
  before_action :require_login
  before_action :find_contact_group, only: [:show, :edit, :update, :destroy, :add_member, :remove_member]
  before_action :authorize_global
  
  def index
    @contact_groups = ContactGroup.visible(User.current)
                                .includes(:author)
                                .order(:name)
                                .page(params[:page])
                                
    respond_to do |format|
      format.html
      format.api
    end
  end
  
  def show
    @members = @contact_group.contacts.includes(:author).order(:name)
    
    respond_to do |format|
      format.html
      format.api
    end
  end
  
  def new
    @contact_group = ContactGroup.new(author: User.current)
    @contact_group.safe_attributes = params[:contact_group]
  end
  
  def create
    @contact_group = ContactGroup.new(author: User.current)
    @contact_group.safe_attributes = params[:contact_group]
    
    if @contact_group.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_contact_group_created)
          redirect_to contact_group_path(@contact_group)
        }
        format.api { render action: 'show', status: :created }
      end
    else
      respond_to do |format|
        format.html { render action: 'new' }
        format.api { render_validation_errors(@contact_group) }
      end
    end
  end
  
  def edit
  end
  
  def update
    @contact_group.safe_attributes = params[:contact_group]
    
    if @contact_group.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_contact_group_updated)
          redirect_to contact_group_path(@contact_group)
        }
        format.api { render_api_ok }
      end
    else
      respond_to do |format|
        format.html { render action: 'edit' }
        format.api { render_validation_errors(@contact_group) }
      end
    end
  end
  
  def destroy
    if @contact_group.deletable?
      @contact_group.destroy
      flash[:notice] = l(:notice_contact_group_deleted)
    else
      flash[:error] = l(:error_contact_group_not_deletable)
    end
    
    respond_to do |format|
      format.html { redirect_to contact_groups_path }
      format.api { render_api_ok }
    end
  end
  
  def add_member
    @membership = @contact_group.memberships.build
    @membership.safe_attributes = params[:membership]
    
    if @membership.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_contact_added_to_group)
          redirect_to contact_group_path(@contact_group)
        }
        format.js
        format.api { render_api_ok }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = @membership.errors.full_messages.join(', ')
          redirect_to contact_group_path(@contact_group)
        }
        format.js { render json: @membership.errors, status: :unprocessable_entity }
        format.api { render_validation_errors(@membership) }
      end
    end
  end
  
  def remove_member
    @membership = @contact_group.memberships.find_by!(contact_id: params[:contact_id])
    @membership.destroy
    
    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_contact_removed_from_group)
        redirect_to contact_group_path(@contact_group)
      }
      format.js
      format.api { render_api_ok }
    end
  end
  
  private
  
  def find_contact_group
    @contact_group = ContactGroup.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end