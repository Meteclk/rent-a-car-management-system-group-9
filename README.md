# Rent a Car Management System – CMPE341 Group 9

Web application and PostgreSQL 16 database for a car rental company with four branches.
Developed for the CMPE341 Database Design and Management course project.

**Team members:** Metehan Çelik, Tufan Aydın, Mert Dülgar, Deniz Demir

## Open the application

| Where | Address |
|---|---|
| Local, after `docker compose up` | http://localhost:8080 |
| Deployed server | http://SERVER_PUBLIC_IP/ |

## Test accounts

| Role | Username | Password | Permissions |
|---|---|---|---|
| Administrator | `admin` | `FleetDemo-Admin26` | All eight tables: view, add, update and delete records; vehicle availability search |
| Standard user | `desk` | `FleetDemo-Desk26` | View branches, vehicle categories and vehicles; vehicle availability search; no changes and no access to customer, employee, booking or payment data |

Passwords are never stored in plain text. They are stored as salted PBKDF2-SHA256 hashes
(600,000 iterations). Sessions use random tokens that are revoked at sign-out, cookies are
HttpOnly, and every form is protected by a CSRF token. Permissions are checked on the server
for every request; a forbidden page returns HTTP 403.

## Run with Docker

Requirement: Docker Desktop (Windows / macOS) or Docker Engine with the Compose plugin (Linux).

```sh
git clone https://github.com/Meteclk/rent-a-car-management-system-group-9.git
cd rent-a-car-management-system-group-9
docker compose up
```

On the first start Docker builds the web image, creates the PostgreSQL database with
`database/01_schema.sql` (tables and constraints) and `database/02_data.sql` (sample data),
and creates the two web accounts. Then open **http://localhost:8080**.
No .env file or manual SQL import is needed for the local demo.

- Stop: `Ctrl+C` or `docker compose down` (data is kept)
- Reset to the original sample data: `docker compose down -v`, then `docker compose up`
- If port 8080 is in use: create a `.env` file with `WEB_PORT=8081` and open http://localhost:8081
- Logs: `docker compose logs db web`

## Try it

1. Sign in as **desk** and open *Availability*. From 11 Nov 2026 10:00 to 14 Nov 2026 10:00,
   eight vehicles are available. Opening `/table/customer` returns 403. Sign out.
2. Sign in as **admin**. Open *Customer → Add record*, add a customer with an unused ID
   (e.g. 9001), edit it, then delete it. Deleting customer 1 is rejected because reservations
   reference that customer.
3. Business rules: a confirmed reservation cannot be made for a vehicle in maintenance,
   overlapping reservations of the same vehicle are rejected by the database, a rental cannot
   start from a canceled reservation, and entering a return time completes the reservation.

## Database access (DBeaver / pgAdmin)

| Setting | Value |
|---|---|
| Host | `localhost` |
| Port | `5433` |
| Database / User | `rentacar` |
| Password | `local-course-demo` (or `DB_PASSWORD` from `.env`) |

The database port is bound to the local machine only. The report queries are in
`database/03_queries.sql`.

## Deploy to a Linux server

On an Ubuntu virtual machine with Docker Engine and the Compose plugin installed:

```sh
git clone https://github.com/Meteclk/rent-a-car-management-system-group-9.git
cd rent-a-car-management-system-group-9
cp .env.example .env && chmod 600 .env
nano .env                  # set the passwords; WEB_BIND=0.0.0.0 and WEB_PORT=80
docker compose up -d
docker compose ps          # both services should be "healthy"
```

Allow inbound TCP port 80 in the cloud provider's security rules, then open
`http://SERVER_PUBLIC_IP/`. Do not open the database ports (5432/5433) to the Internet.

## Tests

- `tests/check_db.sql` – every table has at least three rows and overlapping reservations are rejected
- `tests/smoke.py` – login, roles, CSRF, availability, insert/update/delete over HTTP:
  `python3 tests/smoke.py http://localhost:8080`

The GitHub Actions workflow `.github/workflows/verify.yml` runs these tests and the report
queries on every push (see the *Actions* tab).

## Project structure

```
├── app/
│   ├── web.py              WSGI application: routes, roles, CRUD, availability
│   ├── accounts.py         Accounts, password hashing, sessions
│   ├── model.py            Tables and columns managed by the interface
│   ├── templates/          HTML pages (Jinja2)
│   └── static/style.css
├── database/
│   ├── 01_schema.sql       CREATE TABLE statements with constraints
│   ├── 02_data.sql         Sample data
│   └── 03_queries.sql      Queries used in the report
├── tests/                  check_db.sql, smoke.py
├── .github/workflows/      verify.yml
├── compose.yaml            PostgreSQL + web application
├── Dockerfile              Web application image (Gunicorn)
├── requirements.txt
└── .env.example            Settings for a server deployment
```

## Technologies

PostgreSQL 16 · Python 3.12 · Jinja2 · psycopg2 · Gunicorn · Docker Compose · GitHub Actions
