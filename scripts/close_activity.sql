-- filepath: Asset-Management\scripts\close_activity.sql

USE AssetManagement;

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_close_activity$$
CREATE PROCEDURE sp_close_activity(
  IN p_ActivityId INT
)
BEGIN
  DECLARE v_LabId      INT;
  DECLARE v_FundsAvail FLOAT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
    -- fetch lab and remaining funds for this activity
    SELECT LabId, FundsAvailable
      INTO v_LabId, v_FundsAvail
    FROM LabActivity
    WHERE ActivityId = p_ActivityId
    FOR UPDATE;

    -- refund leftover funds back to the lab
    UPDATE Lab
      SET FundsAvailable = FundsAvailable + v_FundsAvail
    WHERE LabId = v_LabId;

    -- close the activity
    UPDATE LabActivity
      SET FundsAvailable = 0,
          IsClosed       = TRUE,
          DateModified   = NOW()
    WHERE ActivityId = p_ActivityId;
  COMMIT;
END$$
DELIMITER ;

-- To invoke:
-- CALL sp_close_activity(<your_activity_id>);