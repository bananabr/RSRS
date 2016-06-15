class SupportRequestsController < LoginRequiredController
  before_action :set_support_request, only: [:show, :edit, :update, :destroy]

  # GET /support_requests
  # GET /support_requests.json
  def index
    @support_requests = current_user.support_requests.order(id: :desc)
    @support_requests = @support_requests.offset(@skip) unless @skip.nil? 
    @support_requests = @support_requests.first(@limit) unless @limit.nil? 
  end

  # GET /support_requests/1
  # GET /support_requests/1.json
  def show
  end

  # GET /support_requests/new
  def new
    @support_request = SupportRequest.new
  end

  # GET /support_requests/1/edit
  def edit
  end

  # POST /support_requests
  # POST /support_requests.json
  def create
    @support_request = SupportRequest.new(support_request_params)
    @support_request.ttl = Settings.default_request_ttl
    @support_request.user = current_user
    @support_request.provider = Settings.default_request_tunnel_provider
    @support_request.shared_key = Utils::generate_random_string(Settings.default_request_shared_key_size)

    respond_to do |format|
      if @support_request.save
        format.html { redirect_to support_requests_url, notice: 'Support request was successfully created.' }
        format.json { render :show, status: :created, location: @support_request }
      else
        format.html { render :new }
        format.json { render json: @support_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /support_requests/1
  # PATCH/PUT /support_requests/1.json
  def update
    respond_to do |format|
      if @support_request.update(support_request_params)
        format.html { redirect_to support_requests_url, notice: 'Support request was successfully updated.' }
        format.json { render :show, status: :ok, location: @support_request }
      else
        format.html { render :edit }
        format.json { render json: @support_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /support_requests/1
  # DELETE /support_requests/1.json
  def destroy
    @support_request.destroy
    respond_to do |format|
      format.html { redirect_to support_requests_url, notice: 'Support request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_support_request
      @support_request = current_user.support_requests.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def support_request_params
      params.require(:support_request).permit(:justification, :ttl)
    end
end
