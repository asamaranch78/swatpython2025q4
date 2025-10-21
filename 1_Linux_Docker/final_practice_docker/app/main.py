from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from database import Base, engine, SessionLocal
from models import Usuario

app = FastAPI()
Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
def root():
    return {"message": "API de usuarios"}

@app.post("/usuarios/")
def create_user(nombre:str, email:str, db: Session = Depends(get_db)):
    if(db.query(Usuario).filter(Usuario.email == email).first()):
        raise HTTPException(status_code=400, details="El email ya existe")
    nuevo = Usuario(nombre=nombre, email=email)
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo

@app.get("/usuarios/")
def list_users(db: Session = Depends (get_db)):
    return db.query(Usuario).all()

@app.get("/usuarios/{usuario_id}")
def get_user_byId(usuario_id: int, db:Session = Depends (get_db)):
    usuario = db.query(Usuario).filter(Usuario.id == usuario_id).first()
    if not usuario:
        raise HTTPException(status_code=404, details="Usuario no encontrado")
    return usuario

@app.delete("/usuarios/{usuario_id}")
def delete_user(usuario_id: int, db:Session = Depends (get_db)):
    usuario = db.query(Usuario).filter(Usuario.id == usuario_id).first()
    if not usuario:
        raise HTTPException(status_code=404, details="Usuario no encontrado")
    db.delete(usuario)
    db.commit()
    return {"message": "usuario eliminado correctamente"}





