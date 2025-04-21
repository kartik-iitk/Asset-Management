
USE AssetManagement;
DELIMITER $$

CREATE TRIGGER trg_lab_after_insert
AFTER INSERT ON Lab
FOR EACH ROW
BEGIN
  INSERT INTO LabLog
    (LabId, ActionTakenBy, ActionTaken, ActionDescription, Amount)
  VALUES
    (NEW.LabId, USER(), 'Added', 'Initial Funds', NEW.FundsAvailable);
END$$

CREATE TRIGGER trg_lab_after_update
AFTER UPDATE ON Lab
FOR EACH ROW
BEGIN
  DECLARE delta FLOAT;
  SET delta = NEW.FundsAvailable - OLD.FundsAvailable;
  IF delta > 0 THEN
    INSERT INTO LabLog
      (LabId, ActionTakenBy, ActionTaken, ActionDescription, Amount)
    VALUES
      (NEW.LabId, USER(), 'Added', 'Funds Allocated', delta);
  ELSEIF delta < 0 THEN
    INSERT INTO LabLog
      (LabId, ActionTakenBy, ActionTaken, ActionDescription, Amount)
    VALUES
      (NEW.LabId, USER(), 'Spent', 'Funds Used', -delta);
  END IF;
END$$

DELIMITER ;