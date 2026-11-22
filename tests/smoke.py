"""Run against a disposable, seeded instance (standard library only)."""
import sys,os,urllib.request as u, urllib.parse as p, urllib.error as err,http.cookiejar,re,secrets
base=sys.argv[1].rstrip('/')
def browser():return u.build_opener(u.HTTPCookieProcessor(http.cookiejar.CookieJar()))
def call(b,path,data=None):
    try:r=b.open(base+path,p.urlencode(data).encode() if data is not None else None,timeout=12)
    except err.HTTPError as e:r=e
    with r:return r.status,r.read().decode()
def token(html):return re.search('name="csrf" value="([^"]+)"',html)[1]
def login(b,user,pw):
    code,html=call(b,'/login');assert code==200
    code,html=call(b,'/login',dict(username=user,password=pw,csrf=token(html)))
    assert code==200 and 'Rental desk' in html
    return token(html)
b=browser()
assert 'Staff sign in' in call(b,'/table/customer')[1]
guest=token(call(b,'/login')[1])
assert call(b,'/login',dict(username='admin',password='not-the-password',csrf=guest))[0]==401
s=login(b,'desk',os.getenv('DESK_PASSWORD','FleetDemo-Desk26'))
assert call(b,'/table/customer')[0]==403
assert call(b,'/table/vehicle/new',dict(csrf=s))[0]==403
assert call(b,'/table/vehicle/1/edit',dict(csrf=s))[0]==403
assert call(b,'/table/vehicle/1/delete',dict(csrf=s))[0]==403
assert 'Add record' not in call(b,'/table/vehicle')[1]
code,html=call(b,'/availability',dict(csrf=s,start='2026-11-11T10:00',end='2026-11-14T10:00'));assert code==200 and '8 matching vehicles' in html and '06 AB 101' not in html
call(b,'/logout',dict(csrf=s));assert 'Staff sign in' in call(b,'/')[1]
a=browser(); s=login(a,'admin',os.getenv('ADMIN_PASSWORD','FleetDemo-Admin26'))
k=str(1000000+secrets.randbelow(90000000));record=dict(customer_id=k,first_name='Demo',last_name='Verification',phone='000',email='',birth_date='1995-01-01',licence_number='TEST-'+k)
assert call(a,'/table/customer/new',record)[0]==403
record['csrf']=s;code,html=call(a,'/table/customer/new',record);assert code==200 and 'Record added.' in html and 'TEST-'+k in html
record['last_name']='Updated'+k
code,html=call(a,'/table/customer/'+k+'/edit',record);assert code==200 and 'Updated'+k in html
code,html=call(a,'/table/customer/'+k+'/delete',dict(csrf=s));assert code==200 and 'Record deleted.' in html and 'TEST-'+k not in html
assert call(a,'/table/customer/1/delete',dict(csrf=s))[0]==409
print('PASS: login, role boundaries, availability, logout, CSRF, insert/update/delete and protected references')
