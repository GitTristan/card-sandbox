class TransactionsController < ApplicationController

  def index
    @transaction = Transaction.all
  end

  def new
    @transaction = Transaction.new
  end

  def create
    @transaction = Transaction.new(transaction_params)
    if @transaction.save
      fireflyRequest = RestClient.get("https://cloud.touchsuite.com/api/mobile/process_manual_credit_card.json?api_key=046AAA0614C811E389AED4BED9E2D958&active=true&authcode=&cc_holder=&amount=#{@transaction.amount}&cardnumber=#{@transaction.card_number}&expiry=#{@transaction.exp_date}")
      json = JSON.parse fireflyRequest, symbolize_names:true
      @transaction.update_attribute(:auth_code, json.first[:authorization_id_response])
      flash[:notice] = "transaction was approved for #{@transaction.amount}. Your Auth Code is #{@transaction.auth_code}"
      redirect_to transactions_path
    else
      render :new
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:card_number, :exp_date, :cvv, :amount)
  end

end