
require "pg"
require "csv"
require 'pry'

system 'psql korning < schema.sql'

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

table = CSV.read('sales.csv', headers: true, header_converters: :symbol)

frequency_arr = table[:invoice_frequency].uniq
employee = table[:employee].uniq

employee_name = []
employee_email = []

employee.each do |value|
  employee_name << "#{value.gsub(/[()]/, "").split(' ')[0]} #{value.gsub(/[()]/, "").split(' ')[1]}"
  employee_email << "#{value.gsub(/[()]/, "").split(' ')[2]}"
end


employee_hash = Hash[employee_name.zip(employee_email)]

customer = table[:customer_and_account_no].uniq

customer_name = []
customer_account_no = []

customer.each do |value|
  customer_name << "#{value.gsub(/[()]/, "").split(' ')[0]}"
  customer_account_no << "#{value.gsub(/[()]/, "").split(' ')[1]}"
end

customer_hash = Hash[customer_name.zip(customer_account_no)]


db_connection do |conn|

  frequency_arr.each do |frequency|
    conn.exec_params("INSERT INTO frequencies (frequency) VALUES ($1)", [frequency])
  end

  employee_hash.each do |name, email|
    conn.exec_params("INSERT INTO employees (name, email) VALUES ($1, $2)", [name, email])
  end

  customer_hash.each do |name, account_no|
    conn.exec_params("INSERT INTO customers (name, account_no) VALUES ($1, $2)", [name, account_no])
  end

  table.each do |sale|
    customer = sale.to_hash[:customer_and_account_no].split(' ').first
    customer_id = conn.exec("SELECT id FROM customers WHERE name = ($1)", [customer])

    employee = sale.to_hash[:employee].split(" (").first
    employee_id = conn.exec("SELECT id FROM employees WHERE name = ($1)", [employee])

    frequency = sale.to_hash[:invoice_frequency]
    frequency_id = conn.exec("SELECT id FROM frequencies WHERE frequency = ($1)", [frequency])

    conn.exec_params("INSERT INTO sales (
    customer_id,
    employee_id,
    frequency_id,
    product_name,
    sale_date,
    sale_amount,
    units_sold,
    invoice_no
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8)",
    [
      customer_id[0]["id"].to_i,
      employee_id[0]["id"].to_i,
      frequency_id[0]["id"].to_i,
      sale[:product_name],
      sale[:sale_date],
      sale[:sale_amount],
      sale[:units_sold],
      sale[:invoice_no]
      ]
      );
  end
end
