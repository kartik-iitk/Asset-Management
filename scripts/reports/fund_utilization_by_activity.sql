SELECT  
  LA.ActivityDescription,  
  LA.FundsAllocated,  
  LA.FundsAvailable,  
  (LA.FundsAllocated - LA.FundsAvailable) AS Spent  
FROM LabActivity LA  
ORDER BY Spent DESC;