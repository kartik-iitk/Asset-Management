USE AssetManagement;

DELIMITER $$
CREATE TRIGGER trg_asset_after_insert
AFTER INSERT ON Asset
FOR EACH ROW
BEGIN
  INSERT INTO AssetTransactionLog
    (AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription)
  VALUES
    (NEW.AssetId, USER(), 'Added', NEW.QuantityAvailable, 'New asset record');
END$$

CREATE TRIGGER trg_asset_after_update
AFTER UPDATE ON Asset
FOR EACH ROW
BEGIN
  INSERT INTO AssetTransactionLog
    (AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription)
  VALUES
    (NEW.AssetId, USER(), 'Updated', NEW.QuantityAvailable - OLD.QuantityAvailable,
     'Asset details modified');
END$$
DELIMITER ;