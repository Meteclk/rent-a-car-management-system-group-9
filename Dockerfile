FROM python:3.12-slim
WORKDIR /opt/rental
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && useradd --system --uid 10001 rental && install -d -o rental /var/lib/rental
COPY app/ .
USER rental
ENV AUTH_DIR=/var/lib/rental PYTHONDONTWRITEBYTECODE=1
EXPOSE 8000
CMD ["sh","-c","python -c 'import accounts; accounts.setup()' && exec gunicorn -w 2 -b 0.0.0.0:8000 web:app"]
