Select * From balanced_tree.sales

Select * From balanced_tree.product_details

Select sum(qty) as "Total Sales" From balanced_tree.sales

Select prod_id, sum(qty)
From balanced_tree.sales
Group By prod_id

Select s.prod_id, pd.product_name, sum(s.qty) as quantity
From balanced_tree.sales s
Left Join balanced_tree.product_details pd ON s.prod_id = pd.product_id
Group By s.prod_id, pd.product_name

Select prod_id, sum (qty * price) as total_revenue_before_discount
From balanced_tree.sales
Group by prod_id

Select prod_id, sum (qty * price * (CAST(discount as float)/100)) as total_discount
From balanced_tree.sales
Group by prod_id

Select txn_id, Count(Distinct(prod_id)) 
From balanced_tree.sales
Group by txn_id


Select txn_id, Distinct(prod_id)
From balanced_tree.sales
Group by txn_id



