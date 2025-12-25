-- ============================================================================
-- POSTGRESQL COMPLETE REFERENCE GUIDE - BEGINNER TO ADVANCED
-- ============================================================================

-- ============================================================================
-- 1. DATABASE OPERATIONS
-- ============================================================================

-- Create database
CREATE DATABASE my_database;

-- Connect to database
\c my_database

-- Drop database
DROP DATABASE my_database;

-- List all databases
\l

-- Show current database
SELECT current_database();

-- ============================================================================
-- 2. TABLE OPERATIONS
-- ============================================================================

-- Create table
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    salary DECIMAL(10, 2),
    hire_date DATE DEFAULT CURRENT_DATE,
    department_id INTEGER,
    is_active BOOLEAN DEFAULT true
);

-- Create table with constraints
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    budget DECIMAL(12, 2) CHECK (budget > 0),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Add foreign key
ALTER TABLE employees 
ADD CONSTRAINT fk_department 
FOREIGN KEY (department_id) 
REFERENCES departments(id) ON DELETE CASCADE;

-- Drop table
DROP TABLE employees;

-- Drop table if exists
DROP TABLE IF EXISTS employees CASCADE;

-- List all tables
\dt

-- Describe table structure
\d employees

-- Rename table
ALTER TABLE employees RENAME TO staff;

-- ============================================================================
-- 3. ALTER TABLE OPERATIONS
-- ============================================================================

-- Add column
ALTER TABLE employees ADD COLUMN phone VARCHAR(20);

-- Drop column
ALTER TABLE employees DROP COLUMN phone;

-- Rename column
ALTER TABLE employees RENAME COLUMN name TO full_name;

-- Change column type
ALTER TABLE employees ALTER COLUMN salary TYPE NUMERIC(12, 2);

-- Add constraint
ALTER TABLE employees ADD CONSTRAINT check_salary CHECK (salary > 0);

-- Drop constraint
ALTER TABLE employees DROP CONSTRAINT check_salary;

-- Set default value
ALTER TABLE employees ALTER COLUMN is_active SET DEFAULT true;

-- Set NOT NULL
ALTER TABLE employees ALTER COLUMN email SET NOT NULL;

-- Drop NOT NULL
ALTER TABLE employees ALTER COLUMN email DROP NOT NULL;

-- ============================================================================
-- 4. INSERT DATA
-- ============================================================================

-- Basic insert
INSERT INTO employees (name, email, salary) 
VALUES ('John Doe', 'john@example.com', 50000);

-- Multiple rows insert
INSERT INTO employees (name, email, salary, department_id) 
VALUES 
    ('Alice Smith', 'alice@example.com', 60000, 1),
    ('Bob Johnson', 'bob@example.com', 55000, 2),
    ('Carol White', 'carol@example.com', 65000, 1);

-- Insert and return values
INSERT INTO employees (name, email, salary) 
VALUES ('David Brown', 'david@example.com', 70000)
RETURNING id, name, hire_date;

-- Insert from SELECT
INSERT INTO employees_backup 
SELECT * FROM employees WHERE salary > 60000;

-- Insert with ON CONFLICT (upsert)
INSERT INTO employees (id, name, email, salary) 
VALUES (1, 'John Doe', 'john@example.com', 55000)
ON CONFLICT (id) 
DO UPDATE SET salary = EXCLUDED.salary;

-- ============================================================================
-- 5. SELECT QUERIES
-- ============================================================================

-- Basic select
SELECT * FROM employees;

-- Select specific columns
SELECT name, email, salary FROM employees;

-- Select with WHERE clause
SELECT * FROM employees WHERE salary > 50000;

-- Multiple conditions (AND, OR)
SELECT * FROM employees 
WHERE salary > 50000 AND department_id = 1;

SELECT * FROM employees 
WHERE department_id = 1 OR department_id = 2;

-- IN operator
SELECT * FROM employees 
WHERE department_id IN (1, 2, 3);

-- BETWEEN operator
SELECT * FROM employees 
WHERE salary BETWEEN 50000 AND 70000;

-- LIKE operator (pattern matching)
SELECT * FROM employees WHERE name LIKE 'John%';
SELECT * FROM employees WHERE email LIKE '%@gmail.com';
SELECT * FROM employees WHERE name ILIKE 'john%'; -- case insensitive

