INSERT INTO branch VALUES
(1, 'Ankara Kizilay', 'Ankara', 'Ataturk Blv. No:45, Cankaya', '0312 444 1001'),
(2, 'Istanbul Airport', 'Istanbul', 'Istanbul Airport, Arrivals Hall', '0212 444 1002'),
(3, 'Izmir Alsancak', 'Izmir', 'Kibris Sehitleri Cd. No:12', '0232 444 1003'),
(4, 'Antalya Lara', 'Antalya', 'Lara Cd. No:88, Muratpasa', '0242 444 1004');
INSERT INTO employee VALUES
(1, 1, 'Selin', 'Aksoy', 'manager', 62000, '2019-03-01'),
(2, 1, 'Emre', 'Kaya', 'agent', 38000, '2022-06-15'),
(3, 2, 'Burak', 'Sahin', 'manager', 65000, '2018-09-10'),
(4, 2, 'Zeynep', 'Arslan', 'agent', 39000, '2021-04-05'),
(5, 2, 'Can', 'Ozturk', 'agent', 37000, '2023-02-20'),
(6, 3, 'Deniz', 'Yildiz', 'agent', 38000, '2020-11-02'),
(7, 3, 'Ece', 'Polat', 'accountant', 45000, '2021-01-18'),
(8, 4, 'Kerem', 'Celik', 'agent', 37500, '2022-05-09'),
(9, 4, 'Gamze', 'Kurt', 'manager', 60000, '2019-07-22'),
(10, 3, 'Oya', 'Tekin', 'manager', 61000, '2020-01-13');
INSERT INTO customer VALUES
(1, 'Mert', 'Demir', '0532 111 2233', 'mdemir@mail.com', '1995-04-12', 'TR-B-104523'),
(2, 'Ayse', 'Kaya', '0533 222 3344', 'akaya@mail.com', '1990-08-30', 'TR-B-208871'),
(3, 'Ali', 'Yilmaz', '0542 333 4455', 'ayilmaz@mail.com', '1988-01-05', 'TR-B-301122'),
(4, 'Elif', 'Sen', '0505 444 5566', 'esen@mail.com', '1998-11-19', 'TR-B-412340'),
(5, 'Hakan', 'Dogan', '0535 555 6677', 'hdogan@mail.com', '1985-06-23', 'TR-B-509981'),
(6, 'Merve', 'Aydin', '0544 666 7788', 'maydin@mail.com', '1993-02-14', 'TR-B-617745'),
(7, 'Onur', 'Kilic', '0530 777 8899', 'okilic@mail.com', '1979-09-08', 'TR-B-720036'),
(8, 'Buse', 'Erdem', '0555 888 9900', 'berdem@mail.com', '2000-12-01', 'TR-B-835512');
INSERT INTO vehicle_category VALUES
(1, 'Economy', 'Small, fuel-efficient city cars'),
(2, 'Sedan', 'Mid-size cars for families and business trips'),
(3, 'SUV', 'Sport utility vehicles with large luggage space'),
(4, 'Luxury', 'Premium cars for special occasions');
INSERT INTO vehicle VALUES
(1, 1, 1, '06 AB 101', 'Renault', 'Clio', 2023, 18950, 1100, 'operational'),
(2, 1, 1, '06 AB 102', 'Fiat', 'Egea', 2022, 24300, 1000, 'operational'),
(3, 2, 2, '34 CD 201', 'Toyota', 'Corolla', 2024, 10900, 1600, 'operational'),
(4, 2, 2, '34 CD 202', 'Volkswagen', 'Passat', 2023, 15880, 2100, 'operational'),
(5, 3, 2, '34 CD 203', 'Hyundai', 'Tucson', 2024, 7650, 2500, 'operational'),
(6, 3, 3, '35 EF 301', 'Peugeot', '2008', 2023, 13120, 2200, 'operational'),
(7, 2, 3, '35 EF 302', 'Renault', 'Megane', 2022, 31200, 1500, 'operational'),
(8, 3, 4, '07 GH 401', 'Dacia', 'Duster', 2023, 23100, 1900, 'operational'),
(9, 4, 4, '07 GH 402', 'BMW', '520i', 2024, 3480, 4500, 'operational'),
(10, 4, 2, '34 CD 204', 'Mercedes-Benz', 'E200', 2024, 5200, 5000, 'maintenance');
INSERT INTO reservation VALUES
(1, 1, 1, '2026-10-01 10:00', '2026-10-04 10:00', 1100, 'completed'),
(2, 2, 3, '2026-10-03 09:00', '2026-10-07 09:00', 1600, 'completed'),
(3, 3, 5, '2026-10-05 12:00', '2026-10-10 12:00', 2500, 'completed'),
(4, 4, 9, '2026-10-10 10:00', '2026-10-12 10:00', 4500, 'completed'),
(5, 5, 6, '2026-10-12 10:00', '2026-10-15 10:00', 2200, 'completed'),
(6, 1, 4, '2026-10-18 10:00', '2026-10-21 10:00', 2100, 'completed'),
(7, 6, 3, '2026-10-20 10:00', '2026-10-25 10:00', 1600, 'completed'),
(8, 7, 8, '2026-10-25 10:00', '2026-10-28 10:00', 1900, 'completed'),
(9, 2, 1, '2026-11-05 10:00', '2026-11-12 10:00', 1100, 'confirmed'),
(10, 8, 5, '2026-11-07 10:00', '2026-11-10 10:00', 2500, 'confirmed'),
(11, 3, 2, '2026-11-15 10:00', '2026-11-18 10:00', 1000, 'confirmed'),
(12, 5, 9, '2026-11-20 10:00', '2026-11-22 10:00', 4500, 'canceled');
INSERT INTO rental VALUES
(1, 1, 2, '2026-10-01 10:15', '2026-10-04 09:40', 18200, 18950),
(2, 2, 4, '2026-10-03 09:10', '2026-10-07 08:55', 9100, 9920),
(3, 3, 4, '2026-10-05 12:20', '2026-10-10 11:30', 6400, 7650),
(4, 4, 8, '2026-10-10 10:05', '2026-10-12 09:50', 3100, 3480),
(5, 5, 6, '2026-10-12 10:30', '2026-10-15 10:00', 12500, 13120),
(6, 6, 5, '2026-10-18 10:00', '2026-10-21 09:30', 15300, 15880),
(7, 7, 5, '2026-10-20 10:20', '2026-10-25 10:10', 9920, 10900),
(8, 8, 8, '2026-10-25 10:00', '2026-10-28 09:45', 22400, 23100),
(9, 9, 2, '2026-11-05 10:10', NULL, 18950, NULL),
(10, 10, 4, '2026-11-07 10:15', NULL, 7650, NULL);
INSERT INTO payment VALUES
(1, 1, 3300, 'card', '2026-10-04 09:45'),
(2, 2, 6400, 'card', '2026-10-07 09:00'),
(3, 3, 5000, 'card', '2026-10-05 12:25'),
(4, 3, 7500, 'transfer', '2026-10-10 11:40'),
(5, 4, 9000, 'card', '2026-10-12 09:55'),
(6, 5, 6600, 'cash', '2026-10-15 10:05'),
(7, 6, 6300, 'card', '2026-10-21 09:35'),
(8, 7, 4000, 'cash', '2026-10-20 10:25'),
(9, 7, 4000, 'card', '2026-10-25 10:15'),
(10, 8, 5700, 'transfer', '2026-10-28 09:50'),
(11, 9, 2000, 'card', '2026-11-05 10:15'),
(12, 10, 2500, 'cash', '2026-11-07 10:20');
