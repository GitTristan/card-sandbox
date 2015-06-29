class RemoveCcFromTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :token, :string

    remove_column :transactions, :card_number, :string
    remove_column :transactions, :cvv, :string
  end
end
