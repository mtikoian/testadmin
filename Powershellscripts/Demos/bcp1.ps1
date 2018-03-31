bcp dbo.Categories in ./Categories1.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000
bcp dbo.Shippers in ./Shippers1.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000
bcp dbo.Suppliers in ./Suppliers1.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000 	
bcp dbo.Customers in ./Customers1.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000
bcp dbo.Employees in ./Employees1.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000
bcp dbo.Products in ./Products1.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000
bcp dbo.Orders in ./Orders1.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000
bcp dbo.OrderDetails in ./OrderDetails1.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000
