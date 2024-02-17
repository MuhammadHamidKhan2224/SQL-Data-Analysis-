CREATE DATABASE employee;
use employee; 

CREATE TABLE employee (
    ID INT PRIMARY KEY,
	 first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INT,
    job_title VARCHAR(100),
    date_of_birth DATE,
    phone_number bigint,
    insurance_id VARCHAR(15)
);

INSERT INTO employee(ID, first_name, last_name, age, job_title, date_of_birth, phone_number, insurance_id) 
VALUES 
(101, 'Smith', 'John', 32, 'Manager', '1989-05-12', '5551234567', 'INS736'),
(102, 'Johnson', 'Sarah', 28, 'Analyst', '1993-09-20', '5559876543', 'INS832'),
(103, 'Davis', 'David', 45, 'HR', '1976-02-03', '5550555995', 'INS007'),
(104, 'Brown', 'Emily', 37, 'Lawyer', '1984-11-15', '5551112022', 'INS035'),
(105, 'Wilson', 'Michael', 41, 'Accountant', '1980-07-28', '5554403003', 'INS943'),
(106, 'Anderson', 'Lisa', 22, 'Intern', '1999-03-10', '555666777', 'INS332'),
(107, 'Thompson', 'Alex', 29, 'Sales Representative', '1992-07-28', '5552120111', 'INS433');

CREATE TABLE employee_insurance(
insurance_id VARCHAR  (15) PRIMARY KEY,
insurance_info VARCHAR (100));



INSERT INTO employee_insurance(insurance_id, insurance_info)
VALUES('INS736', 'unavailable'),
('INS832', 'unavailable'),
('INS007', 'unavailable'),
('INS035', 'unavailable'),
('INS943', 'unavailable'),
('INS332', 'unavailable'),
('INS433', 'unavailable');

ALTER TABLE employee
ADD CONSTRAINT fk_insurance_id
FOREIGN KEY (insurance_id) REFERENCES employee_insurance(insurance_id);

select *from employee_insurance;

ALTER TABLE employee
ADD email VARCHAR(50);
 
  UPDATE employee
SET email = 'unavailable';


select*from employee;

select*from employee_insurance;