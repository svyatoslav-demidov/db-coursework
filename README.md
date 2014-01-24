db-coursework
=============
=============
##Схема:
![Схема](model.png)

------------------------

1. [Drivers](https://github.com/svyd/db-coursework/blob/master/README.md#drivers)
2. [Cars](https://github.com/svyd/db-coursework/blob/master/README.md#cars)
3. [Payments](https://github.com/svyd/db-coursework/blob/master/README.md#payments)
4. [d_licenses](https://github.com/svyd/db-coursework/blob/master/README.md#d_licenses)
5. [Penalties](https://github.com/svyd/db-coursework/blob/master/README.md#penalties)

------------------------
#Описание
------------------------
### drivers
1. driver_id
2. first_name
3. last_name
4. d_license_id

```sql
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
ENGINE = InnoDB
```
------------------------
### cars
1. car_id
2. mark
3. model
4. year_issue
5. vin_code
6. body_type
7. color
8. driver_id

```sql
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
ENGINE = InnoDB
```

------------------------
### payments
1. payment_id
2. payment_cost
3. payment_date
4. penalty_id
5. driver_id

```sql
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
ENGINE = InnoDB
```

------------------------
### d_licenses
1. license_id
2. license_number
3. issue_date
4. region

```sql
CREATE TABLE IF NOT EXISTS `mydb`.`d_licenses` (
  `license_id` INT NOT NULL AUTO_INCREMENT,
  `license_number` VARCHAR(45) NOT NULL,
  `issue_date` DATE NOT NULL,
  `region` INT NOT NULL,
  PRIMARY KEY (`license_id`),
  UNIQUE INDEX `license_id_UNIQUE` (`license_id` ASC),
  UNIQUE INDEX `license_number_UNIQUE` (`license_number` ASC))
ENGINE = InnoDB
```

------------------------
### penalties
1. penalty_id
2. comment 
3. cost
4. driver_id
5. foul_date
6. is_closed

```sql
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
ENGINE = InnoDB
```

------------------------
