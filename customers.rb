
require 'pry'
require 'csv'

table = CSV.read('sales.csv', headers: true, header_converters: :symbol)


class Customers

  attr_reader :customer, :account_no

  def initialize(table)
    @customer = table[:customer_and_account_no]
    @account_no = table[:customer_and_account_no] #.match(/\(([^)]+)\)/)
  end

end


customer = Customers.new(table)

puts customer.customer

binding.pry
