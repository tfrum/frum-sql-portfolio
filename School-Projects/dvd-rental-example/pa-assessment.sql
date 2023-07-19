DROP TABLE IF EXISTS detailed_table;
DROP TABLE IF EXISTS summary_table;



CREATE TABLE detailed_table (
    rental_id INT,
    rental_date TIMESTAMP,
    return_date TIMESTAMP,
    customer_id INT,
    inventory_id INT,
    rental_duration INT,
    rental_rate NUMERIC,
    replacement_cost NUMERIC
);



CREATE TABLE summary_table (
    month DATE,
    total_revenue NUMERIC,
    year_to_date_sales NUMERIC,
    average_monthly_sales NUMERIC
);




CREATE OR REPLACE FUNCTION update_summary_table() RETURNS TRIGGER AS
$$
BEGIN
    DELETE FROM summary_table;

    INSERT INTO summary_table (month, total_revenue, year_to_date_sales, average_monthly_sales)
    SELECT
        month,
        SUM(total_revenue) AS total_revenue,
        SUM(SUM(total_revenue)) OVER (ORDER BY month) AS year_to_date_sales,
        AVG(SUM(total_revenue)) OVER (ORDER BY month) AS average_monthly_sales
    FROM (
        SELECT
            DATE_TRUNC('month', rental_date) AS month,
            rental_duration * rental_rate AS total_revenue
        FROM
            detailed_table
    ) sub
    GROUP BY
        month;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;






CREATE TRIGGER trigger_update_summary_table
AFTER INSERT OR DELETE OR UPDATE ON detailed_table
FOR EACH STATEMENT
EXECUTE FUNCTION update_summary_table();








CREATE OR REPLACE PROCEDURE refresh_report_data() AS
$$
BEGIN
    TRUNCATE detailed_table;
    INSERT INTO detailed_table
    SELECT
        r.rental_id,
        r.rental_date,
        r.return_date,
        r.customer_id,
        i.inventory_id,
        EXTRACT(DAY FROM (r.return_date - r.rental_date)) AS rental_duration,
        f.rental_rate,
        f.replacement_cost
    FROM
        rental r
        JOIN inventory i ON r.inventory_id = i.inventory_id
        JOIN film f ON i.film_id = f.film_id;

    DELETE FROM summary_table;

    INSERT INTO summary_table (month, total_revenue, year_to_date_sales, average_monthly_sales)
    WITH monthly_revenue AS (
        SELECT
            DATE_TRUNC('month', rental_date) AS month,
            rental_duration * rental_rate AS revenue
        FROM
            detailed_table
    )
    SELECT
        month,
        SUM(revenue) AS total_revenue,
        SUM(SUM(revenue)) OVER (ORDER BY month) AS year_to_date_sales,
        AVG(SUM(revenue)) OVER (ORDER BY month) AS average_monthly_sales
    FROM
        monthly_revenue
    GROUP BY
        month;

END;
$$ LANGUAGE plpgsql;

