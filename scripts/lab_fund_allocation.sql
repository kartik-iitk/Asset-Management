USE AssetManagement;
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_add_lab_funds$$
CREATE PROCEDURE sp_add_lab_funds(
  IN p_LabId   INT,
  IN p_Amount  FLOAT
)
BEGIN
  START TRANSACTION;
    UPDATE Lab
      SET FundsAvailable = FundsAvailable + p_Amount
    WHERE LabId = p_LabId;
  COMMIT;
END$$
DELIMITER ;

-- To invoke:
-- CALL sp_add_lab_funds(1, 5000.00);