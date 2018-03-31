bcp dbo.Categories in ./Categories2.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000
bcp dbo.Shippers in ./Shippers2.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000
bcp dbo.Suppliers in ./Suppliers2.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000 	
bcp dbo.Customers in ./Customers2.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000
bcp dbo.Employees in ./Employees2.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000
bcp dbo.Products in ./Products2.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000
bcp dbo.Orders in ./Orders2.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000
bcp dbo.OrderDetails in ./OrderDetails2.txt -S WS12SQL -d Northwind -T -c -t '|' -b 1000
