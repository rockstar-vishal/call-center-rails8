class Sysadmin::SourcesController < Sysadmin::BaseController
  before_action :set_source, only: [:show, :edit, :update, :destroy]

  def index
    @sources = Source.all.order(:name)
  end

  def show
  end

  def new
    @source = Source.new
  end

  def create
    @source = Source.new(source_params)
    
    if @source.save
      flash[:notice] = 'Source was successfully created.'
      redirect_to sysadmin_source_path(@source)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @source.update(source_params)
      flash[:notice] = 'Source was successfully updated.'
      redirect_to sysadmin_source_path(@source)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @source.destroy
      flash[:notice] = 'Source was successfully deleted.'
    else
      flash[:alert] = "Cannot delete this source. #{@source.errors.full_messages.join(', ')}"
    end
    redirect_to sysadmin_sources_path
  end

  private

  def set_source
    @source = Source.find(params[:id])
  end

  def source_params
    params.require(:source).permit(:name, :tag)
  end
end
