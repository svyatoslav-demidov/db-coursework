db-coursework
=============
=============
##Схема:
![Схема](model.png)

------------------------

#Данные
1. [Drivers](https://github.com/svyd/db-coursework/blob/master/README.md#drivers)
2. [Cars](https://github.com/svyd/db-coursework/blob/master/README.md#cars)
3. [Payments](https://github.com/svyd/db-coursework/blob/master/README.md#payments)
4. [d_licenses](https://github.com/svyd/db-coursework/blob/master/README.md#d_licenses)
5. [Penalties](https://github.com/svyd/db-coursework/blob/master/README.md#penalties)

#Хранимые процедуры

Помечаем штраф с заданным id как оплаченный
```sql
DELIMITER $$

CREATE PROCEDURE `remove_penalty_by_payment` (IN var1 INT)
BEGIN
	UPDATE penalties SET is_closed = true where penalties.penalty_id = var1;
END

```

#Триггеры

1. После успешного добавления платежа вызываем процедуру, которая пометит нужный штраф как проплаченный

```sql
USE `mydb`;
DROP trigger IF EXISTS `mydb`.`remove_penalty_trigger`;

DELIMITER $$

CREATE TRIGGER `remove_penalty_trigger` AFTER INSERT ON payments
for each row
BEGIN
        call remove_penalty_by_payment(new.penalty_id);
END$$

DELIMITER ;
```
2. Проверка входящего платежа  перед добавлением (есть ли подходящие под этот платеж штрафы)

```sql
USE `mydb`;
DROP trigger IF EXISTS `mydb`.`check_payment_trigger`;

DELIMITER $$

CREATE TRIGGER `check_payment_trigger` BEFORE INSERT ON payments
for each row
BEGIN
        SET @is_good := EXISTS(SELECT * FROM penalties WHERE
                penalties.cost = new.payment_cost and
                penalties.penalty_id = new.penalty_id
                and penalties.driver_id = new.driver_id);
        if @is_good = 0 then
                set @msg = "Bad payment";
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
        end if;
END$$


DELIMITER ;
```

3. Проверка того факта, что длинна vin-кода составляет именно 17 символов (При добавлении)

```sql
DROP trigger IF EXISTS `mydb`.`check_cars_trigger`;
DELIMITER $$
CREATE TRIGGER `check_cars_trigger` BEFORE INSERT ON cars
for each row
BEGIN
        if length(new.vin_code) <> 17 then
                set @msg = "Bad vin_code";
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
        end if;
END$$

DELIMITER ;
```


------------------------
#Описание
------------------------
### drivers (Водитель)
1. driver_id (идентификатор водителя)
2. first_name (имя водителя)
3. last_name (фамилия водителя)
4. d_license_id (идентификатор в/у водителя)

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
### cars (Автомобиль)
1. car_id (идентификатор автомобиля)
2. mark (марка автомобиля)
3. model (модель автомобиля)
4. year_issue (год выпуска автомобиля)
5. vin_code (vehicle identification number)
6. body_type (тип кузова автомобиля)
7. color (цвет автомобиля)
8. driver_id (идентификатор владельца автомобиля - водителя)

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
### payments (Платежи)
1. payment_id (идентификатор платежа)
2. payment_cost (сумма платежа)
3. payment_date (дата проведения платежа)
4. penalty_id (идентификатор штрафа - назначение плвтежа)
5. driver_id (идентификатор нарушителя-водителя - кто оплачивает штраф)

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
### d_licenses (Водительские удостоверения)
1. license_id (идентефикатор в/у)
2. license_number (номер в/у)
3. issue_date (дата получения в/у)
4. region (регион получения)

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
### penalties (Штрафы за нарушения)
1. penalty_id (идентификатор штрафа)
2. comment (условный комментарий ("за что штраф"))
3. cost (величина штрафа)
4. driver_id (идентификатор нарушителя - водителя)
5. foul_date (дата получения штрафа)
6. is_closed (оплачен ли штраф)

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
