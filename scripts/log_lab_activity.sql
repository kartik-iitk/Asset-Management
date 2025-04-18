USE AssetManagement;

DELIMITER $$
CREATE TRIGGER trg_labactivity_after_update
AFTER UPDATE ON LabActivity
FOR EACH ROW
BEGIN
  INSERT INTO LabActivityLog
    (ActivityId, ActionTakenBy, ActionTaken, ActionDescription, Funds)
  VALUES
    (OLD.ActivityId, USER(), 'Update', 'Funds/status changed', NEW.FundsAvailable);
END$$
DELIMITER ;