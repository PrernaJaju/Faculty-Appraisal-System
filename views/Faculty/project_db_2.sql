
DROP DATABASE IF EXISTS project2;
CREATE DATABASE project2;
USE project2;

-- Table for institute master
CREATE TABLE institution_master (
    id INT AUTO_INCREMENT PRIMARY KEY,
    institution_id VARCHAR(50) UNIQUE,
    institution_name VARCHAR(250),
    location varchar(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive') DEFAULT 'active'
);

DELIMITER //
CREATE TRIGGER before_insert_institution_master
BEFORE INSERT ON institution_master
FOR EACH ROW
BEGIN
    DECLARE next_id INT;
    SET next_id = (SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'institution_master');
    SET NEW.institution_id = CONCAT('INS', next_id);
END//
DELIMITER ;

-- Table for department master
CREATE TABLE department_master (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dept_id VARCHAR(50) UNIQUE,
    department_name VARCHAR(40),
    institution_id VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive') DEFAULT 'active',
    FOREIGN KEY (institution_id) REFERENCES institution_master(institution_id)
);

DELIMITER //
CREATE TRIGGER before_insert_department_master
BEFORE INSERT ON department_master
FOR EACH ROW
BEGIN
    DECLARE next_id INT;
    SET next_id = (SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'department_master');
    SET NEW.dept_id = CONCAT('DEPT', next_id);
END//
DELIMITER ;

-- Table for user type master
CREATE TABLE user_type_master (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_type_id VARCHAR(50) UNIQUE,
    password VARCHAR(255),
    user_type_type ENUM('admin', 'superAdmin', 'employee', 'committee') DEFAULT 'employee',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive') DEFAULT 'active'
);

DELIMITER //
CREATE TRIGGER before_insert_user_type_master
BEFORE INSERT ON user_type_master
FOR EACH ROW
BEGIN
    DECLARE next_id INT;
    SET next_id = (SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'user_type_master');
    SET NEW.user_type_id = CONCAT('USERTY', next_id);
END//
DELIMITER ;

-- Table for user master
CREATE TABLE user_master (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) UNIQUE,
    first_name VARCHAR(20),
    middle_name VARCHAR(20),
    last_name VARCHAR(20),
    email_id VARCHAR(40) UNIQUE,
    contact_no VARCHAR(10),
    pan_card_no VARCHAR(10) UNIQUE,
    addhar_no VARCHAR(12) UNIQUE,
    emp_id VARCHAR(50),
    institution_id VARCHAR(50),
    dept_id VARCHAR(50),
    user_type_id VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive') DEFAULT 'active',
    FOREIGN KEY (institution_id) REFERENCES institution_master(institution_id),
    FOREIGN KEY (dept_id) REFERENCES department_master(dept_id),
    FOREIGN KEY (user_type_id) REFERENCES user_type_master(user_type_id)
);

DELIMITER //
CREATE TRIGGER before_insert_user_master
BEFORE INSERT ON user_master
FOR EACH ROW
BEGIN
    DECLARE next_id INT;
    SET next_id = (SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'user_master');
    SET NEW.user_id = CONCAT('USR', next_id);
END//
DELIMITER ;

-- Table for criteria master
CREATE TABLE criteria_master (
    id INT AUTO_INCREMENT PRIMARY KEY,
    criteria_id VARCHAR(50) UNIQUE,
    criteria_description VARCHAR(40),
    max_marks INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive') DEFAULT 'active'
);

DELIMITER //
CREATE TRIGGER before_insert_criteria_master
BEFORE INSERT ON criteria_master
FOR EACH ROW
BEGIN
    DECLARE next_id INT;
    SET next_id = (SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'criteria_master');
    SET NEW.criteria_id = CONCAT('CRIT', next_id);
END//
DELIMITER ;

