CREATE EXTENSION IF NOT EXISTS btree_gist;
CREATE TABLE branch (
    branch_id    INTEGER      PRIMARY KEY,
    branch_name  VARCHAR(80)  NOT NULL UNIQUE,
    city         VARCHAR(50)  NOT NULL,
    address      VARCHAR(200) NOT NULL,
    phone        VARCHAR(25)  NOT NULL
);
CREATE TABLE employee (
    employee_id  INTEGER       PRIMARY KEY,
    branch_id    INTEGER       NOT NULL REFERENCES branch(branch_id),
    first_name   VARCHAR(50)   NOT NULL,
    last_name    VARCHAR(50)   NOT NULL,
    position     VARCHAR(20)   NOT NULL
                 CHECK (position IN ('manager', 'agent', 'accountant')),
    salary       NUMERIC(10,2) NOT NULL CHECK (salary > 0),
    hire_date    DATE          NOT NULL
);
CREATE TABLE customer (
    customer_id    INTEGER      PRIMARY KEY,
    first_name     VARCHAR(50)  NOT NULL,
    last_name      VARCHAR(50)  NOT NULL,
    phone          VARCHAR(25)  NOT NULL,
    email          VARCHAR(100) UNIQUE,
    birth_date     DATE         NOT NULL,
    licence_number VARCHAR(40)  NOT NULL UNIQUE
);
CREATE TABLE vehicle_category (
    category_id   INTEGER      PRIMARY KEY,
    category_name VARCHAR(50)  NOT NULL UNIQUE,
    description   VARCHAR(200)
);
CREATE TABLE vehicle (
    vehicle_id         INTEGER       PRIMARY KEY,
    category_id        INTEGER       NOT NULL REFERENCES vehicle_category(category_id),
    branch_id          INTEGER       NOT NULL REFERENCES branch(branch_id),
    plate              VARCHAR(20)   NOT NULL UNIQUE,
    brand              VARCHAR(50)   NOT NULL,
    model              VARCHAR(50)   NOT NULL,
    model_year         INTEGER       NOT NULL CHECK (model_year BETWEEN 2000 AND 2030),
    mileage_km         INTEGER       NOT NULL CHECK (mileage_km >= 0),
    daily_rate         NUMERIC(10,2) NOT NULL CHECK (daily_rate > 0),
    operational_status VARCHAR(20)   NOT NULL
                       CHECK (operational_status IN ('operational', 'maintenance'))
);
CREATE TABLE reservation (
    reservation_id    INTEGER       PRIMARY KEY,
    customer_id       INTEGER       NOT NULL REFERENCES customer(customer_id),
    vehicle_id        INTEGER       NOT NULL REFERENCES vehicle(vehicle_id),
    start_at          TIMESTAMP     NOT NULL,
    end_at            TIMESTAMP     NOT NULL,
    agreed_daily_rate NUMERIC(10,2) NOT NULL CHECK (agreed_daily_rate > 0),
    status            VARCHAR(20)   NOT NULL
                      CHECK (status IN ('confirmed', 'completed', 'canceled')),
    CHECK (end_at > start_at),
    EXCLUDE USING gist (vehicle_id WITH =,
                        tsrange(start_at, end_at, '[)') WITH &&)
            WHERE (status IN ('confirmed', 'completed'))
);
CREATE TABLE rental (
    rental_id      INTEGER   PRIMARY KEY,
    reservation_id INTEGER   NOT NULL UNIQUE REFERENCES reservation(reservation_id),
    employee_id    INTEGER   NOT NULL REFERENCES employee(employee_id),
    pickup_at      TIMESTAMP NOT NULL,
    return_at      TIMESTAMP,
    pickup_km      INTEGER   NOT NULL CHECK (pickup_km >= 0),
    return_km      INTEGER,
    CHECK ((return_at IS NULL AND return_km IS NULL) OR
           (return_at IS NOT NULL AND return_km IS NOT NULL
            AND return_at >= pickup_at AND return_km >= pickup_km))
);
CREATE TABLE payment (
    payment_id     INTEGER       PRIMARY KEY,
    rental_id      INTEGER       NOT NULL REFERENCES rental(rental_id),
    amount         NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(20)   NOT NULL
                   CHECK (payment_method IN ('cash', 'card', 'transfer')),
    paid_at        TIMESTAMP     NOT NULL
);
