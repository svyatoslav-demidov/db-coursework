USE `mydb`;

DELIMITER $$

CREATE TRIGGER `check_license_years_trigger` BEFORE INSERT ON d_licenses
for each row
BEGIN
        if DATEDIFF(new.licence_end, new.issue_date) > 0 then
                set @msg = "Bad license";
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
        end if;
END$$


DELIMITER ;

USE `mydb`;

DROP trigger IF EXISTS `mydb`.`remove_penalty_trigger`;

DELIMITER $$

CREATE TRIGGER `remove_penalty_trigger` AFTER INSERT ON payments
for each row
BEGIN
	call remove_penalty_by_payment(new.penalty_id);	
END$$

DELIMITER ;


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

