class Sysadmin::CompaniesController < Sysadmin::BaseController
  before_action :set_company, only: [:show, :edit, :update, :destroy]

  def index
    @companies = Company.all.order(:name)
  end

  def show
    @users_count = @company.users.count
    @leads_count = @company.leads.count
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    
    if @company.save
      flash[:notice] = 'Company was successfully created.'
      redirect_to sysadmin_company_path(@company)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @company.update(company_params)
      flash[:notice] = 'Company was successfully updated.'
      redirect_to sysadmin_company_path(@company)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @company.destroy
      flash[:notice] = 'Company was successfully deleted.'
    else
      flash[:alert] = "Cannot delete this company. #{@company.errors.full_messages.join(', ')}"
    end
    redirect_to sysadmin_companies_path
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :lead_limit, :domain, :crm_domain, :logo, :icon)
  end
end