-- IS NULL / IS NOT NULL
SELECT * FROM employees WHERE department_id IS NULL;
SELECT * FROM employees WHERE email IS NOT NULL;

-- DISTINCT
SELECT DISTINCT department_id FROM employees;

-- ORDER BY
SELECT * FROM employees ORDER BY salary DESC;
SELECT * FROM employees ORDER BY department_id ASC, salary DESC;

-- LIMIT and OFFSET (pagination)
SELECT * FROM employees LIMIT 10;
SELECT * FROM employees LIMIT 10 OFFSET 20;

-- ============================================================================
-- 6. UPDATE DATA
-- ============================================================================

-- Basic update
UPDATE employees SET salary = 60000 WHERE id = 1;

-- Update multiple columns
UPDATE employees 
SET salary = 65000, department_id = 2 
WHERE id = 1;

-- Update with calculation
UPDATE employees SET salary = salary * 1.1 WHERE department_id = 1;

-- Update all rows
UPDATE employees SET is_active = true;

-- Update with RETURNING
UPDATE employees 
SET salary = 70000 
WHERE id = 1 
RETURNING *;

-- ============================================================================
-- 7. DELETE DATA
-- ============================================================================

-- Delete specific rows
DELETE FROM employees WHERE id = 1;

-- Delete with condition
DELETE FROM employees WHERE salary < 40000;

-- Delete all rows (but keeps table structure)
DELETE FROM employees;

-- Delete with RETURNING
DELETE FROM employees WHERE id = 1 RETURNING *;

-- TRUNCATE (faster for deleting all rows)
TRUNCATE TABLE employees;
TRUNCATE TABLE employees RESTART IDENTITY CASCADE;

-- ============================================================================
-- 8. AGGREGATE FUNCTIONS
-- ============================================================================

-- COUNT
SELECT COUNT(*) FROM employees;
SELECT COUNT(DISTINCT department_id) FROM employees;

-- SUM
SELECT SUM(salary) FROM employees;

-- AVG
SELECT AVG(salary) FROM employees;

-- MIN / MAX
SELECT MIN(salary), MAX(salary) FROM employees;

-- GROUP BY
SELECT department_id, COUNT(*), AVG(salary) 
FROM employees 
GROUP BY department_id;

-- HAVING (filter after GROUP BY)
SELECT department_id, AVG(salary) as avg_salary
FROM employees 
GROUP BY department_id 
HAVING AVG(salary) > 55000;

-- ============================================================================
-- 9. JOINS
-- ============================================================================

-- INNER JOIN
SELECT e.name, e.salary, d.name as department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.id;

-- LEFT JOIN (LEFT OUTER JOIN)
SELECT e.name, d.name as department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id;

-- RIGHT JOIN (RIGHT OUTER JOIN)
SELECT e.name, d.name as department_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.id;

-- FULL OUTER JOIN
SELECT e.name, d.name as department_name
FROM employees e
FULL OUTER JOIN departments d ON e.department_id = d.id;

-- CROSS JOIN (Cartesian product)
SELECT e.name, d.name 
FROM employees e 
CROSS JOIN departments d;

-- SELF JOIN
SELECT e1.name as employee, e2.name as manager
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.id;

-- Multiple joins
SELECT e.name, d.name as dept, c.city
FROM employees e
JOIN departments d ON e.department_id = d.id
JOIN cities c ON d.city_id = c.id;

-- ============================================================================
-- 10. SUBQUERIES
-- ============================================================================

-- Subquery in WHERE
SELECT name, salary 
FROM employees 
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Subquery with IN
SELECT name 
FROM employees 
WHERE department_id IN (
    SELECT id FROM departments WHERE budget > 100000
);

-- Subquery in SELECT
SELECT name, 
       salary,
       (SELECT AVG(salary) FROM employees) as avg_salary
FROM employees;

-- Correlated subquery
SELECT e1.name, e1.salary
FROM employees e1
WHERE salary > (
    SELECT AVG(salary) 
    FROM employees e2 
    WHERE e2.department_id = e1.department_id
);

-- EXISTS
SELECT name FROM employees e
WHERE EXISTS (
    SELECT 1 FROM departments d 
    WHERE d.id = e.department_id AND d.budget > 50000
);

