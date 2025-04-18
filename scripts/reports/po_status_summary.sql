SELECT  
  PO.POStatus,  
  COUNT(*) AS NumPOs,  
  SUM(PO.Amount) AS TotalAmt  
FROM PurchaseOrder PO  
GROUP BY PO.POStatus  
ORDER BY FIELD(PO.POStatus,'Generated','Approved','Received','Closed');