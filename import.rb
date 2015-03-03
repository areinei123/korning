# Use this file to import the sales information into the
# the database.

require "pg"
require "pry"
require "csv"

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

invoices = []
employees_db = []
customers_db = []
products_db = []
invoices_db = []

def get_id(db_name,name_value)
  db_name.each do |row|
      return row[:id] if row[:name] == name_value
  end
  nil
end

CSV.foreach('sales.csv', headers:true, header_converters: :symbol) do |row|
   invoices << row.to_hash
end

invoices.each do |hash|
  employee_row = {name: '', email: ''}
  employees = hash[:employee].split(' (')
  employee_row[:name] = employees[0]
  employee_row[:email] = employees[1].gsub(')', '')
  employees_db << employee_row unless employees_db.include?(employee_row)

  customer_row = {name: '', acct_num: ''}
  customers = hash[:customer_and_account_no].split(' (')
  customer_row[:name] = customers[0]
  customer_row[:acct_num] = customers[1].gsub(')', '')
  customers_db << customer_row unless customers_db.include?(customer_row)

  product_row = {name: ''}
  product_row[:name] = hash[:product_name]
  products_db << product_row unless products_db.include?(product_row)
end

employees_db.each_with_index { |hash, index| hash[:id] = index+1 }
customers_db.each_with_index { |hash, index| hash[:id] = index+1 }
products_db.each_with_index { |hash, index| hash[:id] = index+1 }

invoices.each do |hash|
  invoice_row = {sale_date: '', sale_amount: '', units_sold: '', invoice_num: '', frequency: '', employee_id: '', customer_id: '', product_id: ''}
  invoice_row[:sale_date] = hash[:sale_date]
  invoice_row[:sale_amount] = hash[:sale_amount].gsub('$', '')
  invoice_row[:units_sold] = hash[:units_sold]
  invoice_row[:invoice_num] = hash[:invoice_no]
  invoice_row[:frequency] = hash[:invoice_frequency]

  employees = hash[:employee].split(' (')
  emp_name = employees[0]
  invoice_row[:employee_id] = get_id(employees_db,emp_name)

  customers = hash[:customer_and_account_no].split(' (')
  cus_name = customers.first
  invoice_row[:customer_id] = get_id(customers_db,cus_name)

  prod_name = hash[:product_name]
  invoice_row[:product_id] = get_id(products_db,prod_name)

  invoices_db << invoice_row
end

db_connection do |conn|
  employees_db.each do |hash|
    conn.exec_params("INSERT INTO employee (name, email) VALUES ($1, $2)", ([hash[:name], hash[:email]]))
  end
end

db_connection do |conn|
  customers_db.each do |hash|
    conn.exec_params("INSERT INTO customer (name, acct_num) VALUES ($1, $2)", ([hash[:name], hash[:acct_num]]))
  end
end

db_connection do |conn|
  products_db.each do |hash|
    conn.exec_params("INSERT INTO product (name) VALUES ($1)", ([hash[:name]]))
  end
end

db_connection do |conn|
  invoices_db.each do |hash|
    conn.exec_params("INSERT INTO invoice (sale_date, sale_amount, units_sold, invoice_num, frequency, employee_id, customer_id, product_id)
                      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)",
                      ([hash[:sale_date], hash[:sale_amount], hash[:units_sold],
                      hash[:invoice_num], hash[:frequency], hash[:employee_id],
                      hash[:customer_id], hash[:product_id]]))
  end
end
