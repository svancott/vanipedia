class WikisController < ApplicationController

  before_action :require_sign_in, except: [:index, :show]
  before_action :authorize_user, except: [:index, :show, :new, :edit, :create, :update]
  def index
    @wikis = policy_scope(Wiki)
  end

  def new
    @wiki = Wiki.new
    @all_users = User.all
  end

  def create
    @wiki = Wiki.new
    @wiki.title = params[:wiki][:title]
    @wiki.body = params[:wiki][:body]
    @wiki.user= current_user
    @wiki.private = params[:wiki][:private]
    # @wiki.collaborator = Collaborator.new(wiki_id: @wiki, user_id: User.where(email: params[:new_collaborator]))

    if @wiki.save
      flash[:notice] = "Wiki was saved."
      redirect_to @wiki
    else
      flash.now[:alert] = "There was an error saving the Wiki. Please try again."
      render :new
    end
  end

  def show
    @wiki = Wiki.find(params[:id])
  end

  def edit
    @wiki = Wiki.find(params[:id])
  end

  def update
    @wiki = Wiki.find(params[:id])
    @wiki.title = params[:wiki][:title]
    @wiki.body = params[:wiki][:body]
    @wiki.private = params[:wiki][:private]
    # @wiki.collaborator = Collaborator.new(wiki_id: @wiki, user_id: User.where(email: params[:new_collaborator]))
    authorize @wiki

    if @wiki.save
      flash[:notice] = "Wiki was updated."
      redirect_to @wiki
    else
      flash.now[:alert] = "There was an error saving the Wiki. Please try again."
      render :edit
    end
  end

  def destroy
    @wiki = Wiki.find(params[:id])

    if @wiki.destroy
      flash[:notice] = "\"#{@wiki.title}\" was deleted successfully"
      redirect_to wikis_path
    else
      flash.now[:alert] = "There was an error deleting the Wiki."
      render :show
    end
  end

  private

  def authorize_user
     unless current_user.admin?
       flash[:alert] = "You must be an admin to do that."
       redirect_to wikis_path
     end
   end

   def collaborator
     @wiki = Wiki.find(params[:id])
     @collaborator = Collaborator.new(wiki_id: @wiki, user_id: User.where(email: params[:new_collaborator]))
     @collaborator.save
   end
end
