
create table customers(
cust_id serial primary key,
cust_name varchar(100) not null
)

create table orders(
ord_id serial primary key,
ord_date date not null default current_date,
price numeric not null,
cust_id int not null,
foreign key(cust_id) references 
customers(cust_id)
)

insert into customers (cust_name) values
('raju'),
('ajharul')

insert into orders (price, cust_id) values
(250.00, 1),
(300.00, 1)
select * from orders

select c.cust_name, count(o.ord_id) from customers c
inner join
orders o
on c.cust_id = o.cust_id
group by cust_name;



select * from customers c
left join
orders o
on c.cust_id = o.cust_id










CREATE TABLE students (
    s_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

INSERT INTO Students (name) VALUES
('Raju'),
('Sham'),
('Alex');




CREATE TABLE courses (
    c_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    fee NUMERIC NOT NULL
);

INSERT INTO courses (name, fee)
VALUES
('Mathematics', 500.00),
('Physics', 600.00),
('Chemistry', 700.00);



CREATE TABLE enrollment (
    enrollment_id SERIAL PRIMARY KEY,
    s_id INT NOT NULL,
    c_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    FOREIGN KEY (s_id) REFERENCES students(s_id),
    FOREIGN KEY (c_id) REFERENCES courses(c_id)
);

INSERT INTO enrollment (s_id, c_id, enrollment_date)
VALUES
(1, 1, '2024-01-01'), -- Raju enrolled in Mathematics
(1, 2, '2024-01-15'), -- Raju enrolled in Physics
(2, 1, '2024-02-01'), -- Sham enrolled in Mathematics
(2, 3, '2024-02-15'), -- Sham enrolled in Chemistry
(3, 3, '2024-03-25'); -- Alex enrolled in Chemistry


SELECT
    e.enrollment_id,
    s.name AS student_name,
    c.name AS course_name,
    c.fee,
    e.enrollment_date
FROM
    enrollment e
JOIN
    students s ON e.s_id = s.s_id
JOIN
    courses c ON e.c_id = c.c_id;


