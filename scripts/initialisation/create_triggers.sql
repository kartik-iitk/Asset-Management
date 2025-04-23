USE AssetManagement;

DROP TRIGGER IF EXISTS trg_asset_after_insert;
DROP TRIGGER IF EXISTS trg_asset_after_update;
DROP TRIGGER IF EXISTS trg_labactivity_after_insert;
DROP TRIGGER IF EXISTS trg_labactivity_after_update;
DROP TRIGGER IF EXISTS trg_lab_after_insert;
DROP TRIGGER IF EXISTS trg_lab_after_update;
DROP TRIGGER IF EXISTS trg_po_after_insert;
DROP TRIGGER IF EXISTS trg_po_after_update;
DROP TRIGGER IF EXISTS trg_request_after_insert;
DROP TRIGGER IF EXISTS trg_request_after_update;

DELIMITER $$

-- Asset triggers
CREATE TRIGGER trg_asset_after_insert
AFTER INSERT ON Asset
FOR EACH ROW
BEGIN
  INSERT INTO AssetTransactionLog
    (AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription)
  VALUES
    (NEW.AssetId, USER(), 'Added', NEW.QuantityAvailable, 'New asset record');
END$$

-- on INSERT: NEW.FundsAvailable is the initial funds (A)
CREATE TRIGGER trg_asset_after_update
AFTER UPDATE ON Asset
FOR EACH ROW
BEGIN
  INSERT INTO AssetTransactionLog
    (AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription)
  VALUES
    (NEW.AssetId, USER(), 'Issued', NEW.QuantityAvailable - OLD.QuantityAvailable,
     'Asset details modified');
END$$

-- LabActivity triggers
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
  IF delta > 0 THEN
    INSERT INTO LabActivityLog
      (ActivityId, ActionTakenBy, ActionTaken, ActionDescription, Funds)
    VALUES
      (NEW.ActivityId, USER(), 'Added', 'Funds Allocated', delta);
  ELSEIF delta < 0 THEN
    INSERT INTO LabActivityLog
      (ActivityId, ActionTakenBy, ActionTaken, ActionDescription, Funds)
    VALUES
      (NEW.ActivityId, USER(), 'Spent', 'Funds Used', -delta);
  END IF;
END$$

-- Lab triggers
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

-- PurchaseOrder triggers
CREATE TRIGGER trg_po_after_insert
  AFTER INSERT ON PurchaseOrder
  FOR EACH ROW
BEGIN
  UPDATE LabActivity
    SET FundsAvailable = FundsAvailable - NEW.Amount
  WHERE ActivityId = NEW.ActivityId;
  INSERT INTO POLog
      (POId, POCreatedBy, POStatus, POStatusDescription)
    VALUES
      (NEW.POId, USER(), NEW.POStatus, NEW.POStatus);
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
END$$

-- Request triggers
CREATE TRIGGER trg_request_after_insert
  AFTER INSERT ON Request
  FOR EACH ROW
BEGIN
  INSERT INTO RequestLog
    (RequestId, ActionTakenBy, RequestStatus, RequestDescription)
  VALUES
    (NEW.RequestId, USER(), NEW.RequestStatus, 'Request created');
END$$

CREATE TRIGGER trg_request_after_update
AFTER UPDATE ON Request
FOR EACH ROW
BEGIN
  IF OLD.RequestStatus <> NEW.RequestStatus THEN
    INSERT INTO RequestLog
      (RequestId, ActionTakenBy, RequestStatus, RequestDescription)
    VALUES
      (NEW.RequestId, USER(), NEW.RequestStatus, CONCAT('Status changed from ',OLD.RequestStatus,' to ',NEW.RequestStatus));
  END IF;
END$$

DELIMITER ;
