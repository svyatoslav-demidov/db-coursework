SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

DROP SCHEMA IF EXISTS `mydb` ;
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `mydb` ;

DROP TABLE IF EXISTS `mydb`.`d_licenses` ;

CREATE TABLE IF NOT EXISTS `mydb`.`d_licenses` (
  `license_id` INT NOT NULL AUTO_INCREMENT,
  `license_number` VARCHAR(45) NOT NULL,
  `issue_date` DATE NOT NULL,
  `region` INT NOT NULL,
  PRIMARY KEY (`license_id`),
  UNIQUE INDEX `license_id_UNIQUE` (`license_id` ASC),
  UNIQUE INDEX `license_number_UNIQUE` (`license_number` ASC))
ENGINE = InnoDB;


DROP TABLE IF EXISTS `mydb`.`drivers` ;

CREATE TABLE IF NOT EXISTS `mydb`.`drivers` (
  `driver_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(45) NOT NULL,
  `last_name` VARCHAR(45) NOT NULL,
  `d_license_id` INT NULL,
  PRIMARY KEY (`driver_id`),
  UNIQUE INDEX `iddriver_UNIQUE` (`driver_id` ASC),
  INDEX `fk_drivers_d_licenses_idx` (`d_license_id` ASC),
  CONSTRAINT `fk_drivers_d_licenses`
    FOREIGN KEY (`d_license_id`)
    REFERENCES `mydb`.`d_licenses` (`license_id`)
    ON DELETE SET NULL
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


DROP TABLE IF EXISTS `mydb`.`cars` ;

CREATE TABLE IF NOT EXISTS `mydb`.`cars` (
  `car_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `mark` VARCHAR(45) NOT NULL,
  `model` VARCHAR(45) NOT NULL,
  `year_issue` YEAR NOT NULL,
  `vin_code` VARCHAR(17) NOT NULL,
  `body_type` VARCHAR(45) NULL,
  `color` VARCHAR(45) NULL,
  `driver_id` INT NULL,
  PRIMARY KEY (`car_id`),
  UNIQUE INDEX `vin_code_UNIQUE` (`vin_code` ASC),
  INDEX `fk_cars_drivers1_idx` (`driver_id` ASC),
  CONSTRAINT `fk_cars_drivers1`
    FOREIGN KEY (`driver_id`)
    REFERENCES `mydb`.`drivers` (`driver_id`)
    ON DELETE SET NULL
    ON UPDATE SET NULL)
ENGINE = InnoDB;


DROP TABLE IF EXISTS `mydb`.`penalties` ;