-- Table for criteria parameter master
CREATE TABLE c_parameter_master (
    id INT AUTO_INCREMENT PRIMARY KEY,
    c_parameter_id VARCHAR(50) UNIQUE,
    parameter_description VARCHAR(250),
    parameter_max_marks INT,
    criteria_id VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive') DEFAULT 'active',
    FOREIGN KEY (criteria_id) REFERENCES criteria_master(criteria_id)
);

DELIMITER //
CREATE TRIGGER before_insert_c_parameter_master
BEFORE INSERT ON c_parameter_master
FOR EACH ROW
BEGIN
    DECLARE next_id INT;
    SET next_id = (SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'c_parameter_master');
    SET NEW.c_parameter_id = CONCAT('C_PARA', next_id);
END//
DELIMITER ;

-- Table for self appraisal score master
CREATE TABLE self_appraisal_score_master (
    id INT AUTO_INCREMENT PRIMARY KEY,
    record_id VARCHAR(50) UNIQUE,
    user_id VARCHAR(50),
    marks_by_emp INT,   
    c_parameter_id VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive') DEFAULT 'active',
    FOREIGN KEY (user_id) REFERENCES user_master(user_id),
    FOREIGN KEY (c_parameter_id) REFERENCES c_parameter_master(c_parameter_id)
);

DELIMITER //
CREATE TRIGGER before_insert_self_appraisal_score_master
BEFORE INSERT ON self_appraisal_score_master
FOR EACH ROW
BEGIN
    DECLARE next_id INT;
    SET next_id = (SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'self_appraisal_score_master');
    SET NEW.record_id = CONCAT('SASM', next_id);
END//
DELIMITER ;

-- Function to get employee user_id
DELIMITER //
CREATE FUNCTION get_employee_user_id (user_id VARCHAR(50)) RETURNS VARCHAR(50)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE emp_user_id VARCHAR(50);
    SELECT user_id INTO emp_user_id
    FROM user_master
    WHERE user_id = user_id AND user_type_id IN (SELECT user_type_id FROM user_type_master WHERE user_type_type = 'employee');
    RETURN emp_user_id;
END//
DELIMITER ;

-- Function to get committee user_id
DELIMITER //
CREATE FUNCTION get_committee_user_id (user_id VARCHAR(50)) RETURNS VARCHAR(50)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE comm_user_id VARCHAR(50);
    SELECT user_id INTO comm_user_id
    FROM user_master
    WHERE user_id = user_id AND user_type_id IN (SELECT user_type_id FROM user_type_master WHERE user_type_type = 'committee');
    RETURN comm_user_id;
END//
DELIMITER ;


-- Table for committee master
CREATE TABLE committee_master (
    id INT AUTO_INCREMENT PRIMARY KEY,
    committee_record_id VARCHAR(50) UNIQUE,
     record_id VARCHAR(50) , FOREIGN key (record_id) REFERENCES self_appraisal_score_master(record_id),
    user_id_employee VARCHAR(50),
    user_id_committee VARCHAR(50),
    comm_score INT,
    c_parameter_id VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive') DEFAULT 'active',
    FOREIGN KEY (user_id_employee) REFERENCES user_master(user_id),
    FOREIGN KEY (user_id_committee) REFERENCES user_master(user_id),
    FOREIGN KEY (c_parameter_id) REFERENCES c_parameter_master(c_parameter_id)
);

DELIMITER //
CREATE TRIGGER before_insert_committee_master
BEFORE INSERT ON committee_master
FOR EACH ROW
BEGIN
    DECLARE next_id INT;
    DECLARE emp_user_id VARCHAR(50);
    DECLARE comm_user_id VARCHAR(50);
    SET next_id = (SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'committee_master');
    SET NEW.record_id = CONCAT('COM', next_id);

    SET emp_user_id = get_employee_user_id(NEW.user_id_employee);
    SET comm_user_id = get_committee_user_id(NEW.user_id_committee);

    IF emp_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee User ID does not belong to an employee';
    END IF;

    IF comm_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Committee User ID does not belong to a committee member';
    END IF;
END//
DELIMITER ;