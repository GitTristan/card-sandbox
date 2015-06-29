class TransactionsController < ApplicationController

  def index
    @transaction = Transaction.all
  end

  def new
    @transaction = Transaction.new
  end

  def create
    @transaction = Transaction.new(transaction_params)
    fireflyRequest = RestClient.get(firefly_request_url)
    fireflyResponse = JSON.parse fireflyRequest, symbolize_names:true
    @transaction.update_attribute(:auth_code, fireflyResponse.first[:authorization_id_response])
    tokenRequest = RestClient.post(token_request_url)
    tokenResponse = JSON.parse tokenRequest, symbolize_names:true
    @transaction.update_attribute(:token, tokenResponse[:token])
    if @transaction.save
        if @transaction.auth_code.present?
          flash[:success] = "Transaction was approved for #{@transaction.amount}. Your Auth Code is #{@transaction.auth_code}"
          # Post to token
        else
          flash[:danger] = "Transaction Declined"
        end
      redirect_to transactions_path
    else
      flash[:danger] = "Whoops, something went wrong. Try again"
      render :new
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:exp_date, :amount, :full_name, :api_key, )
  end

  def token_request_url
    ""
  end


  def firefly_request_url
   "https://cloud.touchsuite.com/api/mobile/process_manual_credit_card.json?api_key=#{@transaction.api_key}&active=true&authcode=&cc_holder=&amount=#{@transaction.amount}&cardnumber=#{@transaction.card_number}&expiry=#{@transaction.exp_date}"
  end
  # Test Card
  # CC: 3566007770017510
  # EXP: 0416
  # CVV: 123
end