-- ============================================================================
-- 11. VIEWS
-- ============================================================================

-- Create view
CREATE VIEW high_earners AS
SELECT name, email, salary 
FROM employees 
WHERE salary > 60000;

-- Query view
SELECT * FROM high_earners;

-- Create or replace view
CREATE OR REPLACE VIEW high_earners AS
SELECT name, email, salary, department_id
FROM employees 
WHERE salary > 60000;

-- Materialized view (stores results physically)
CREATE MATERIALIZED VIEW dept_summary AS
SELECT department_id, COUNT(*) as emp_count, AVG(salary) as avg_salary
FROM employees
GROUP BY department_id;

-- Refresh materialized view
REFRESH MATERIALIZED VIEW dept_summary;

-- Drop view
DROP VIEW high_earners;

-- ============================================================================
-- 12. INDEXES
-- ============================================================================

-- Create index
CREATE INDEX idx_employee_email ON employees(email);

-- Create unique index
CREATE UNIQUE INDEX idx_employee_email_unique ON employees(email);

-- Multi-column index
CREATE INDEX idx_dept_salary ON employees(department_id, salary);

-- Partial index
CREATE INDEX idx_active_employees ON employees(name) WHERE is_active = true;

-- Expression index
CREATE INDEX idx_lower_email ON employees(LOWER(email));

-- List indexes
\di

-- Drop index
DROP INDEX idx_employee_email;

-- ============================================================================
-- 13. TRANSACTIONS
-- ============================================================================

-- Begin transaction
BEGIN;

UPDATE employees SET salary = salary + 5000 WHERE id = 1;
INSERT INTO audit_log (action, employee_id) VALUES ('salary_update', 1);

-- Commit transaction
COMMIT;

-- Rollback transaction
BEGIN;
DELETE FROM employees WHERE id = 1;
ROLLBACK;

-- Savepoints
BEGIN;
INSERT INTO employees (name) VALUES ('Test User');
SAVEPOINT my_savepoint;
DELETE FROM employees WHERE name = 'Test User';
ROLLBACK TO my_savepoint;
COMMIT;

-- ============================================================================
-- 14. COMMON TABLE EXPRESSIONS (CTE)
-- ============================================================================

-- Basic CTE
WITH high_salary_emps AS (
    SELECT * FROM employees WHERE salary > 60000
)
SELECT name, salary FROM high_salary_emps;

-- Multiple CTEs
WITH 
dept_avg AS (
    SELECT department_id, AVG(salary) as avg_sal
    FROM employees
    GROUP BY department_id
),
high_depts AS (
    SELECT * FROM dept_avg WHERE avg_sal > 55000
)
SELECT * FROM high_depts;

-- Recursive CTE (organizational hierarchy)
WITH RECURSIVE employee_hierarchy AS (
    SELECT id, name, manager_id, 1 as level
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    SELECT e.id, e.name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.id
)
SELECT * FROM employee_hierarchy;

-- ============================================================================
-- 15. WINDOW FUNCTIONS
-- ============================================================================

-- ROW_NUMBER
SELECT name, salary, 
       ROW_NUMBER() OVER (ORDER BY salary DESC) as rank
FROM employees;

-- RANK and DENSE_RANK
SELECT name, salary,
       RANK() OVER (ORDER BY salary DESC) as rank,
       DENSE_RANK() OVER (ORDER BY salary DESC) as dense_rank
FROM employees;

-- PARTITION BY
SELECT name, department_id, salary,
       ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) as dept_rank
FROM employees;

-- LAG and LEAD
SELECT name, salary,
       LAG(salary) OVER (ORDER BY hire_date) as prev_salary,
       LEAD(salary) OVER (ORDER BY hire_date) as next_salary
FROM employees;

-- Running total
SELECT name, salary,
       SUM(salary) OVER (ORDER BY hire_date) as running_total
FROM employees;

-- NTILE (divide into quartiles)
SELECT name, salary,
       NTILE(4) OVER (ORDER BY salary) as quartile
FROM employees;

-- ============================================================================
-- 16. STRING FUNCTIONS
-- ============================================================================

