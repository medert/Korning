

DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS frequencies CASCADE;
DROP TABLE IF EXISTS sales CASCADE;


CREATE TABLE customers(
  id SERIAL PRIMARY KEY,
  name VARCHAR(200),
  account_no VARCHAR(200)
);

CREATE TABLE employees(
  id SERIAL PRIMARY KEY,
  name VARCHAR(200),
  email VARCHAR(200)
);

CREATE TABLE frequencies(
  id SERIAL PRIMARY KEY,
  frequency VARCHAR(200)
);

CREATE TABLE sales(
  sale_id SERIAL PRIMARY KEY,
  customer_id INTEGER REFERENCES customers(id),
  employee_id INTEGER REFERENCES employees(id),
  frequency_id INTEGER REFERENCES frequencies(id),
  product_name VARCHAR(200),
  sale_date DATE,
  sale_amount VARCHAR(100),
  units_sold INTEGER,
  invoice_no VARCHAR(100)
);
