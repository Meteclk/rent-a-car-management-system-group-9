import os, re, secrets
from datetime import datetime
from pathlib import Path
from http.cookies import SimpleCookie, CookieError
from urllib.parse import parse_qs, urlencode
from contextlib import contextmanager
import psycopg2
from psycopg2.extras import RealDictCursor
from jinja2 import Environment, FileSystemLoader, select_autoescape
import accounts
from model import TABLES,NULLABLE

ROOT=Path(__file__).resolve().parent
env=Environment(loader=FileSystemLoader(ROOT/'templates'),autoescape=select_autoescape())
@contextmanager
def database():
    c=psycopg2.connect(host=os.getenv('PGHOST','db'),dbname=os.getenv('PGDATABASE','rentacar'),user=os.getenv('PGUSER','rentacar'),password=os.environ['PGPASSWORD'],cursor_factory=RealDictCursor,connect_timeout=5)
    try:
        with c, c.cursor() as cur: yield cur
    finally:c.close()

def allowed(role,name,action):
    return name in TABLES and (role=='admin' or role=='standard' and action=='list' and name in ('vehicle','vehicle_category','branch'))

def app(e,start):
    path=e.get('PATH_INFO','/'); method=e.get('REQUEST_METHOD','GET'); headers=[]
    def send(status,body='',typ='text/html; charset=utf-8'):
        data=body.encode();start(status,[('Content-Type',typ),('Content-Length',str(len(data))),('Cache-Control','no-store'),('X-Content-Type-Options','nosniff'),('X-Frame-Options','DENY')]+headers);return [data]
    def go(url):
        headers.append(('Location',url));return send('303 See Other')
    if path=='/static/style.css':return send('200 OK',(ROOT/'static/style.css').read_text(),'text/css')
    if path=='/health':
        try:
            with database() as cur:cur.execute('SELECT 1 FROM vehicle LIMIT 1')
            return send('200 OK','ready','text/plain')
        except psycopg2.Error:return send('503 Service Unavailable','not ready','text/plain')
    cookie=SimpleCookie()
    try:cookie.load(e.get('HTTP_COOKIE',''))
    except CookieError:pass
    token=cookie['sid'].value if 'sid' in cookie else ''
    state=accounts.lookup(token) if token else None
    name,role,csrf=state or (None,None,None)
    def cookie_set(t):
        headers.append(('Set-Cookie','sid='+t+'; Path=/; HttpOnly; SameSite=Lax'+('; Secure' if os.getenv('HTTPS_COOKIE')=='1' else '')))
    def page(template,status='200 OK',**kw):
        return send(status,env.get_template(template+'.html').render(username=name,role=role,csrf=csrf,tables=[t for t in TABLES if allowed(role,t,'list')],**kw))
    def error(status,msg):return page('error',status,message=msg)
    if method not in ('GET','POST'):return error('405 Method Not Allowed','Use GET or POST.')
    form={}
    if method=='POST':
        try:n=int(e.get('CONTENT_LENGTH') or 0)
        except ValueError:n=-1
        if not 0<=n<=65536:return error('413 Payload Too Large','Invalid form size.')
        try:form={k:v[-1] for k,v in parse_qs(e['wsgi.input'].read(n).decode(),keep_blank_values=True,max_num_fields=60).items()}
        except ValueError:return error('400 Bad Request','Invalid form.')
        if not csrf or not secrets.compare_digest(form.get('csrf','').encode(),csrf.encode()):return error('403 Forbidden','Session expired or invalid form. Open the page again.')
    if path=='/login':
        if name:return go('/')
        if method=='GET':
            if not csrf:
                token,csrf=accounts.issue();cookie_set(token)
            return page('login')
        if accounts.authenticate(form.get('username',''),form.get('password','')):
            accounts.revoke(token);cookie_set(accounts.issue(form['username'])[0]);return go('/')
        return page('login','401 Unauthorized',message='Incorrect username or password.')
    if not name:return go('/login')
    if path=='/logout' and method=='POST':
        accounts.revoke(token);cookie_set('');return go('/login')
    if path=='/' and method=='GET':return page('index')
    try:
        if path=='/availability':
            rows=[];a=form.get('start','');b=form.get('end','')
            if method=='POST':
                if not a or not b or datetime.fromisoformat(a)>=datetime.fromisoformat(b):raise ValueError('Invalid dates')
                with database() as cur:
                    cur.execute("""SELECT v.plate,v.brand,v.model,b.branch_name,v.daily_rate FROM vehicle v JOIN branch b ON b.branch_id=v.branch_id WHERE v.operational_status='operational' AND NOT EXISTS (SELECT 1 FROM reservation r WHERE r.vehicle_id=v.vehicle_id AND r.status IN ('confirmed','completed') AND r.start_at<%s AND r.end_at>%s) ORDER BY v.daily_rate,v.plate""",(b,a));rows=cur.fetchall()
            return page('availability',rows=rows,searched=method=='POST',start=a,end=b)
        match=re.fullmatch(r'/table/([a-z_]+)(?:/(new)|/([0-9]+)/(edit|delete))?',path)
        if not match or match[1] not in TABLES:return error('404 Not Found','Page not found.')
        t,new,pk,op=match.groups();action=new or op or 'list'; cols=TABLES[t]; key=cols[0]
        if not allowed(role,t,action):return error('403 Forbidden','Your account does not have permission for this operation.')
        if (action=='delete' and method!='POST') or (action=='list' and method!='GET'):return error('405 Method Not Allowed','Unsupported operation.')
        # Identifiers come exclusively from the fixed table/column allowlist; all input values use bound parameters.
        with database() as cur:
            if action=='list':
                cur.execute(f'SELECT * FROM {t} ORDER BY {key}')
                notice=parse_qs(e.get('QUERY_STRING','')).get('notice',[''])[0]
                return page('table',table=t,cols=cols,rows=cur.fetchall(),message={'added':'Record added.','updated':'Record updated.','deleted':'Record deleted.'}.get(notice))
            if action=='delete':
                cur.execute(f'DELETE FROM {t} WHERE {key}=%s',(pk,))
                if not cur.rowcount:return error('404 Not Found','Record not found.')
                return go('/table/'+t+'?notice=deleted')
            fields=cols if new else cols[1:];row={}
            if method=='GET':
                if not new:
                    cur.execute(f'SELECT * FROM {t} WHERE {key}=%s',(pk,));row=cur.fetchone()
                    if row is None:return error('404 Not Found','Record not found.')
                return page('edit',table=t,fields=fields,row=dict(row),nullable=NULLABLE,adding=bool(new))
            vals=[form.get(k,'').strip() or None for k in fields]; data=dict(zip(fields,vals))
            if any(data[k] is None and k not in NULLABLE for k in fields):return error('400 Bad Request','Fill in all required fields.')
            if t=='reservation' and data['status']=='confirmed':
                cur.execute('SELECT operational_status FROM vehicle WHERE vehicle_id=%s FOR UPDATE',(data['vehicle_id'],));v=cur.fetchone()
                if not v or v['operational_status']!='operational':return error('409 Conflict','Select an operational vehicle.')
            if t=='reservation' and not new and data['status']=='canceled':
                cur.execute('SELECT 1 FROM rental WHERE reservation_id=%s',(pk,))
                if cur.fetchone():return error('409 Conflict','A reservation with a rental cannot be canceled.')
            if t=='rental':
                cur.execute('SELECT r.status,v.operational_status FROM reservation r JOIN vehicle v ON v.vehicle_id=r.vehicle_id WHERE r.reservation_id=%s FOR UPDATE',(data['reservation_id'],));booking=cur.fetchone()
                if not booking or booking['status']=='canceled' or new and (booking['status']!='confirmed' or booking['operational_status']!='operational'):return error('409 Conflict','The booking is not eligible for handover.')
            if new:
                cur.execute(f"INSERT INTO {t} ({','.join(fields)}) VALUES ({','.join(['%s']*len(fields))})",vals);notice='added'
            else:
                cur.execute(f"UPDATE {t} SET {','.join(k+'=%s' for k in fields)} WHERE {key}=%s",vals+[pk]);notice='updated'
                if not cur.rowcount:return error('404 Not Found','Record not found.')
            if t=='rental' and data.get('return_at'):
                cur.execute("UPDATE reservation SET status='completed' WHERE reservation_id=%s",(data['reservation_id'],))
        return go('/table/'+t+'?'+urlencode({'notice':notice}))
    except psycopg2.IntegrityError:return error('409 Conflict','The record violates a database rule. Check references, unique values, dates and reservation overlaps.')
    except (ValueError,TypeError,psycopg2.DataError):return error('400 Bad Request','Check the dates, numeric values and required fields.')
    except psycopg2.OperationalError:return error('503 Service Unavailable','The database is unavailable.')
