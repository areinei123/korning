DROP TABLE IF EXISTS employee, customer, product, invoice;

CREATE TABLE employee (
  id SERIAL PRIMARY KEY,
  name varchar(100),
  email varchar(100)
);

CREATE TABLE customer (
  id SERIAL PRIMARY KEY,
  name varchar(100),
  acct_num varchar(100)
);

CREATE TABLE product (
  id SERIAL PRIMARY KEY,
  name varchar(100)
);

CREATE TABLE invoice (
  id SERIAL PRIMARY KEY,
  sale_date varchar(50),
  sale_amount numeric(11,2),
  units_sold integer,
  invoice_num integer ,
  frequency varchar(50),
  employee_id integer REFERENCES employee(id),
  customer_id integer REFERENCES customer(id),
  product_id integer REFERENCES product(id)
);
