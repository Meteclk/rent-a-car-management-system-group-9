-- Run against a fresh course demo; all test writes are rolled back.
BEGIN;
DO $$
DECLARE t text; n integer;
BEGIN
  FOREACH t IN ARRAY ARRAY['branch','employee','customer','vehicle_category','vehicle','reservation','rental','payment'] LOOP
    EXECUTE format('SELECT count(*) FROM %I',t) INTO n;
    IF n<3 THEN RAISE EXCEPTION 'Expected at least three rows in %',t; END IF;
  END LOOP;
  BEGIN
    INSERT INTO reservation VALUES(990001,1,3,'2026-10-22 10:00','2026-10-23 10:00',1600,'confirmed');
    RAISE EXCEPTION 'Overlap should have failed';
  EXCEPTION WHEN exclusion_violation THEN NULL;
  END;
END $$;
ROLLBACK;
