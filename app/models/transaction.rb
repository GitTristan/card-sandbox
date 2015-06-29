class Transaction < ActiveRecord::Base

  validates :card_number, :cvv, :exp_date, :full_name, :amount, presence: true
  validates :card_number, length: {minimum: 15, maximum: 16}

  attr_accessor :card_number, :cvv

end
