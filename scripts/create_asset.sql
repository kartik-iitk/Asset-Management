USE AssetManagement;

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_asset$$
CREATE PROCEDURE sp_create_asset(
  IN p_LabId             INT,
  IN p_ItemId            INT,
  IN p_SerialNo          VARCHAR(20),
  IN p_QuantityAvailable INT,
  IN p_StorageLocation   VARCHAR(100),
  IN p_ShortDescription  VARCHAR(100)
)
BEGIN
  START TRANSACTION;
    INSERT INTO Asset
      (LabId, ItemId, SerialNo, QuantityAvailable, StorageLocation, ShortDescription)
    VALUES
      (p_LabId, p_ItemId, p_SerialNo, p_QuantityAvailable, p_StorageLocation, p_ShortDescription);
  COMMIT;
END$$
DELIMITER ;

-- example usage:
-- CALL sp_create_asset(1, 3, 'SN-0001', 10, 'Shelf A', 'New Microscope');

-- example update (note this is NOT part of the proc file, just for your reference):
-- BEGIN;
-- UPDATE Asset
--   SET StorageLocation='Shelf B', ShortDescription='Moved to B'
-- WHERE AssetId=3001;
-- COMMIT;

-- Action: Update an Asset’s details  
BEGIN;
UPDATE Asset  
  SET StorageLocation='Shelf B', ShortDescription='Moved to B'  
  WHERE AssetId=3001;  
COMMIT;

-- Action: Retire (soft‑delete) an Asset  
BEGIN;
UPDATE Asset  
  SET QuantityAvailable=0, ShortDescription='Retired', DateModified=NOW()  
  WHERE AssetId=3001;  
COMMIT;