USE TransactionsBKP;


SELECT * FROM sales.SalesOrderDetail

--Self Join
SELECT  x.SalesOrderID ,
        x.SalesOrderDetailID ,
        x.LineTotal ,
        SUM(y.LineTotal) AS RunningTotal
FROM    Sales.SalesOrderDetail x
        JOIN Sales.SalesOrderDetail y ON y.SalesOrderID = x.SalesOrderID
                                         AND y.SalesOrderDetailID <= x.SalesOrderDetailID
GROUP BY x.SalesOrderID ,
        x.SalesOrderDetailID ,
        x.LineTotal
ORDER BY 1, 2, 3;





-- RUNNING TOTAL IN A RECURSIVE FORM



WITH    CTE
            AS ( SELECT   SalesOrderID ,
                        SalesOrderDetailID ,
                        LineTotal ,
                        RunningTotal = LineTotal
                FROM     Sales.SalesOrderDetail
                WHERE    SalesOrderDetailID IN ( SELECT  MIN(SalesOrderDetailID)
                                                FROM    Sales.SalesOrderDetail
                                                GROUP BY SalesOrderID )
                UNION ALL
                SELECT   y.SalesOrderID ,
                        y.SalesOrderDetailID ,
                        y.LineTotal ,
                        RunningTotal = x.RunningTotal + y.LineTotal
                FROM     CTE x
                        JOIN Sales.SalesOrderDetail y ON y.SalesOrderID = x.SalesOrderID
                                                            AND y.SalesOrderDetailID = x.SalesOrderDetailID + 1
                )
    SELECT  *
    FROM    CTE
    ORDER BY 1 ,
            2 ,
            3
OPTION  ( MAXRECURSION 10000 );





--No Sales for N consecutive days



SELECT * FROM (

	SELECT 
	
		orderDate
		,AccountNumber
		,DATEDIFF(DAY,OrderDate,LEAD(OrderDate)OVER (ORDER BY OrderDate) ) AS Gap

		FROM Sales.SalesOrderHeader) NoSales
		--JOIN Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID

		WHERE NoSales.Gap > 1;






--MAX pay from Employees


USE TransactionsFN;


SELECT FullName, DepartmentName, BaseRate FROM

(
SELECT FirstName + ' ' + LastName AS FullName, DepartmentName, BaseRate
		,RANK() OVER (PARTITION BY DepartmentName ORDER BY BaseRate DESC) AS MaxSal

		FROM dbo.DimEmployee

		WHERE DepartmentName IN ('Marketing', 'Engineering')

		) AS EmpSal

		WHERE MaxSal <= 2



		UNION ALL



SELECT 'Others' AS FullName, DepartmentName, SUM(BaseRate) FROM

(
SELECT DepartmentName, BaseRate
		,RANK() OVER (PARTITION BY DepartmentName ORDER BY BaseRate DESC) AS MaxSal

		FROM dbo.DimEmployee

		WHERE DepartmentName IN ('Marketing', 'Engineering')

		) AS EmpSal

		WHERE MaxSal > 2
		GROUP BY DepartmentName






