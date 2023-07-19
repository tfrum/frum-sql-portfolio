-- So we want to create a view that tells us each actor's total sales through our stores.
-- That's going to require us to link their ID to their movie, thent he movie to every sale of that movie.
-- It's fine if some people are in the same movie.  We're looking for a poison-pill here.

-- This function generates out initial view of actor sales.
CREATE OR REPLACE VIEW actor_sales AS
SELECT a.actor_id, a.first_name, a.last_name, SUM(p.amount) AS total_sales
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f        ON fa.film_id = f.film_id
JOIN inventory i   ON f.film_id = i.film_id
JOIN rental r      ON i.inventory_id = r.inventory_id
JOIN payment p     ON r.rental_id = p.rental_id
GROUP BY a.actor_id, a.first_name, a.last_name;





-- This function returns a boolean value of whether or not an entry is above the mean for its column
-- I wanted to write a version that did median, too, but I'm not good enough or not patient enough
CREATE OR REPLACE FUNCTION calculate_mean()
  RETURNS DECIMAL AS $$
DECLARE
  mean_val DECIMAL;
BEGIN
  -- Calculate the mean
  SELECT AVG(total_sales) INTO mean_val FROM actor_sales;
  
  RETURN mean_val;
END;
$$ LANGUAGE plpgsql;





-- here we create a materialized view of our transformed information
CREATE MATERIALIZED VIEW actor_sales_mean_view AS
SELECT actor_id, first_name, last_name, total_sales,
  (total_sales > calculate_mean()) AS is_above_mean
FROM actor_sales;
REFRESH MATERIALIZED VIEW actor_sales_mean_view;






-- Finally let's select the materialized view ordered by the is_above_mean and their total_sales
SELECT first_name, last_name, total_sales, is_above_mean
FROM actor_sales_mean_view
ORDER BY is_above_mean, total_sales;





-- here is where we need to refresh and update our summary table
CREATE OR REPLACE FUNCTION refresh_materialized_view()
  RETURNS TRIGGER AS $$
BEGIN
  IF date_part('day', CURRENT_DATE) = 1 THEN
    REFRESH MATERIALIZED VIEW actor_sales_mean_view;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- and the trigger for it
CREATE TRIGGER refresh_materialized_view_trigger
  AFTER INSERT OR UPDATE OR DELETE ON actor_sales
  FOR EACH STATEMENT
  WHEN (date_part('day', CURRENT_DATE) = 1)
  EXECUTE FUNCTION refresh_materialized_view();
 
 
 
 -- and here is the procedure that we could use to automate and skip some of that code
CREATE OR REPLACE PROCEDURE refresh_actor_sales_mean_view()
AS
BEGIN
   REFRESH MATERIALIZED VIEW actor_sales_mean_view;
END;


