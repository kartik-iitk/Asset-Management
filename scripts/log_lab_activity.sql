USE AssetManagement;

DELIMITER $$

-- on INSERT: NEW.FundsAvailable is the initial funds (A)
CREATE TRIGGER trg_labactivity_after_insert
AFTER INSERT ON LabActivity
FOR EACH ROW
BEGIN
  INSERT INTO LabActivityLog
    (ActivityId, ActionTakenBy, ActionTaken, ActionDescription, Funds)
  VALUES
    (NEW.ActivityId, USER(), 'Added', 'Initial Funds', NEW.FundsAvailable);
END$$

-- on UPDATE: log only the change in FundsAvailable (B)
CREATE TRIGGER trg_labactivity_after_update
AFTER UPDATE ON LabActivity
FOR EACH ROW
BEGIN
  DECLARE delta FLOAT;
  SET delta = NEW.FundsAvailable - OLD.FundsAvailable;
  IF delta <> 0 THEN
    INSERT INTO LabActivityLog
      (ActivityId, ActionTakenBy, ActionTaken, ActionDescription, Funds)
    VALUES
      (NEW.ActivityId, USER(), 'Added', 'Funds Allocated', delta);
  END IF;
END$$

DELIMITER ;