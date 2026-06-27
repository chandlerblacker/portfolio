SELECT ROUND(AVG(a.sales_amount),0), MONTH(a.order_date), YEAR(a.order_date), group_type
FROM sales a
LEFT JOIN (
	SELECT customer_key,
	CASE
		WHEN order_diff <= 30 THEN "multiple_purch_first_month"
		ELSE "control_group"
	END as "group_type"
	FROM (
		SELECT *, DATEDIFF(second_purchase,first_purchase) as "order_diff"
		FROM (
			SELECT SUM(sales_amount), customer_key, order_date as "first_purchase",
			row_number() over(partition by customer_key order by order_date) as ranks,
			LEAD(order_date, 1) OVER(partition by customer_key order by order_date) as "second_purchase"
			FROM sales
			GROUP BY customer_key, order_date
		) a
		WHERE ranks = 1
	) a
) b ON a.customer_key = b.customer_key
GROUP BY MONTH(a.order_date), YEAR(a.order_date), group_type
ORDER BY group_type DESC, year(a.order_date), month(a.order_date)
    