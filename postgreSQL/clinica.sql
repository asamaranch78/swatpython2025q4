
DROP TABLE IF EXISTS CITASCLINICA.CITA;
DROP TABLE IF EXISTS CITASCLINICA.EXPEDIENTE;
DROP TABLE IF EXISTS CITASCLINICA.ESPECIALISTA;
DROP TABLE IF EXISTS CITASCLINICA.PACIENTE;
DROP SCHEMA IF EXISTS CitasClinica;

CREATE SCHEMA CitasClinica;

CREATE TABLE CITASCLINICA.PACIENTE (
	pk_idPaciente INT NOT NULL,
	nombre VARCHAR(20) NOT NULL,
	apellido VARCHAR(20) NOT NULL,
	sexo CHAR(1) NOT NULL,
	fechaNacimiento DATE NOT NULL,
	ciudad VARCHAR(20) NOT NULL,
	provincia VARCHAR(20) NOT NULL,
	telefono CHAR(10) NOT NULL,
	tipoSangre VARCHAR(10) NOT NULL,
	PRIMARY KEY (pk_idPaciente)
);

CREATE TABLE CITASCLINICA.ESPECIALISTA(
	pk_idEspecialista INT NOT NULL,
	nombre VARCHAR(20) NOT NULL,
	apellido VARCHAR(20) NOT NULL,
	sexo CHAR(1) NOT NULL,
	fechaNacimiento DATE NOT NULL,
	especialidad VARCHAR(30) NOT NULL,
	PRIMARY KEY (pk_idEspecialista)
);