-- Concatenation
SELECT CONCAT(first_name, ' ', last_name) as full_name FROM employees;
SELECT first_name || ' ' || last_name as full_name FROM employees;

-- UPPER / LOWER
SELECT UPPER(name), LOWER(email) FROM employees;

-- SUBSTRING
SELECT SUBSTRING(name FROM 1 FOR 5) FROM employees;
SELECT SUBSTRING(name, 1, 5) FROM employees;

-- LENGTH
SELECT name, LENGTH(name) FROM employees;

-- TRIM
SELECT TRIM('  hello  ');
SELECT LTRIM('  hello'), RTRIM('hello  ');

-- REPLACE
SELECT REPLACE(email, '@example.com', '@newdomain.com') FROM employees;

-- SPLIT_PART
SELECT SPLIT_PART(email, '@', 1) as username FROM employees;

-- POSITION
SELECT POSITION('@' IN email) FROM employees;

-- LEFT / RIGHT
SELECT LEFT(name, 3), RIGHT(name, 3) FROM employees;

-- ============================================================================
-- 17. DATE AND TIME FUNCTIONS
-- ============================================================================

-- Current date/time
SELECT NOW();
SELECT CURRENT_DATE;
SELECT CURRENT_TIME;
SELECT CURRENT_TIMESTAMP;

-- Extract parts
SELECT EXTRACT(YEAR FROM hire_date) FROM employees;
SELECT EXTRACT(MONTH FROM hire_date) FROM employees;
SELECT DATE_PART('year', hire_date) FROM employees;

-- Date arithmetic
SELECT hire_date + INTERVAL '1 year' FROM employees;
SELECT hire_date - INTERVAL '30 days' FROM employees;
SELECT NOW() - hire_date as time_employed FROM employees;

-- Age calculation
SELECT AGE(NOW(), hire_date) FROM employees;

-- Format date
SELECT TO_CHAR(hire_date, 'YYYY-MM-DD') FROM employees;
SELECT TO_CHAR(NOW(), 'Month DD, YYYY') FROM employees;

-- Parse date
SELECT TO_DATE('2024-01-15', 'YYYY-MM-DD');
SELECT TO_TIMESTAMP('2024-01-15 14:30:00', 'YYYY-MM-DD HH24:MI:SS');

-- Date truncate
SELECT DATE_TRUNC('month', hire_date) FROM employees;

-- ============================================================================
-- 18. CONDITIONAL EXPRESSIONS
-- ============================================================================

-- CASE
SELECT name, salary,
    CASE 
        WHEN salary < 40000 THEN 'Low'
        WHEN salary BETWEEN 40000 AND 60000 THEN 'Medium'
        ELSE 'High'
    END as salary_category
FROM employees;

-- Simple CASE
SELECT name,
    CASE department_id
        WHEN 1 THEN 'Sales'
        WHEN 2 THEN 'Engineering'
        WHEN 3 THEN 'HR'
        ELSE 'Other'
    END as department_name
FROM employees;

-- COALESCE (returns first non-null value)
SELECT name, COALESCE(phone, email, 'No contact') as contact FROM employees;

-- NULLIF (returns NULL if values are equal)
SELECT NULLIF(salary, 0) FROM employees;

-- ============================================================================
-- 19. ARRAY OPERATIONS
-- ============================================================================

-- Create table with array
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    tags TEXT[]
);

-- Insert array data
INSERT INTO products (name, tags) 
VALUES ('Laptop', ARRAY['electronics', 'computers', 'tech']);

-- Array functions
SELECT * FROM products WHERE 'electronics' = ANY(tags);
SELECT * FROM products WHERE tags @> ARRAY['electronics'];
SELECT array_length(tags, 1) FROM products;
SELECT unnest(tags) FROM products;

-- ============================================================================
-- 20. JSON OPERATIONS
-- ============================================================================

-- Create table with JSON
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    metadata JSONB
);

-- Insert JSON data
INSERT INTO users (name, metadata) 
VALUES ('John', '{"age": 30, "city": "NYC", "hobbies": ["reading", "gaming"]}');

-- Query JSON
SELECT metadata->>'age' FROM users;
SELECT metadata->'hobbies'->0 FROM users;
SELECT * FROM users WHERE metadata->>'city' = 'NYC';
SELECT * FROM users WHERE metadata @> '{"age": 30}';

