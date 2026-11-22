"""Private web identities and expiring sessions. Only salted password hashes are persisted."""
import hashlib, hmac, os, secrets, sqlite3, time
from contextlib import closing
from pathlib import Path

def db():
    return sqlite3.connect(Path(os.environ['AUTH_DIR'])/'access.sqlite',timeout=15)
def digest(s): return hashlib.sha256(s.encode()).hexdigest()
def derive(password,salt):
    return hashlib.pbkdf2_hmac('sha256',password.encode(),bytes.fromhex(salt),600000).hex()
def setup():
    Path(os.environ['AUTH_DIR']).mkdir(parents=True,exist_ok=True)
    with closing(db()) as c,c:
        c.executescript('''CREATE TABLE IF NOT EXISTS account(name TEXT PRIMARY KEY, role TEXT NOT NULL, salt TEXT NOT NULL, hash TEXT NOT NULL);
        CREATE TABLE IF NOT EXISTS session(id TEXT PRIMARY KEY, name TEXT, csrf TEXT NOT NULL, expires INTEGER NOT NULL);''')
        for name,role,pw in [('admin','admin',os.environ.get('ADMIN_PASSWORD','FleetDemo-Admin26')),('desk','standard',os.environ.get('DESK_PASSWORD','FleetDemo-Desk26'))]:
            if not c.execute('SELECT 1 FROM account WHERE name=?',(name,)).fetchone():
                salt=secrets.token_hex(16)
                c.execute('INSERT OR IGNORE INTO account VALUES(?,?,?,?)',(name,role,salt,derive(pw,salt)))
def authenticate(name,password):
    with closing(db()) as c:
        r=c.execute('SELECT salt,hash FROM account WHERE name=?',(name,)).fetchone()
    salt,expected=r or ('0'*32,'0'*64)
    return hmac.compare_digest(derive(password,salt),expected) and r is not None
def issue(name=None):
    token=secrets.token_urlsafe(32);csrf=secrets.token_urlsafe(32)
    with closing(db()) as c,c:
        c.execute('DELETE FROM session WHERE expires<=?',(int(time.time()),))
        c.execute('INSERT INTO session VALUES(?,?,?,?)',(digest(token),name,csrf,int(time.time())+(3600 if name else 600)))
    return token,csrf
def lookup(token):
    with closing(db()) as c:
        return c.execute('SELECT s.name,a.role,s.csrf FROM session s LEFT JOIN account a ON a.name=s.name WHERE s.id=? AND expires>?',(digest(token),int(time.time()))).fetchone()
def revoke(token):
    with closing(db()) as c,c:c.execute('DELETE FROM session WHERE id=?',(digest(token),))
