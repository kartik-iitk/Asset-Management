SELECT  
  LA.ActivityDescription,  
  COUNT(*)            AS NumIssues,  
  SUM(AIT.Quantity)   AS TotalQty,  
  MIN(AIT.ActionDate) AS FirstIssue,  
  MAX(AIT.ActionDate) AS LastIssue  
FROM ActivityItemTransaction AIT  
JOIN LabActivity LA USING(ActivityId)  
WHERE AIT.ActionTaken='Issued'  
GROUP BY LA.ActivityDescription  
ORDER BY TotalQty DESC;