-- filepath: Asset-Management\scripts\approve_po.sql
USE AssetManagement;

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_approve_po$$
CREATE PROCEDURE sp_approve_po(
  IN p_POId INT
)
BEGIN
  DECLARE v_ActivityId  INT;
  DECLARE v_POAmount    FLOAT;
  DECLARE v_FundsAvail  FLOAT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
    -- fetch PO’s amount & activity
    SELECT ActivityId, Amount
      INTO v_ActivityId, v_POAmount
    FROM PurchaseOrder
    WHERE POId = p_POId
    FOR UPDATE;

    -- check activity funds
    SELECT FundsAvailable
      INTO v_FundsAvail
    FROM LabActivity
    WHERE ActivityId = v_ActivityId
    FOR UPDATE;

    IF v_POAmount > v_FundsAvail THEN
      -- insufficient funds: reject this PO
      UPDATE PurchaseOrder
        SET POStatus='Rejected',
            DateModified=NOW()
      WHERE POId = p_POId;
      COMMIT;
      LEAVE_PROC: 
      -- exit without further processing
      BEGIN END;
    END IF;

    -- deduct funds & approve PO
    UPDATE LabActivity
      SET FundsAvailable = FundsAvailable - v_POAmount
    WHERE ActivityId = v_ActivityId;

    UPDATE PurchaseOrder
      SET POStatus='Approved',
          DateModified=NOW()
    WHERE POId = p_POId;
  COMMIT;
END$$
DELIMITER ;

-- To invoke from Streamlit or CLI:
-- CALL sp_approve_po(1234);