CREATE TABLE CITASCLINICA.EXPEDIENTE (
	pk_idExpediente INT NOT NULL,
	fk_idPaciente INT NOT NULL,
	fk_idEspecialista INT NOT NULL,
	enfermedad VARCHAR(50) NOT NULL,
	descripcion VARCHAR(50) NOT NULL,
	fecha TIMESTAMP NOT NULL,
	PRIMARY KEY (pk_idExpediente),
	FOREIGN KEY (fk_idPaciente) REFERENCES CITASCLINICA.PACIENTE(pk_idPaciente),
	FOREIGN KEY (fk_idEspecialista) REFERENCES CITASCLINICA.ESPECIALISTA(pk_idEspecialista)
	ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE CITASCLINICA.CITA (
	pk_idCita INT NOT NULL,
	fk_idPaciente INT NOT NULL,
	fk_idEspecialista INT NOT NULL,
	fecha DATE NOT NULL,
	hora TIME NOT NULL,
	turno VARCHAR(10) NOT NULL,
	status VARCHAR(20) NOT NULL,
	observaciones VARCHAR(100) NOT NULL,
	PRIMARY KEY (pk_idCita),
	FOREIGN KEY (fk_idPaciente) REFERENCES CITASCLINICA.PACIENTE(pk_idPaciente),
	FOREIGN KEY (fk_idEspecialista) REFERENCES CITASCLINICA.ESPECIALISTA(pk_idEspecialista)
	ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO CITASCLINICA.PACIENTE (
    pk_idPaciente,
    nombre,
    apellido,
    sexo,
    fechaNacimiento,
    ciudad,
    provincia,
    telefono,
    tipoSangre
)
SELECT
    gs AS pk_idPaciente,

    -- Nombre aleatorio
    (ARRAY['Juan','María','Pedro','Laura','Carlos','Ana','Jorge','Lucía','Pablo','Sofía',
           'Miguel','Elena','Raúl','Clara','Andrés','Marta','Víctor','Patricia','Diego','Carmen']
    )[floor(random()*20 + 1)] AS nombre,

    -- Apellido aleatorio
    (ARRAY['García','López','Martínez','Sánchez','Pérez','Gómez','Fernández','Díaz','Ruiz','Moreno',
           'Jiménez','Muñoz','Álvarez','Romero','Navarro','Torres','Domínguez','Vázquez','Ramos','Gil']
    )[floor(random()*20 + 1)] AS apellido,

    -- Sexo aleatorio ('M' o 'F')
    (ARRAY['M','F'])[floor(random()*2 + 1)] AS sexo,

    -- Fecha de nacimiento aleatoria entre 1920 y 2022
    date '1920-01-01' + (trunc(random() * 37500)) * interval '1 day' AS fechaNacimiento,

    -- Ciudad aleatoria
    (ARRAY['Madrid','Barcelona','Valencia','Sevilla','Zaragoza','Málaga','Murcia','Palma','Bilbao','Valladolid'])[floor(random()*10 + 1)] AS ciudad,

    -- Provincia (mismo índice que la ciudad)
    (ARRAY['Madrid','Barcelona','Valencia','Sevilla','Zaragoza','Málaga','Murcia','Islas Baleares','Bizkaia','Valladolid'])[floor(random()*10 + 1)] AS provincia,

    -- Teléfono único (formato 6XXXXXXXX)
    lpad((600000000 + random()*99999999)::text, 9, '0') AS telefono,

    (ARRAY['A+','A-','AB+','AB','B+','B-','0+','0-'])[floor(random()*8 + 1)] AS tipoSangre

FROM generate_series(0, 999999) AS gs;


INSERT INTO CITASCLINICA.ESPECIALISTA (
        pk_idEspecialista,
        nombre,
        apellido,
        sexo,
        fechaNacimiento,
        especialidad
)
SELECT
    gs AS pk_idEspecialista,

    (ARRAY['Juan','María','Pedro','Laura','Juan Carlos','Ana','Jorge','Lucía','Pablo','Sofía',
           'Javier','Elena','Raúl','Olvido','Andrés','Marta','Víctor','Patricia','Diego','Carmen']
    )[floor(random()*20 + 1)] AS nombre,

    (ARRAY['Sanchez','Salvador','Enrena','Cascos','Pérez','Gómez','Fernández','Díaz','Ruiz','Crancos',
           'Jiménez','Muñoz','Álvarez','Menendez','Valbuena','Torres','Domínguez','Vázquez','Ramos','Gil']
    )[floor(random()*20 + 1)] AS apellido,

    (ARRAY['M','F'])[floor(random()*2 + 1)] AS sexo,

    date '1958-01-01' + (trunc(random() * 18000)) * interval '1 day' AS fechaNacimiento,

    (ARRAY['Alergologia','Oncologia','Neurologia','Urologia','Medica Interna','Neurocirugia','Otorrinonaringologia','Traumatologia','Analisis Clinicos'])[floor(random()*8 + 1)] AS especialidad
FROM generate_series(0, 200) AS gs;



WITH ids AS (
  SELECT
    (SELECT array_agg(pk_idPaciente) FROM citasclinica.paciente) AS pacientes,
    (SELECT array_agg(pk_idEspecialista) FROM citasclinica.especialista) AS especialistas
)
INSERT INTO citasclinica.expediente (
  pk_idExpediente,
  fk_idPaciente,
  fk_idEspecialista,
  enfermedad,
  descripcion,
  fecha
)
SELECT
  gs AS pk_idExpediente,
  pacientes[(floor(random() * cardinality(pacientes))::int) + 1] AS fk_idPaciente,
  especialistas[(floor(random() * cardinality(especialistas))::int) + 1] AS fk_idEspecialista,
  (ARRAY['Cancer','Diabetes','Hipertension','Migrañas','Depresion'])[floor(random() * 5 + 1)] AS enfermedad,
  (ARRAY['NA','Consultar ficha','Consultar descripcion en papel'])[floor(random() * 3 + 1)] AS descripcion,
  date '2000-01-01' + (trunc(random() * 8700)::int) * INTERVAL '1 day' AS fecha
FROM generate_series(1,200000) AS gs
CROSS JOIN ids;


WITH ids AS (
  SELECT
    (SELECT array_agg(pk_idPaciente) FROM citasclinica.paciente) AS pacientes,
    (SELECT array_agg(pk_idEspecialista) FROM citasclinica.especialista) AS especialistas
)
INSERT INTO citasclinica.cita (
  pk_idCita,
  fk_idPaciente,
  fk_idEspecialista,
  fecha,
  hora,
  turno,
  status,
  observaciones
)
SELECT
  gs AS pk_idCita,
  (SELECT fk_idPaciente FROM citasclinica.expediente WHERE pk_idExpediente=gs) as fk_idPaciente,
  (SELECT fk_idEspecialista FROM citasclinica.expediente WHERE pk_idExpediente=gs) as fk_idEspecialista,
  date '2000-01-01' + (trunc(random() * 8700)) * interval '1 day' AS fecha,
  make_time( floor(random() * 24)::int, floor(random() * 60)::int, floor(random() * 60)::int) as hora,
  (ARRAY['Mañana','Tarde','Noche'])[floor(random()*3 + 1)] AS turno,
  (ARRAY['Pendiente Confirmar','Confirmado','Ausente','Concluida'])[floor(random()*4 + 1)] AS status,
  (ARRAY['NA','Faltan datos','NA','No contesta'])[floor(random()*3 + 1)] AS status
FROM generate_series(1,200000) AS gs
CROSS JOIN ids;