CREATE TABLE IF NOT EXISTS `mydb`.`penalties` (
  `penalty_id` INT NOT NULL AUTO_INCREMENT,
  `comment` TEXT NULL,
  `cost` INT NOT NULL,
  `driver_id` INT NOT NULL,
  `foul_date` DATE NOT NULL,
  `is_closed` TINYINT(1) NULL DEFAULT FALSE,
  PRIMARY KEY (`penalty_id`),
  INDEX `fk_penalty_drivers1_idx` (`driver_id` ASC),
  CONSTRAINT `fk_penalty_drivers1`
    FOREIGN KEY (`driver_id`)
    REFERENCES `mydb`.`drivers` (`driver_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


DROP TABLE IF EXISTS `mydb`.`payments` ;

CREATE TABLE IF NOT EXISTS `mydb`.`payments` (
  `payment_id` INT NOT NULL AUTO_INCREMENT,
  `payment_cost` INT NOT NULL,
  `payment_date` DATE NOT NULL,
  `penalty_id` INT NULL,
  `driver_id` INT NULL,
  PRIMARY KEY (`payment_id`),
  INDEX `fk_payments_penalties1_idx` (`penalty_id` ASC),
  INDEX `fk_payments_drivers1_idx` (`driver_id` ASC),
  CONSTRAINT `fk_payments_penalties1`
    FOREIGN KEY (`penalty_id`)
    REFERENCES `mydb`.`penalties` (`penalty_id`)
    ON DELETE SET NULL
    ON UPDATE SET NULL,
  CONSTRAINT `fk_payments_drivers1`
    FOREIGN KEY (`driver_id`)
    REFERENCES `mydb`.`drivers` (`driver_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

USE `mydb` ;

CREATE TABLE IF NOT EXISTS `mydb`.`view_drivers_and_licenses` (`'driver_id'` INT, `'first_name'` INT, `'last_name'` INT, `'license_number'` INT, `'license_issue_date'` INT);

CREATE TABLE IF NOT EXISTS `mydb`.`view_drivers_and_cars` (`'driver_id'` INT, `'first_name'` INT, `'last_name'` INT, `'car_id'` INT, `'mark'` INT, `'model'` INT, `'year'` INT, `'color'` INT, `'vin'` INT);

CREATE TABLE IF NOT EXISTS `mydb`.`view_drivers_cars_licenses` (`'driver_id'` INT, `'first_name'` INT, `'last_name'` INT, `'mark'` INT, `'model'` INT, `'year'` INT, `'color'` INT, `'vin'` INT, `'license_number'` INT, `'license_issue_date'` INT);

CREATE TABLE IF NOT EXISTS `mydb`.`view_penalty_with_all` (`'driver_id'` INT, `'first_name'` INT, `'last_name'` INT, `'mark'` INT, `'model'` INT, `'year'` INT, `'color'` INT, `'vin'` INT, `'license_number'` INT, `'license_issue_date'` INT, `'comment'` INT, `'foul_date'` INT, `'cost'` INT);

CREATE TABLE IF NOT EXISTS `mydb`.`view_drivers_without_license` (`'driver_id'` INT, `'first_name'` INT, `'last_name'` INT);

CREATE TABLE IF NOT EXISTS `mydb`.`view_closed_penalty_with_all` (`'driver_id'` INT, `'first_name'` INT, `'last_name'` INT, `'mark'` INT, `'model'` INT, `'year'` INT, `'color'` INT, `'vin'` INT, `'license_number'` INT, `'license_issue_date'` INT, `'comment'` INT, `'foul_date'` INT, `'cost'` INT);


USE `mydb`;
DROP procedure IF EXISTS `mydb`.`remove_penalty_by_payment`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `remove_penalty_by_payment` (IN var1 INT)
BEGIN
	UPDATE penalties SET is_closed = true where penalties.penalty_id = var1;
END

$$

DELIMITER ;

DROP VIEW IF EXISTS `mydb`.`view_drivers_and_licenses` ;
DROP TABLE IF EXISTS `mydb`.`view_drivers_and_licenses`;
USE `mydb`;
CREATE  OR REPLACE VIEW `view_drivers_and_licenses` AS
SELECT 
drivers.driver_id as 'driver_id',
drivers.first_name as 'first_name',
drivers.last_name as 'last_name',
d_licenses.license_number as 'license_number',
d_licenses.issue_date as 'license_issue_date' FROM drivers 
INNER JOIN d_licenses on drivers.d_license_id = d_licenses.license_id;

DROP VIEW IF EXISTS `mydb`.`view_drivers_and_cars` ;
DROP TABLE IF EXISTS `mydb`.`view_drivers_and_cars`;
USE `mydb`;
CREATE  OR REPLACE VIEW `view_drivers_and_cars` AS
select 
drivers.driver_id as 'driver_id',
drivers.first_name as 'first_name',
drivers.last_name as 'last_name',
cars.car_id as 'car_id',
cars.mark as 'mark',
cars.model as 'model',
cars.year_issue as 'year',
cars.color as 'color', 
cars.vin_code as 'vin' 
from drivers inner join cars on drivers.driver_id = cars.driver_id;

DROP VIEW IF EXISTS `mydb`.`view_drivers_cars_licenses` ;
DROP TABLE IF EXISTS `mydb`.`view_drivers_cars_licenses`;
USE `mydb`;
CREATE  OR REPLACE VIEW `view_drivers_cars_licenses` AS
select
drivers.driver_id as 'driver_id', 
drivers.first_name as 'first_name',
drivers.last_name as 'last_name',
cars.mark as 'mark',
cars.model as 'model',
cars.year_issue as 'year',
cars.color as 'color', 
cars.vin_code as 'vin',
d_licenses.license_number as 'license_number',
d_licenses.issue_date as 'license_issue_date' 
from drivers 
inner join d_licenses on drivers.d_license_id = d_licenses.license_id 
inner join cars on drivers.driver_id = cars.driver_id;

DROP VIEW IF EXISTS `mydb`.`view_penalty_with_all` ;
DROP TABLE IF EXISTS `mydb`.`view_penalty_with_all`;
USE `mydb`;
CREATE  OR REPLACE VIEW `view_penalty_with_all` AS
select 
drivers.driver_id as 'driver_id',
drivers.first_name as 'first_name',
drivers.last_name as 'last_name',
cars.mark as 'mark',
cars.model as 'model',
cars.year_issue as 'year',
cars.color as 'color', 
cars.vin_code as 'vin',
d_licenses.license_number as 'license_number',
d_licenses.issue_date as 'license_issue_date',
penalties.comment as 'comment',
penalties.foul_date as 'foul_date',
penalties.cost as 'cost' 
from drivers 
inner join cars on drivers.driver_id = cars.driver_id
inner join penalties on drivers.driver_id = penalties.driver_id
LEFT OUTER join d_licenses 
on drivers.d_license_id = d_licenses.license_id where penalties.is_closed = FALSE;


DROP VIEW IF EXISTS `mydb`.`view_drivers_without_license` ;
DROP TABLE IF EXISTS `mydb`.`view_drivers_without_license`;
USE `mydb`;
CREATE  OR REPLACE VIEW `view_drivers_without_license` AS
select 
drivers.driver_id as 'driver_id',
drivers.first_name as 'first_name',
drivers.last_name as 'last_name' 
from drivers where drivers.d_license_id is NULL; 


DROP VIEW IF EXISTS `mydb`.`view_closed_penalty_with_all` ;
DROP TABLE IF EXISTS `mydb`.`view_closed_penalty_with_all`;
USE `mydb`;
CREATE  OR REPLACE VIEW `view_closed_penalty_with_all` AS
select 
drivers.driver_id as 'driver_id',
drivers.first_name as 'first_name',
drivers.last_name as 'last_name',
cars.mark as 'mark',
cars.model as 'model',
cars.year_issue as 'year',
cars.color as 'color', 
cars.vin_code as 'vin',
d_licenses.license_number as 'license_number',
d_licenses.issue_date as 'license_issue_date',
penalties.comment as 'comment',
penalties.foul_date as 'foul_date',
penalties.cost as 'cost' 
from drivers 
inner join cars on drivers.driver_id = cars.driver_id
inner join penalties on drivers.driver_id = penalties.driver_id
LEFT OUTER join d_licenses 
on drivers.d_license_id = d_licenses.license_id where penalties.is_closed = TRUE;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

START TRANSACTION;
USE `mydb`;
INSERT INTO `mydb`.`d_licenses` (`license_id`, `license_number`, `issue_date`, `region_id`) VALUES (1, '3503649015', '2011-08-20', 1);
INSERT INTO `mydb`.`d_licenses` (`license_id`, `license_number`, `issue_date`, `region_id`) VALUES (2, '1234567890', '1992-05-25', 2);
INSERT INTO `mydb`.`d_licenses` (`license_id`, `license_number`, `issue_date`, `region_id`) VALUES (3, '3214567742', '2012-12-31', 4);
INSERT INTO `mydb`.`d_licenses` (`license_id`, `license_number`, `issue_date`, `region_id`) VALUES (4, '3232323234', '2004-03-03', 3);

COMMIT;


START TRANSACTION;
USE `mydb`;
INSERT INTO `mydb`.`drivers` (`driver_id`, `first_name`, `last_name`, `d_license_id`) VALUES (1, 'Svyatoslav', 'Demidov', 1);
INSERT INTO `mydb`.`drivers` (`driver_id`, `first_name`, `last_name`, `d_license_id`) VALUES (2, 'Petrov', 'Ivan', 2);
INSERT INTO `mydb`.`drivers` (`driver_id`, `first_name`, `last_name`, `d_license_id`) VALUES (3, 'Sidorov', 'Petr', 3);
INSERT INTO `mydb`.`drivers` (`driver_id`, `first_name`, `last_name`, `d_license_id`) VALUES (4, 'Miron', 'Mironov', NULL);
INSERT INTO `mydb`.`drivers` (`driver_id`, `first_name`, `last_name`, `d_license_id`) VALUES (5, 'Anton', 'Antonov', 4);

COMMIT;


START TRANSACTION;
USE `mydb`;
INSERT INTO `mydb`.`cars` (`car_id`, `mark`, `model`, `year_issue`, `vin_code`, `body_type`, `color`, `driver_id`, `region_id`) VALUES (1, 'BMW', 'X5', 2005, 'WBACS11020FR83379', 'CROSSOVER', 'BLACK', 1, 1);
INSERT INTO `mydb`.`cars` (`car_id`, `mark`, `model`, `year_issue`, `vin_code`, `body_type`, `color`, `driver_id`, `region_id`) VALUES (2, 'VOLKSWAGEN', 'GOLF', 2011, 'CDBEW12060EC53335', 'HATCHBACK', 'GREEN', 1, 2);
INSERT INTO `mydb`.`cars` (`car_id`, `mark`, `model`, `year_issue`, `vin_code`, `body_type`, `color`, `driver_id`, `region_id`) VALUES (3, 'VAZ', '2115', 2005, 'CDBEW12063RC53335', 'SEDAN', 'SILVER', 2, 3);
INSERT INTO `mydb`.`cars` (`car_id`, `mark`, `model`, `year_issue`, `vin_code`, `body_type`, `color`, `driver_id`, `region_id`) VALUES (4, 'ALPINA', 'B6', 2013, 'WVESFEWSFEWQERDFD', 'COUPE', 'RED', 4, 4);
INSERT INTO `mydb`.`cars` (`car_id`, `mark`, `model`, `year_issue`, `vin_code`, `body_type`, `color`, `driver_id`, `region_id`) VALUES (5, 'BMW', '3ER', 1999, 'DDDDDDDDDDDDDDDDD', 'HATCHBACK', 'SILVER', 5, 2);

COMMIT;

START TRANSACTION;
USE `mydb`;
INSERT INTO `mydb`.`penalties` (`penalty_id`, `comment`, `cost`, `driver_id`, `foul_date`, `is_closed`, `region_id`) VALUES (1, 'Превышение скорости на 10 км/ч', 500, 2, '2012-08-20', FALSE, 1);
INSERT INTO `mydb`.`penalties` (`penalty_id`, `comment`, `cost`, `driver_id`, `foul_date`, `is_closed`, `region_id`) VALUES (2, 'Езда без прав', 1500, 4, '2011-05-03', FALSE, 2);
INSERT INTO `mydb`.`penalties` (`penalty_id`, `comment`, `cost`, `driver_id`, `foul_date`, `is_closed`, `region_id`) VALUES (3, 'Нарушение правил парковки', 2000, 3, '2013-04-24', FALSE, 1);

COMMIT;

