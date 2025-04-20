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

-- Instead, your Streamlit (or Python) interface should CALL this proc with real inputs, e.g.:

-- CALL sp_create_asset(
--   1001,         -- LabId
--   2001,         -- ItemId
--   'SN-000123',  -- SerialNo
--   10,           -- QuantityAvailable
--   'Shelf A',    -- StorageLocation
--   'New Microscope'  -- ShortDescription
-- );

-- To invoke (replace arguments as needed):
-- CALL sp_create_asset(<LabId>, <ItemId>, '<SerialNo>', <Quantity>, '<Location>', '<Description>');

Action: Update an Asset’s details  
````mysql
BEGIN;
UPDATE Asset  
  SET StorageLocation='Shelf B', ShortDescription='Moved to B'  
  WHERE AssetId=3001;  
COMMIT;
```  

Action: Retire (soft‑delete) an Asset  
````mysql
BEGIN;
UPDATE Asset  
  SET QuantityAvailable=0, ShortDescription='Retired', DateModified=NOW()  
  WHERE AssetId=3001;  
COMMIT;