-- JSON functions
SELECT jsonb_object_keys(metadata) FROM users;
SELECT jsonb_array_elements(metadata->'hobbies') FROM users;

-- ============================================================================
-- 21. FULL TEXT SEARCH
-- ============================================================================

-- Create tsvector column
ALTER TABLE products ADD COLUMN search_vector tsvector;

-- Update search vector
UPDATE products 
SET search_vector = to_tsvector('english', name || ' ' || description);

-- Create index
CREATE INDEX idx_search ON products USING GIN(search_vector);

-- Search
SELECT * FROM products 
WHERE search_vector @@ to_tsquery('english', 'laptop & gaming');

-- Rank results
SELECT *, ts_rank(search_vector, query) as rank
FROM products, to_tsquery('laptop') query
WHERE search_vector @@ query
ORDER BY rank DESC;

-- ============================================================================
-- 22. STORED PROCEDURES AND FUNCTIONS
-- ============================================================================

-- Create function
CREATE OR REPLACE FUNCTION get_employee_count()
RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM employees);
END;
$$ LANGUAGE plpgsql;

-- Call function
SELECT get_employee_count();

-- Function with parameters
CREATE OR REPLACE FUNCTION give_raise(emp_id INTEGER, raise_amount DECIMAL)
RETURNS VOID AS $$
BEGIN
    UPDATE employees SET salary = salary + raise_amount WHERE id = emp_id;
END;
$$ LANGUAGE plpgsql;

-- Call with parameters
SELECT give_raise(1, 5000);

-- Function returning table
CREATE OR REPLACE FUNCTION get_high_earners(min_salary DECIMAL)
RETURNS TABLE(emp_name VARCHAR, emp_salary DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT name, salary FROM employees WHERE salary > min_salary;
END;
$$ LANGUAGE plpgsql;

-- Call table function
SELECT * FROM get_high_earners(60000);

-- Create procedure (PostgreSQL 11+)
CREATE OR REPLACE PROCEDURE update_salaries(raise_percent DECIMAL)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE employees SET salary = salary * (1 + raise_percent / 100);
    COMMIT;
END;
$$;

-- Call procedure
CALL update_salaries(5);

-- ============================================================================
-- 23. TRIGGERS
-- ============================================================================

-- Create audit table
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(50),
    operation VARCHAR(10),
    changed_at TIMESTAMP DEFAULT NOW()
);

-- Create trigger function
CREATE OR REPLACE FUNCTION log_employee_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (table_name, operation)
    VALUES (TG_TABLE_NAME, TG_OP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER employee_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employee_changes();

-- Drop trigger
DROP TRIGGER employee_audit_trigger ON employees;

-- ============================================================================
-- 24. CONSTRAINTS
-- ============================================================================

-- PRIMARY KEY
CREATE TABLE test (id INTEGER PRIMARY KEY);

-- UNIQUE
CREATE TABLE test (email VARCHAR(100) UNIQUE);

-- NOT NULL
CREATE TABLE test (name VARCHAR(100) NOT NULL);

-- CHECK
CREATE TABLE test (
    age INTEGER CHECK (age >= 18),
    salary DECIMAL CHECK (salary > 0)
);

-- FOREIGN KEY
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id) ON DELETE CASCADE
);

-- Multiple column constraint
CREATE TABLE test (
    CHECK (start_date < end_date)
);

-- ============================================================================
-- 25. SEQUENCES
-- ============================================================================

-- Create sequence
CREATE SEQUENCE employee_id_seq START 1000;

-- Use sequence
INSERT INTO employees (id, name) 
VALUES (nextval('employee_id_seq'), 'John Doe');

-- Get current value
SELECT currval('employee_id_seq');

-- Set sequence value
SELECT setval('employee_id_seq', 2000);

-- Drop sequence
DROP SEQUENCE employee_id_seq;

-- ============================================================================
-- 26. PARTITIONING
-- ============================================================================

-- Range partitioning
CREATE TABLE sales (
    id SERIAL,
    sale_date DATE NOT NULL,
    amount DECIMAL
) PARTITION BY RANGE (sale_date);

