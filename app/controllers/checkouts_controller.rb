class CheckoutsController < ApplicationController
  TRANSACTION_SUCCESS_STATUSES = [
    Braintree::Transaction::Status::Authorizing,
    Braintree::Transaction::Status::Authorized,
    Braintree::Transaction::Status::Settled,
    Braintree::Transaction::Status::SettlementConfirmed,
    Braintree::Transaction::Status::SettlementPending,
    Braintree::Transaction::Status::Settling,
    Braintree::Transaction::Status::SubmittedForSettlement,
  ]

  def new
    @client_token = Braintree::ClientToken.generate
  end

  def index
    transaction_ids = Braintree::Transaction.search do |search|
      search.customer_id.is "#{params[:customer_id]}"
    end
    @transactions = []
    if transaction_ids.ids.count > 50
      tran_ids = transaction_ids.ids.last(50) 
    else
      tran_ids = transaction_ids.ids 
    end
    tran_ids.each do |tran_id|
      @transactions << Braintree::Transaction.find(tran_id)
    end
  end

  def show
    @transaction = Braintree::Transaction.find(params[:id])
    @result = _create_result_hash(@transaction)
  end

  def create
    customer_name = params["customer_name"]
    amount = params["amount"] # In production you should not take amounts directly from clients
    nonce = params["payment_method_nonce"]

    result = Braintree::Transaction.sale(
      amount: params[:amount],
      payment_method_nonce: params[:payment_method_nonce],
      customer: {
        first_name: params[:first_name],
        last_name: params[:last_name],
        email: params[:email]
      },
      billing: {
        street_address: params[:street_address],
        extended_address: params[:extended_address],
        locality: params[:locality],
        region: params[:region],
        postal_code: params[:postal_code],
        country_code_alpha2: params[:country_code]
      },
      options: {
        submit_for_settlement: true
      }
    )


    if result.success? || result.transaction
      redirect_to checkout_path(result.transaction.id)
    else
      error_messages = result.errors.map { |error| "Error: #{error.code}: #{error.message}" }
      flash[:error] = error_messages
      redirect_to new_checkout_path
    end
  end

  def _create_result_hash(transaction)
    status = transaction.status

    if TRANSACTION_SUCCESS_STATUSES.include? status
      result_hash = {
        :header => "Sweet Success!",
        :icon => "success",
        :message => "Your test transaction has been successfully processed. See the Braintree API response and try again."
      }
    else
      result_hash = {
        :header => "Transaction Failed",
        :icon => "fail",
        :message => "Your test transaction has a status of #{status}. See the Braintree API response and try again."
      }
    end
  end
end
