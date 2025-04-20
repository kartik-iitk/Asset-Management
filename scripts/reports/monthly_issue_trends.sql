SELECT  
  DATE_FORMAT(AIT.ActionDate,'%Y-%m') AS Month,  
  COUNT(*)                          AS NumIssues,  
  SUM(AIT.Quantity)                 AS QtyIssued  
FROM ActivityItemTransaction AIT  
WHERE AIT.ActionTaken='Issued'  
  AND AIT.ActionDate > DATE_SUB(CURDATE(), INTERVAL 12 MONTH)  
GROUP BY Month  
ORDER BY Month;