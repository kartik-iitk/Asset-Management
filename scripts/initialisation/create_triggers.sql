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
  DECLARE qty_change INT;
  SET qty_change = NEW.QuantityAvailable - OLD.QuantityAvailable;
  
  IF qty_change < 0 THEN
    INSERT INTO AssetTransactionLog
      (AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription)
    VALUES
      (NEW.AssetId, USER(), 'Issued', ABS(qty_change),
       'Asset issued');
       -- Destroyed ??
  ELSEIF qty_change > 0 THEN
    INSERT INTO AssetTransactionLog
      (AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription)
    VALUES
      (NEW.AssetId, USER(), 'Returned', qty_change,
       'Asset returned');
  END IF;
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
  DECLARE labAction VARCHAR(20);
  DECLARE delta FLOAT;
  
  -- Retrieve the recent action taken from the Lab table
  SELECT RecentActionTaken INTO labAction
    FROM Lab
   WHERE LabId = NEW.LabId;
  
  SET delta = NEW.FundsAvailable - OLD.FundsAvailable;
  
  IF labAction = 'Added' THEN
    INSERT INTO LabActivityLog
      (ActivityId, ActionTakenBy, ActionTaken, ActionDescription, Funds)
    VALUES
      (NEW.ActivityId, USER(), 'Added', 'Funds Added', delta);
  ELSEIF labAction = 'Spent' THEN
    INSERT INTO LabActivityLog
      (ActivityId, ActionTakenBy, ActionTaken, ActionDescription, Funds)
    VALUES
      (NEW.ActivityId, USER(), 'Spent', 'Funds Spent', ABS(delta));
  ELSEIF labAction = 'Refunded' THEN
    INSERT INTO LabActivityLog
      (ActivityId, ActionTakenBy, ActionTaken, ActionDescription, Funds)
    VALUES
      (NEW.ActivityId, USER(), 'Refunded', 'Funds Refunded', delta);
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
  DECLARE labAction VARCHAR(20);
  DECLARE delta FLOAT;
  
  SELECT RecentActionTaken INTO labAction
    FROM Lab
   WHERE LabId = NEW.LabId;
  
  SET delta = NEW.FundsAvailable - OLD.FundsAvailable;
  
  IF labAction = 'Added' THEN
    INSERT INTO LabLog
      (LabId, ActionTakenBy, ActionTaken, ActionDescription, Amount)
    VALUES
      (NEW.LabId, USER(), 'Added', 'Funds Added', delta);
  ELSEIF labAction = 'Allocated' THEN
    INSERT INTO LabLog
      (LabId, ActionTakenBy, ActionTaken, ActionDescription, Amount)
    VALUES
      (NEW.LabId, USER(), 'Allocated', 'Funds Allocated', ABS(delta));
  ELSEIF labAction = 'Refunded' THEN
    INSERT INTO LabLog
      (LabId, ActionTakenBy, ActionTaken, ActionDescription, Amount)
    VALUES
      (NEW.LabId, USER(), 'Refunded', 'Funds Refunded', delta);
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
    IF NEW.POStatus = 'Pending' THEN
      INSERT INTO POLog
        (POId, POCreatedBy, POStatus, POStatusDescription)
      VALUES
        (NEW.POId, USER(), NEW.POStatus, CONCAT('Status changed from ', OLD.POStatus, ' to Pending'));
    ELSEIF NEW.POStatus = 'Approved' THEN
      INSERT INTO POLog
        (POId, POCreatedBy, POStatus, POStatusDescription)
      VALUES
        (NEW.POId, USER(), NEW.POStatus, CONCAT('Status changed from ', OLD.POStatus, ' to Approved'));
    ELSEIF NEW.POStatus = 'Rejected' THEN
      INSERT INTO POLog
        (POId, POCreatedBy, POStatus, POStatusDescription)
      VALUES
        (NEW.POId, USER(), NEW.POStatus, CONCAT('Status changed from ', OLD.POStatus, ' to Rejected'));
    ELSEIF NEW.POStatus = 'Closed' THEN
      INSERT INTO POLog
        (POId, POCreatedBy, POStatus, POStatusDescription)
      VALUES
        (NEW.POId, USER(), NEW.POStatus, CONCAT('Status changed from ', OLD.POStatus, ' to Closed'));
    END IF;
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
    IF NEW.RequestStatus = 'Pending' THEN
      INSERT INTO RequestLog
        (RequestId, ActionTakenBy, RequestStatus, RequestDescription)
      VALUES
        (NEW.RequestId, USER(), NEW.RequestStatus, CONCAT('Status changed from ', OLD.RequestStatus, ' to Pending'));
    ELSEIF NEW.RequestStatus = 'Approved' THEN
      INSERT INTO RequestLog
        (RequestId, ActionTakenBy, RequestStatus, RequestDescription)
      VALUES
        (NEW.RequestId, USER(), NEW.RequestStatus, CONCAT('Status changed from ', OLD.RequestStatus, ' to Approved'));
    ELSEIF NEW.RequestStatus = 'Rejected' THEN
      INSERT INTO RequestLog
        (RequestId, ActionTakenBy, RequestStatus, RequestDescription)
      VALUES
        (NEW.RequestId, USER(), NEW.RequestStatus, CONCAT('Status changed from ', OLD.RequestStatus, ' to Rejected'));
    ELSEIF NEW.RequestStatus = 'Closed' THEN
      INSERT INTO RequestLog
        (RequestId, ActionTakenBy, RequestStatus, RequestDescription)
      VALUES
        (NEW.RequestId, USER(), NEW.RequestStatus, CONCAT('Status changed from ', OLD.RequestStatus, ' to Closed'));
    END IF;
  END IF;
END$$

DELIMITER ;