-- Create partitions
CREATE TABLE sales_2023 PARTITION OF sales
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE sales_2024 PARTITION OF sales
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- List partitioning
CREATE TABLE customers (
    id SERIAL,
    name VARCHAR(100),
    country VARCHAR(2)
) PARTITION BY LIST (country);

CREATE TABLE customers_us PARTITION OF customers FOR VALUES IN ('US');
CREATE TABLE customers_uk PARTITION OF customers FOR VALUES IN ('UK');

-- ============================================================================
-- 27. USER AND PERMISSION MANAGEMENT
-- ============================================================================

-- Create user
CREATE USER john_doe WITH PASSWORD 'secure_password';

-- Grant privileges
GRANT SELECT, INSERT ON employees TO john_doe;
GRANT ALL PRIVILEGES ON DATABASE my_database TO john_doe;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO john_doe;

-- Revoke privileges
REVOKE INSERT ON employees FROM john_doe;

-- Create role
CREATE ROLE readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;
GRANT readonly TO john_doe;

-- Drop user
DROP USER john_doe;

-- ============================================================================
-- 28. BACKUP AND RESTORE
-- ============================================================================

-- Backup (command line)
-- pg_dump -U username -d database_name -f backup.sql

-- Backup specific table
-- pg_dump -U username -d database_name -t employees -f employees_backup.sql

-- Restore
-- psql -U username -d database_name -f backup.sql

-- Backup in custom format
-- pg_dump -U username -d database_name -Fc -f backup.dump

-- Restore custom format
-- pg_restore -U username -d database_name backup.dump

-- ============================================================================
-- 29. PERFORMANCE OPTIMIZATION
-- ============================================================================

-- EXPLAIN (show query plan)
EXPLAIN SELECT * FROM employees WHERE salary > 50000;

-- EXPLAIN ANALYZE (execute and show actual performance)
EXPLAIN ANALYZE SELECT * FROM employees WHERE salary > 50000;

-- VACUUM (clean up dead tuples)
VACUUM employees;
VACUUM FULL employees;

-- ANALYZE (update statistics)
ANALYZE employees;

-- REINDEX
REINDEX TABLE employees;

-- Check table size
SELECT pg_size_pretty(pg_total_relation_size('employees'));

-- Check database size
SELECT pg_size_pretty(pg_database_size('my_database'));

-- ============================================================================
-- 30. IMPORT/EXPORT DATA
-- ============================================================================

-- Export to CSV
COPY employees TO '/path/to/employees.csv' WITH CSV HEADER;

-- Import from CSV
COPY employees FROM '/path/to/employees.csv' WITH CSV HEADER;

-- Export specific columns
COPY (SELECT name, email FROM employees) TO '/path/to/output.csv' WITH CSV;

-- Import with delimiter
COPY employees FROM '/path/to/data.txt' WITH (DELIMITER '|');

-- ============================================================================
-- 31. ADVANCED QUERY TECHNIQUES
-- ============================================================================

-- UNION (combine results, remove duplicates)
SELECT name FROM employees
UNION
SELECT name FROM contractors;

-- UNION ALL (combine results, keep duplicates)
SELECT name FROM employees
UNION ALL
SELECT name FROM contractors;

-- INTERSECT (common rows)
SELECT email FROM employees
INTERSECT
SELECT email FROM subscribers;

-- EXCEPT (rows in first query but not in second)
SELECT email FROM employees
EXCEPT
SELECT email FROM unsubscribed;

-- LATERAL join
SELECT d.name, e.*
FROM departments d,
LATERAL (
    SELECT * FROM employees 
    WHERE department_id = d.id 
    ORDER BY salary DESC 
    LIMIT 3
) e;

-- ============================================================================
-- 32. SYSTEM INFORMATION
-- ============================================================================

-- PostgreSQL version
SELECT version();

-- Current user
SELECT current_user;

-- List all schemas
\dn

-- List all functions
\df

-- Show table information
SELECT * FROM information_schema.tables WHERE table_schema = 'public';

-- Show column information
SELECT * FROM information_schema.columns WHERE table_name = 'employees';

-- Active connections
SELECT * FROM pg_stat_activity;

-- Database statistics
SELECT * FROM pg_stat_database;

-- ============================================================================
-- END OF POSTGRESQL REFERENCE GUIDE
-- ============================================================================