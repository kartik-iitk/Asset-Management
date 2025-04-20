SELECT  
  I.Make, I.Model, A.SerialNo,  
  A.DateCreated,  
  DATE_ADD(A.DateCreated, INTERVAL I.WarrantyPeriodMonths MONTH) AS WarrantyExpiry  
FROM Asset A  
JOIN Item I USING(ItemId)  
WHERE DATE_ADD(A.DateCreated, INTERVAL I.WarrantyPeriodMonths MONTH)  
      BETWEEN CURDATE() AND DATE_ADD(CURDATE(),INTERVAL 30 DAY);