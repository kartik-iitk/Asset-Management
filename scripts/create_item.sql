-- filepath: d:\IITK\ACADEMICS\2024-25 Semester 2\CS315\CourseProject\Asset-Management\scripts\create_item.sql
USE AssetManagement;
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_item$$
CREATE PROCEDURE sp_create_item(
  IN p_Category           VARCHAR(50),
  IN p_Make               VARCHAR(100),
  IN p_Model              VARCHAR(100),
  IN p_WarrantyMonths     INT,
  IN p_ItemDescription    VARCHAR(255),
  IN p_CreatedByUserId    INT,
  IN p_IsActive           BOOLEAN
)
BEGIN
  START TRANSACTION;
    INSERT INTO Item
      (Category
      ,Make
      ,Model
      ,WarrantyPeriodMonths
      ,ItemDescription
      ,CreatedBy
      ,DateCreated
      ,IsActive)
    VALUES
      (p_Category
      ,p_Make
      ,p_Model
      ,p_WarrantyMonths
      ,p_ItemDescription
      ,p_CreatedByUserId
      ,NOW()
      ,p_IsActive);
  COMMIT;
END$$
DELIMITER ;

-- To invoke from mysql> prompt:
-- CALL sp_create_item(
--   'Camera',       -- p_Category
--   'Canon',        -- p_Make
--   'EOS 1500D',    -- p_Model
--   24,             -- p_WarrantyMonths
--   'DSLR camera',  -- p_ItemDescription
--   1,              -- p_CreatedByUserId
--   TRUE            -- p_IsActive
-- );