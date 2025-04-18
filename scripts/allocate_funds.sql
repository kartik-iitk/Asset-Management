-- filepath: Asset-Management\scripts\allocate_funds.sql
USE AssetManagement;
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_allocate_funds$$
CREATE PROCEDURE sp_allocate_funds(
  IN p_LabId       INT,
  IN p_ActivityId  INT,
  IN p_Amount      FLOAT
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
    UPDATE Lab
      SET FundsAvailable = FundsAvailable - p_Amount
    WHERE LabId = p_LabId;

    UPDATE LabActivity
      SET FundsAvailable = FundsAvailable + p_Amount
    WHERE ActivityId = p_ActivityId;
  COMMIT;
END$$
DELIMITER ;