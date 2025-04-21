USE AssetManagement;
DROP TRIGGER IF EXISTS trg_po_after_insert;
DELIMITER $$

CREATE TRIGGER trg_po_after_insert
  AFTER INSERT ON PurchaseOrder
  FOR EACH ROW
BEGIN
  UPDATE LabActivity
    SET FundsAvailable = FundsAvailable - NEW.Amount
  WHERE ActivityId = NEW.ActivityId;
END$$

CREATE TRIGGER trg_po_after_update
AFTER UPDATE ON PurchaseOrder
FOR EACH ROW
BEGIN
  IF OLD.POStatus <> NEW.POStatus THEN
    INSERT INTO POLog
      (POId, POCreatedBy, POStatus, POStatusDescription)
    VALUES
      (NEW.POId, USER(), NEW.POStatus, CONCAT('Status changed from ',OLD.POStatus,' to ',NEW.POStatus));
  END IF;
  -- if you also want to log amount changes, add similar delta logic here
END$$

DELIMITER ;