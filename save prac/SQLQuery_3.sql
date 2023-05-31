-- Câu 1 (0.75 đ): Lấy thông tin về Mã đơn hàng, mã sản phẩm, mã khách hàng, số lượng sản
-- phẩm của những dòng dữ liệu thỏa điều kiện Ship Mode là Standard Class

SELECT Order_ID,Product_ID,Customer_ID,Quantity
From sales
WHERE Ship_Mode = 'Standard Class'

-- Câu 2 (0.75 đ): Lấy thông tin về mã đơn hàng của những dòng dữ liệu thỏa mãn điều kiện
-- tồn tại một loại sản phẩm (Product ID) thuộc nhóm category là Office Supplies và có quantity
-- > 3

SELECT distinct Order_ID 
from sales
WHERE Category = 'Office Supplies' and Quantity > 3

-- Câu 3 (1đ) : Thống kê số lượng mã đơn hàng, số lượng các loại sản phẩm (product ID),
-- tổng doanh thu và tổng lợi nhuận theo từng Category, sắp xếp theo thứ tự giảm dần của
-- doanh thu

SELECT COUNT(Product_ID) madonhang , Category , sum(Profit) Sumprofit, sum(sales) sumsales
from sales 
GROUP BY Category
ORDER by sum(Profit) DESC



-- Câu 4 (1đ): Với mỗi loại Ship mode, lấy ra thông tin khách hàng (Customer ID), số lượng
-- đơn hàng sao cho có số lượng đơn hàng theo hình thức Ship mode đó là nhiều nhất.



SELECT Ship_Mode, Customer_ID , totalofOI
FROM(SELECT Ship_Mode, Customer_ID, COUNT(DISTINCT Order_ID) AS totalofOI
        FROM sales 
        GROUP BY Ship_Mode, Customer_ID) x
        WHERE totalofOI >= ALL( SELECT totalofOI
                            FROM (SELECT Ship_Mode, Customer_ID, COUNT(DISTINCT Order_ID) AS totalofOI
                                        FROM sales
                                        GROUP BY Ship_Mode, Customer_ID) y
                                        WHERE x.Ship_Mode = y.Ship_Mode)
        ORDER BY Ship_Mode


-- Câu 5 (1đ): Với mỗi dòng dữ liệu, thêm 1 column có tên là totalSaleBefore: Tổng số doanh
-- thu của các đơn hàng mà trước đó customer đó thực hiện (Bao gồm cả đơn hàng hiện tại).
-- Những đơn hàng trước đó chính là những đơn hàng có Order Date <= Ngày của đơn hàng
-- đang xét.





SELECT *
FROM sales