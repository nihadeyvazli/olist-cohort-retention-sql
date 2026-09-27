-- TRAP:
SELECT
    COUNT(*)                           AS total_rows,
    COUNT(DISTINCT customer_id)        AS unique_customer_id,
    COUNT(DISTINCT customer_unique_id) AS unique_customer_unique_id
FROM customers;


-- Q1: Delivered orders only, with the real customer 
SELECT
    o.order_id,
    c.customer_unique_id,
    o.order_purchase_timestamp
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';




-- Q2: Cohort CTE 
WITH delivered_orders AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        o.order_purchase_timestamp
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
cohort AS (
    SELECT DISTINCT
        customer_unique_id,
        strftime('%Y-%m',
            MIN(order_purchase_timestamp) OVER (PARTITION BY customer_unique_id)
        ) AS cohort_month
    FROM delivered_orders
)
SELECT *
FROM cohort
ORDER BY cohort_month;




-- Q3: Activity CTE 
WITH delivered_orders AS (


    SELECT
        o.order_id,
        c.customer_unique_id,
        o.order_purchase_timestamp
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
activity AS (

    SELECT
        customer_unique_id,
        order_id,
        strftime('%Y-%m', order_purchase_timestamp) AS order_month
    FROM delivered_orders
)
SELECT *
FROM activity
ORDER BY order_month;




-- Q4: Join activity 
WITH delivered_orders AS (
    
    SELECT
        o.order_id,
        c.customer_unique_id,
        o.order_purchase_timestamp
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
cohort AS (
    SELECT DISTINCT
        customer_unique_id,
        strftime('%Y-%m',
            MIN(order_purchase_timestamp) OVER (PARTITION BY customer_unique_id)
        ) AS cohort_month
    FROM delivered_orders
),
activity AS (
    SELECT
        customer_unique_id,
        order_id,
        strftime('%Y-%m', order_purchase_timestamp) AS order_month
    FROM delivered_orders
),
cohort_activity AS (
    SELECT
        a.customer_unique_id,
        a.order_id,
        c.cohort_month,
        a.order_month,
        (CAST(substr(a.order_month, 1, 4) AS INTEGER) - CAST(substr(c.cohort_month, 1, 4) AS INTEGER)) * 12
      + (CAST(substr(a.order_month, 6, 2) AS INTEGER) - CAST(substr(c.cohort_month, 6, 2) AS INTEGER))
            AS period_number
    FROM activity AS a
    JOIN cohort AS c
        ON a.customer_unique_id = c.customer_unique_id
)
SELECT *
FROM cohort_activity
ORDER BY cohort_month, period_number;






-- Q5: Retention matrix - cohort_month x period_number
WITH delivered_orders AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        o.order_purchase_timestamp
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
cohort AS (
    SELECT DISTINCT
        customer_unique_id,
        strftime('%Y-%m',
            MIN(order_purchase_timestamp) OVER (PARTITION BY customer_unique_id)
        ) AS cohort_month
    FROM delivered_orders
),
activity AS (
    SELECT
        customer_unique_id,
        order_id,
        strftime('%Y-%m', order_purchase_timestamp) AS order_month
    FROM delivered_orders
),
cohort_activity AS (
    SELECT
        a.customer_unique_id,
        a.order_id,
        c.cohort_month,
        a.order_month,
        (CAST(substr(a.order_month, 1, 4) AS INTEGER) - CAST(substr(c.cohort_month, 1, 4) AS INTEGER)) * 12
      + (CAST(substr(a.order_month, 6, 2) AS INTEGER) - CAST(substr(c.cohort_month, 6, 2) AS INTEGER))
            AS period_number
    FROM activity AS a
    JOIN cohort AS c
        ON a.customer_unique_id = c.customer_unique_id
)

SELECT
    cohort_month,
    COUNT(DISTINCT CASE WHEN period_number = 0  THEN customer_unique_id END) AS p0,
    COUNT(DISTINCT CASE WHEN period_number = 1  THEN customer_unique_id END) AS p1,
    COUNT(DISTINCT CASE WHEN period_number = 2  THEN customer_unique_id END) AS p2,
    COUNT(DISTINCT CASE WHEN period_number = 3  THEN customer_unique_id END) AS p3,
    COUNT(DISTINCT CASE WHEN period_number = 4  THEN customer_unique_id END) AS p4,
    COUNT(DISTINCT CASE WHEN period_number = 5  THEN customer_unique_id END) AS p5,
    COUNT(DISTINCT CASE WHEN period_number = 6  THEN customer_unique_id END) AS p6,
    COUNT(DISTINCT CASE WHEN period_number = 7  THEN customer_unique_id END) AS p7,
    COUNT(DISTINCT CASE WHEN period_number = 8  THEN customer_unique_id END) AS p8,
    COUNT(DISTINCT CASE WHEN period_number = 9  THEN customer_unique_id END) AS p9,
    COUNT(DISTINCT CASE WHEN period_number = 10 THEN customer_unique_id END) AS p10,
    COUNT(DISTINCT CASE WHEN period_number = 11 THEN customer_unique_id END) AS p11,
    COUNT(DISTINCT CASE WHEN period_number = 12 THEN customer_unique_id END) AS p12,
    COUNT(DISTINCT CASE WHEN period_number = 13 THEN customer_unique_id END) AS p13,
    COUNT(DISTINCT CASE WHEN period_number = 14 THEN customer_unique_id END) AS p14,
    COUNT(DISTINCT CASE WHEN period_number = 15 THEN customer_unique_id END) AS p15,
    COUNT(DISTINCT CASE WHEN period_number = 16 THEN customer_unique_id END) AS p16,
    COUNT(DISTINCT CASE WHEN period_number = 17 THEN customer_unique_id END) AS p17,
    COUNT(DISTINCT CASE WHEN period_number = 18 THEN customer_unique_id END) AS p18,
    COUNT(DISTINCT CASE WHEN period_number = 19 THEN customer_unique_id END) AS p19,
    COUNT(DISTINCT CASE WHEN period_number = 20 THEN customer_unique_id END) AS p20
FROM cohort_activity
GROUP BY cohort_month
ORDER BY cohort_month;







-- Q6: Cohort sizes 
WITH delivered_orders AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        o.order_purchase_timestamp
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
cohort AS (
    SELECT DISTINCT
        customer_unique_id,
        strftime('%Y-%m',
            MIN(order_purchase_timestamp) OVER (PARTITION BY customer_unique_id)
        ) AS cohort_month
    FROM delivered_orders
),
activity AS (
    SELECT
        customer_unique_id,
        order_id,
        strftime('%Y-%m', order_purchase_timestamp) AS order_month
    FROM delivered_orders
),
cohort_activity AS (
    SELECT
        a.customer_unique_id,
        a.order_id,
        c.cohort_month,
        a.order_month,
        (CAST(substr(a.order_month, 1, 4) AS INTEGER) - CAST(substr(c.cohort_month, 1, 4) AS INTEGER)) * 12
      + (CAST(substr(a.order_month, 6, 2) AS INTEGER) - CAST(substr(c.cohort_month, 6, 2) AS INTEGER))
            AS period_number
    FROM activity AS a
    JOIN cohort AS c
        ON a.customer_unique_id = c.customer_unique_id
),
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS cohort_size
    FROM cohort_activity
    WHERE period_number = 0
    GROUP BY cohort_month
)
SELECT *
FROM cohort_size
ORDER BY cohort_month;





-- Q7: Retention rate matrix 
WITH delivered_orders AS (

    SELECT
        o.order_id,
        c.customer_unique_id,
        o.order_purchase_timestamp
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
cohort AS (
 
    SELECT DISTINCT
        customer_unique_id,
        strftime('%Y-%m',
            MIN(order_purchase_timestamp) OVER (PARTITION BY customer_unique_id)
        ) AS cohort_month
    FROM delivered_orders
),
activity AS (

    SELECT
        customer_unique_id,
        order_id,
        strftime('%Y-%m', order_purchase_timestamp) AS order_month
    FROM delivered_orders
),
cohort_activity AS (
    
    SELECT
        a.customer_unique_id,
        a.order_id,
        c.cohort_month,
        a.order_month,
        (CAST(substr(a.order_month, 1, 4) AS INTEGER) - CAST(substr(c.cohort_month, 1, 4) AS INTEGER)) * 12
      + (CAST(substr(a.order_month, 6, 2) AS INTEGER) - CAST(substr(c.cohort_month, 6, 2) AS INTEGER))
            AS period_number
    FROM activity AS a
    JOIN cohort AS c
        ON a.customer_unique_id = c.customer_unique_id
),
cohort_size AS (
  
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS cohort_size
    FROM cohort_activity
    WHERE period_number = 0
    GROUP BY cohort_month
),
data_end AS (
  
    SELECT MAX(order_month) AS last_month
    FROM activity
),
cohort_info AS (
    
    SELECT
        s.cohort_month,
        s.cohort_size,
        (CAST(substr(e.last_month, 1, 4) AS INTEGER) - CAST(substr(s.cohort_month, 1, 4) AS INTEGER)) * 12
      + (CAST(substr(e.last_month, 6, 2) AS INTEGER) - CAST(substr(s.cohort_month, 6, 2) AS INTEGER))
            AS max_period
    FROM cohort_size AS s
    CROSS JOIN data_end AS e
),
retention_counts AS (
    
    SELECT
        cohort_month,
        period_number,
        COUNT(DISTINCT customer_unique_id) AS active_customers
    FROM cohort_activity
    GROUP BY cohort_month, period_number
)

SELECT
    ci.cohort_month,
    ci.cohort_size,
    ROUND(100.0 * SUM(CASE WHEN rc.period_number = 0 THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) AS p0,
    CASE WHEN ci.max_period >= 1  THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 1  THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p1,
    CASE WHEN ci.max_period >= 2  THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 2  THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p2,
    CASE WHEN ci.max_period >= 3  THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 3  THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p3,
    CASE WHEN ci.max_period >= 4  THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 4  THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p4,
    CASE WHEN ci.max_period >= 5  THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 5  THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p5,
    CASE WHEN ci.max_period >= 6  THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 6  THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p6,
    CASE WHEN ci.max_period >= 7  THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 7  THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p7,
    CASE WHEN ci.max_period >= 8  THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 8  THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p8,
    CASE WHEN ci.max_period >= 9  THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 9  THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p9,
    CASE WHEN ci.max_period >= 10 THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 10 THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p10,
    CASE WHEN ci.max_period >= 11 THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 11 THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p11,
    CASE WHEN ci.max_period >= 12 THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 12 THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p12,
    CASE WHEN ci.max_period >= 13 THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 13 THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p13,
    CASE WHEN ci.max_period >= 14 THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 14 THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p14,
    CASE WHEN ci.max_period >= 15 THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 15 THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p15,
    CASE WHEN ci.max_period >= 16 THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 16 THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p16,
    CASE WHEN ci.max_period >= 17 THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 17 THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p17,
    CASE WHEN ci.max_period >= 18 THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 18 THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p18,
    CASE WHEN ci.max_period >= 19 THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 19 THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p19,
    CASE WHEN ci.max_period >= 20 THEN ROUND(100.0 * SUM(CASE WHEN rc.period_number = 20 THEN rc.active_customers ELSE 0 END) / ci.cohort_size, 2) END AS p20
FROM cohort_info AS ci
JOIN retention_counts AS rc
    ON rc.cohort_month = ci.cohort_month
GROUP BY ci.cohort_month, ci.cohort_size, ci.max_period
ORDER BY ci.cohort_month;







-- Q8: Average retention rate per period 
WITH delivered_orders AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        o.order_purchase_timestamp
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
cohort AS (
 
    SELECT DISTINCT
        customer_unique_id,
        strftime('%Y-%m',
            MIN(order_purchase_timestamp) OVER (PARTITION BY customer_unique_id)
        ) AS cohort_month
    FROM delivered_orders
),
activity AS (
    SELECT
        customer_unique_id,
        order_id,
        strftime('%Y-%m', order_purchase_timestamp) AS order_month
    FROM delivered_orders
),
cohort_activity AS (

    SELECT
        a.customer_unique_id,
        a.order_id,
        c.cohort_month,
        a.order_month,
        (CAST(substr(a.order_month, 1, 4) AS INTEGER) - CAST(substr(c.cohort_month, 1, 4) AS INTEGER)) * 12
      + (CAST(substr(a.order_month, 6, 2) AS INTEGER) - CAST(substr(c.cohort_month, 6, 2) AS INTEGER))
            AS period_number
    FROM activity AS a
    JOIN cohort AS c
        ON a.customer_unique_id = c.customer_unique_id
),
cohort_size AS (

    SELECT
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS cohort_size
    FROM cohort_activity
    WHERE period_number = 0
    GROUP BY cohort_month
),
data_end AS (

    SELECT MAX(order_month) AS last_month
    FROM activity
),
cohort_info AS (
 
    SELECT
        s.cohort_month,
        s.cohort_size,
        (CAST(substr(e.last_month, 1, 4) AS INTEGER) - CAST(substr(s.cohort_month, 1, 4) AS INTEGER)) * 12
      + (CAST(substr(e.last_month, 6, 2) AS INTEGER) - CAST(substr(s.cohort_month, 6, 2) AS INTEGER))
            AS max_period
    FROM cohort_size AS s
    CROSS JOIN data_end AS e
),
retention_counts AS (
    SELECT
        cohort_month,
        period_number,
        COUNT(DISTINCT customer_unique_id) AS active_customers
    FROM cohort_activity
    GROUP BY cohort_month, period_number
),
periods(period_number) AS (
    VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10),
           (11), (12), (13), (14), (15), (16), (17), (18), (19), (20)
),
cell_rates AS (
    SELECT
        ci.cohort_month,
        ci.cohort_size,
        p.period_number,
        COALESCE(rc.active_customers, 0) AS active_customers,
        100.0 * COALESCE(rc.active_customers, 0) / ci.cohort_size AS retention_pct
    FROM cohort_info AS ci
    CROSS JOIN periods AS p
    LEFT JOIN retention_counts AS rc
        ON rc.cohort_month = ci.cohort_month
       AND rc.period_number = p.period_number
    WHERE p.period_number <= ci.max_period
       AND ci.cohort_month >= '2017-01'
)
SELECT
    period_number,
    COUNT(*)                      AS n_cohorts,
    ROUND(AVG(retention_pct), 2)  AS avg_retention_pct
FROM cell_rates
GROUP BY period_number
ORDER BY period_number;







-- Q9: Best and worst cohort by month-1 retention
WITH delivered_orders AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        o.order_purchase_timestamp
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
cohort AS (

    SELECT DISTINCT
        customer_unique_id,
        strftime('%Y-%m',
            MIN(order_purchase_timestamp) OVER (PARTITION BY customer_unique_id)
        ) AS cohort_month
    FROM delivered_orders
),
activity AS (

    SELECT
        customer_unique_id,
        order_id,
        strftime('%Y-%m', order_purchase_timestamp) AS order_month
    FROM delivered_orders
),
cohort_activity AS (
    SELECT
        a.customer_unique_id,
        a.order_id,
        c.cohort_month,
        a.order_month,
        (CAST(substr(a.order_month, 1, 4) AS INTEGER) - CAST(substr(c.cohort_month, 1, 4) AS INTEGER)) * 12
      + (CAST(substr(a.order_month, 6, 2) AS INTEGER) - CAST(substr(c.cohort_month, 6, 2) AS INTEGER))
            AS period_number
    FROM activity AS a
    JOIN cohort AS c
        ON a.customer_unique_id = c.customer_unique_id
),
cohort_size AS (

    SELECT
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS cohort_size
    FROM cohort_activity
    WHERE period_number = 0
    GROUP BY cohort_month
),
data_end AS (
    
    SELECT MAX(order_month) AS last_month
    FROM activity
),
cohort_info AS (
    
    SELECT
        s.cohort_month,
        s.cohort_size,
        (CAST(substr(e.last_month, 1, 4) AS INTEGER) - CAST(substr(s.cohort_month, 1, 4) AS INTEGER)) * 12
      + (CAST(substr(e.last_month, 6, 2) AS INTEGER) - CAST(substr(s.cohort_month, 6, 2) AS INTEGER))
            AS max_period
    FROM cohort_size AS s
    CROSS JOIN data_end AS e
),
retention_counts AS (
  
    SELECT
        cohort_month,
        period_number,
        COUNT(DISTINCT customer_unique_id) AS active_customers
    FROM cohort_activity
    GROUP BY cohort_month, period_number
),
cohort_month1 AS (

    SELECT
        ci.cohort_month,
        ci.cohort_size,
        COALESCE(rc.active_customers, 0) AS month1_customers,
        ROUND(100.0 * COALESCE(rc.active_customers, 0) / ci.cohort_size, 2) AS month1_retention_pct
    FROM cohort_info AS ci
    LEFT JOIN retention_counts AS rc
        ON rc.cohort_month = ci.cohort_month
       AND rc.period_number = 1
    WHERE ci.max_period >= 1
      AND ci.cohort_month >= '2017-01'
),
ranked AS (
    
    SELECT
        *,
        RANK() OVER (ORDER BY month1_retention_pct DESC) AS best_rank,
        RANK() OVER (ORDER BY month1_retention_pct ASC)  AS worst_rank
    FROM cohort_month1
)
SELECT
    CASE WHEN best_rank = 1 THEN 'best' ELSE 'worst' END AS label,
    cohort_month,
    cohort_size,
    month1_customers,
    month1_retention_pct
FROM ranked
WHERE best_rank = 1 OR worst_rank = 1
ORDER BY month1_retention_pct DESC;








-- Q10: Revenue per cohort per period
WITH delivered_orders AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        o.order_purchase_timestamp
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
cohort AS (
    SELECT DISTINCT
        customer_unique_id,
        strftime('%Y-%m',
            MIN(order_purchase_timestamp) OVER (PARTITION BY customer_unique_id)
        ) AS cohort_month
    FROM delivered_orders
),
activity AS (
    SELECT
        customer_unique_id,
        order_id,
        strftime('%Y-%m', order_purchase_timestamp) AS order_month
    FROM delivered_orders
),
cohort_activity AS (
    SELECT
        a.customer_unique_id,
        a.order_id,
        c.cohort_month,
        a.order_month,
        (CAST(substr(a.order_month, 1, 4) AS INTEGER) - CAST(substr(c.cohort_month, 1, 4) AS INTEGER)) * 12
      + (CAST(substr(a.order_month, 6, 2) AS INTEGER) - CAST(substr(c.cohort_month, 6, 2) AS INTEGER))
            AS period_number
    FROM activity AS a
    JOIN cohort AS c
        ON a.customer_unique_id = c.customer_unique_id
),
order_revenue AS (
    SELECT
        order_id,
        SUM(price) AS order_revenue
    FROM order_items
    GROUP BY order_id
),
cohort_revenue AS (
    SELECT
        ca.cohort_month,
        ca.period_number,
        SUM(r.order_revenue) AS revenue
    FROM cohort_activity AS ca
    JOIN order_revenue AS r
        ON r.order_id = ca.order_id
    GROUP BY ca.cohort_month, ca.period_number
)
SELECT
    cohort_month,
    period_number,
    ROUND(revenue, 2) AS revenue
FROM cohort_revenue
ORDER BY cohort_month, period_number;