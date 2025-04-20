-- filepath: Asset-Management\scripts\create_purchase.sql

USE AssetManagement;

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_purchase$$
CREATE PROCEDURE sp_create_purchase(
  IN p_ActivityId INT,
  IN p_Amount     FLOAT
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
    INSERT INTO PurchaseOrder
      (ActivityId, OrderDate, Amount, POStatus)
    VALUES
      (p_ActivityId, NOW(), p_Amount, 'Generated');
  COMMIT;
END$$
DELIMITER ;

-- To invoke:
-- CALL sp_create_purchase(<ActivityId>, <Amount>);