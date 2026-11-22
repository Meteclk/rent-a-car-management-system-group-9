SELECT r.rental_id,
       c.first_name || ' ' || c.last_name AS customer,
       v.plate, v.brand || ' ' || v.model AS vehicle,
       b.branch_name, r.pickup_at::date AS pickup_date,
       r.return_km - r.pickup_km AS km_driven
FROM rental r
JOIN reservation rs ON rs.reservation_id = r.reservation_id
JOIN customer c     ON c.customer_id     = rs.customer_id
JOIN vehicle v      ON v.vehicle_id      = rs.vehicle_id
JOIN branch b       ON b.branch_id       = v.branch_id
WHERE r.return_at IS NOT NULL
ORDER BY r.pickup_at;

SELECT b.branch_name,
       COUNT(DISTINCT r.rental_id) AS rental_count,
       SUM(p.amount)               AS total_revenue
FROM branch b
JOIN vehicle v      ON v.branch_id       = b.branch_id
JOIN reservation rs ON rs.vehicle_id     = v.vehicle_id
JOIN rental r       ON r.reservation_id  = rs.reservation_id
JOIN payment p      ON p.rental_id       = r.rental_id
GROUP BY b.branch_id, b.branch_name
ORDER BY total_revenue DESC;

SELECT plate, brand, model, daily_rate
FROM vehicle
WHERE daily_rate > (SELECT AVG(daily_rate) FROM vehicle)
ORDER BY daily_rate DESC;

SELECT v.plate, v.brand, v.model, vc.category_name, b.city, v.daily_rate
FROM vehicle v
JOIN vehicle_category vc ON vc.category_id = v.category_id
JOIN branch b            ON b.branch_id    = v.branch_id
WHERE v.operational_status = 'operational'
  AND NOT EXISTS (
        SELECT 1
        FROM reservation rs
        WHERE rs.vehicle_id = v.vehicle_id
          AND rs.status IN ('confirmed', 'completed')
          AND rs.start_at < TIMESTAMP '2026-11-14 10:00'
          AND rs.end_at   > TIMESTAMP '2026-11-11 10:00')
ORDER BY v.daily_rate;
