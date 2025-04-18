SELECT  
  L.LabName,  
  I.Category, I.Make, I.Model,  
  SUM(A.QuantityAvailable) AS QtyOnHand  
FROM Asset A  
JOIN Lab L     USING(LabId)  
JOIN Item I    USING(ItemId)  
GROUP BY L.LabName, I.Category, I.Make, I.Model  
ORDER BY L.LabName, QtyOnHand DESC;