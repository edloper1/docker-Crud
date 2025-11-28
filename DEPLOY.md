# 🚀 Guía de Deploy - API REST CRUD

Guía completa para desplegar el proyecto en diferentes entornos: local, Render, Railway y otros servicios en la nube.

---

## 📋 Tabla de Contenidos

1. [Deploy Local con Docker](#deploy-local-con-docker)
2. [Deploy en Render](#deploy-en-render)
3. [Deploy en Railway](#deploy-en-railway)
4. [Deploy en otros servicios](#deploy-en-otros-servicios)
5. [Configuración de Variables de Entorno](#configuración-de-variables-de-entorno)
6. [Troubleshooting](#troubleshooting)

---

## 🐳 Deploy Local con Docker

### Requisitos Previos

- Docker instalado ([Instalar Docker](https://docs.docker.com/get-docker/))
- Docker Compose instalado (viene con Docker Desktop)

### Pasos

1. **Clonar el repositorio** (si no lo tienes localmente):
```bash
git clone https://github.com/TU_USUARIO/docker-Crud.git
cd docker-Crud
```

2. **Construir y levantar los servicios**:
```bash
docker-compose up --build
```

3. **Verificar que todo funciona**:
```bash
# En otra terminal, probar el endpoint
curl http://localhost/api/users
```

4. **Detener los servicios**:
```bash
docker-compose down
```

### Estructura de Servicios Locales

| Servicio | Puerto | URL |
|----------|--------|-----|
| nginx-gateway | 80 | http://localhost |
| api-service | 3000 | http://localhost:3000 |
| postgres-db | 5432 | localhost:5432 |

### Variables de Entorno Locales

Las variables están configuradas en `docker-compose.yml`:
- `DB_HOST=postgres-db`
- `DB_PORT=5432`
- `DB_NAME=crud_db`
- `DB_USER=postgres`
- `DB_PASSWORD=postgres`

---

## ☁️ Deploy en Render

Render es ideal para este proyecto porque ofrece servicios PostgreSQL gestionados y despliegue de aplicaciones web.

### Opción 1: Deploy Completo (API + PostgreSQL + Nginx Gateway)

#### Paso 1: Crear Base de Datos PostgreSQL

1. Ve a [Render Dashboard](https://dashboard.render.com/)
2. Click en **"New +"** → **"PostgreSQL"**
3. Configuración:
   - **Name**: `crud-db` (o el nombre que prefieras)
   - **Database**: `crud_db`
   - **User**: Se genera automáticamente
   - **Region**: Elige la más cercana
   - **PostgreSQL Version**: 15
   - **Plan**: Free (o el plan que prefieras)
4. Click en **"Create Database"**
5. **IMPORTANTE**: Copia la **Internal Database URL** (para uso dentro de Render) y la **External Database URL** (para uso externo)

#### Paso 2: Deploy del API Service

1. En Render Dashboard, click en **"New +"** → **"Web Service"**
2. Conecta tu repositorio de GitHub
3. Configuración:
   - **Name**: `api-service-crud` (o el nombre que prefieras)
   - **Environment**: `Node`
   - **Build Command**: `cd api-service && npm install`
   - **Start Command**: `cd api-service && node server.js`
   - **Root Directory**: Dejar vacío (o `./` si es necesario)
4. **Variables de Entorno**:
   - `PORT`: `3000`
   - `DATABASE_URL`: Pega la **Internal Database URL** del paso anterior
5. Click en **"Create Web Service"**

#### Paso 3: Deploy del Nginx Gateway (Opcional)

Si quieres mantener el gateway Nginx:

1. **New +** → **"Web Service"**
2. Conecta el mismo repositorio
3. Configuración:
   - **Name**: `nginx-gateway-crud`
   - **Environment**: `Docker`
   - **Dockerfile Path**: `nginx/Dockerfile`
   - **Docker Context**: `.`
4. **Variables de Entorno**:
   - `API_SERVICE_URL`: `https://api-service-crud.onrender.com` (URL de tu API service)
5. **IMPORTANTE**: Modifica `nginx/nginx.conf` para usar la variable de entorno o actualiza manualmente con la URL de tu API service

### Opción 2: Deploy Simplificado (Solo API + PostgreSQL)

Si no necesitas el gateway Nginx, puedes desplegar solo el API service:

1. Sigue los pasos 1 y 2 de la Opción 1
2. Accede directamente a: `https://api-service-crud.onrender.com/api/users`

### Verificación Post-Deploy

```bash
# Probar el endpoint
curl https://api-service-crud.onrender.com/api/users

# Crear un usuario
curl -X POST https://api-service-crud.onrender.com/api/users \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Test","correo":"test@example.com"}'
```

### Notas Importantes para Render

- **Cold Start**: Los servicios gratuitos se "duermen" después de 15 minutos de inactividad. El primer request puede tardar ~30 segundos.
- **Health Checks**: Render verifica automáticamente el endpoint `/health`
- **Logs**: Puedes ver los logs en tiempo real desde el Dashboard de Render
- **Auto-Deploy**: Cada push a la rama principal despliega automáticamente

---

## 🚂 Deploy en Railway

Railway ofrece una experiencia similar a Render con PostgreSQL gestionado.

### Paso 1: Crear Proyecto

1. Ve a [Railway](https://railway.app/)
2. Click en **"New Project"**
3. Selecciona **"Deploy from GitHub repo"**
4. Conecta tu repositorio

### Paso 2: Agregar Base de Datos PostgreSQL

1. En tu proyecto, click en **"+ New"**
2. Selecciona **"Database"** → **"Add PostgreSQL"**
3. Railway creará automáticamente la base de datos y la variable `DATABASE_URL`

### Paso 3: Configurar API Service

1. Click en **"+ New"** → **"GitHub Repo"** (o usa el servicio que ya creaste)
2. Selecciona tu repositorio
3. Railway detectará automáticamente que es un proyecto Node.js
4. **Configuración**:
   - **Root Directory**: `api-service`
   - **Build Command**: `npm install`
   - **Start Command**: `node server.js`
5. **Variables de Entorno**:
   - Railway ya tiene `DATABASE_URL` disponible automáticamente
   - `PORT`: Railway lo asigna automáticamente (usa `process.env.PORT`)

### Paso 4: Configurar Dominio (Opcional)

1. En el servicio del API, ve a **"Settings"**
2. Click en **"Generate Domain"** para obtener una URL pública
3. O conecta tu propio dominio personalizado

### Verificación

```bash
# Reemplaza con tu URL de Railway
curl https://TU-PROYECTO.up.railway.app/api/users
```

---

## 🌐 Deploy en Otros Servicios

### Heroku

1. **Instalar Heroku CLI**: [Instalar Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)

2. **Login y crear app**:
```bash
heroku login
heroku create tu-app-name
```

3. **Agregar PostgreSQL**:
```bash
heroku addons:create heroku-postgresql:mini
```

4. **Configurar variables**:
```bash
heroku config:set NODE_ENV=production
# DATABASE_URL se configura automáticamente
```

5. **Deploy**:
```bash
git push heroku main
```

6. **Configurar el servicio**:
```bash
# Crear un Procfile en api-service/
echo "web: node server.js" > api-service/Procfile
```

### DigitalOcean App Platform

1. Ve a [DigitalOcean](https://cloud.digitalocean.com/)
2. **Apps** → **Create App**
3. Conecta tu repositorio de GitHub
4. **Add Component** → **Database** → **PostgreSQL**
5. **Add Component** → **Web Service**:
   - **Source Directory**: `api-service`
   - **Build Command**: `npm install`
   - **Run Command**: `node server.js`
6. Configura `DATABASE_URL` desde la base de datos creada

### AWS (EC2 + RDS)

1. **Crear instancia EC2** (Ubuntu)
2. **Instalar Docker y Docker Compose**:
```bash
sudo apt update
sudo apt install docker.io docker-compose -y
sudo usermod -aG docker $USER
```

3. **Clonar repositorio en EC2**:
```bash
git clone https://github.com/TU_USUARIO/docker-Crud.git
cd docker-Crud
```

4. **Crear RDS PostgreSQL** (o usar PostgreSQL en EC2)
5. **Configurar variables de entorno** en `docker-compose.yml` o archivo `.env`
6. **Levantar servicios**:
```bash
docker-compose up -d
```

7. **Configurar Security Groups** para permitir tráfico en puertos 80 y 3000

---

## 🔐 Configuración de Variables de Entorno

### Variables Requeridas

| Variable | Descripción | Ejemplo Local | Ejemplo Producción |
|----------|-------------|---------------|-------------------|
| `PORT` | Puerto del API service | `3000` | Asignado por el servicio |
| `DATABASE_URL` | URL completa de PostgreSQL (prioridad) | - | `postgresql://user:pass@host:5432/db?sslmode=require` |
| `DB_HOST` | Host de PostgreSQL (si no hay DATABASE_URL) | `postgres-db` | `db.example.com` |
| `DB_PORT` | Puerto de PostgreSQL | `5432` | `5432` |
| `DB_NAME` | Nombre de la base de datos | `crud_db` | `crud_db` |
| `DB_USER` | Usuario de PostgreSQL | `postgres` | `admin` |
| `DB_PASSWORD` | Contraseña de PostgreSQL | `postgres` | `password_segura` |

### Prioridad de Configuración

El código usa esta prioridad:
1. **`DATABASE_URL`** (si existe, se usa con SSL)
2. **Variables individuales** (`DB_HOST`, `DB_PORT`, etc.)
3. **Valores por defecto** (solo para desarrollo local)

### Archivo .env (Solo para desarrollo local)

Crea un archivo `.env` en `api-service/` (NO lo subas a Git):

```env
PORT=3000
DB_HOST=postgres-db
DB_PORT=5432
DB_NAME=crud_db
DB_USER=postgres
DB_PASSWORD=postgres
```

O para producción con DATABASE_URL:

```env
PORT=3000
DATABASE_URL=postgresql://user:password@host:5432/dbname?sslmode=require
```

---

## 🔧 Troubleshooting

### Problema: "No se pudo conectar a la base de datos"

**Solución**:
- Verifica que las variables de entorno estén configuradas correctamente
- Asegúrate de que la base de datos esté corriendo
- En servicios cloud, verifica que uses la URL interna (Internal Database URL) si el API está en el mismo servicio
- Revisa los logs del servicio: `docker-compose logs api-service`

### Problema: "Connection timeout" en Render

**Solución**:
- Render tiene cold starts. El primer request después de 15 minutos puede tardar ~30 segundos
- Verifica que estés usando la **Internal Database URL** (no la External) si ambos servicios están en Render
- Aumenta los timeouts en la configuración de Nginx si usas gateway

### Problema: "Table does not exist"

**Solución**:
- El código crea la tabla automáticamente al iniciar
- Verifica los logs para ver si hay errores en la creación de la tabla
- Si la tabla no se crea, ejecuta manualmente:
```sql
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  nombre TEXT,
  correo TEXT
);
```

### Problema: CORS errors en el navegador

**Solución**:
- El código ya incluye `cors()`, pero si persiste:
- Verifica que el frontend esté haciendo requests a la URL correcta
- En producción, configura CORS específicamente:
```javascript
app.use(cors({
  origin: 'https://tu-frontend.com',
  credentials: true
}));
```

### Problema: Docker build falla

**Solución**:
```bash
# Limpiar caché de Docker
docker-compose down -v
docker system prune -a

# Reconstruir sin caché
docker-compose build --no-cache
docker-compose up
```

### Problema: Puerto ya en uso

**Solución**:
```bash
# Encontrar proceso usando el puerto 80
sudo lsof -i :80

# Matar el proceso o cambiar el puerto en docker-compose.yml
# Cambia '80:80' a '8080:80' por ejemplo
```

### Verificar Estado de Servicios

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f api-service

# Verificar estado de contenedores
docker-compose ps

# Health check del API
curl http://localhost/api/users
curl http://localhost:3000/health
```

---

## 📊 Checklist de Deploy

### Pre-Deploy
- [ ] Código subido a GitHub
- [ ] `.gitignore` configurado correctamente
- [ ] No hay credenciales hardcodeadas en el código
- [ ] README.md actualizado

### Deploy Local
- [ ] Docker y Docker Compose instalados
- [ ] `docker-compose up --build` ejecuta sin errores
- [ ] Endpoints responden correctamente
- [ ] Base de datos se crea automáticamente

### Deploy en Producción
- [ ] Base de datos PostgreSQL creada
- [ ] Variables de entorno configuradas
- [ ] API service desplegado y funcionando
- [ ] Health checks pasando (`/health`)
- [ ] Endpoints probados con curl o Postman
- [ ] Logs revisados para errores
- [ ] Dominio/URL pública configurada (si aplica)

---

## 🔗 Enlaces Útiles

- [Documentación de Docker](https://docs.docker.com/)
- [Documentación de Render](https://render.com/docs)
- [Documentación de Railway](https://docs.railway.app/)
- [Documentación de PostgreSQL](https://www.postgresql.org/docs/)
- [Documentación de Express](https://expressjs.com/)

---

## 📝 Notas Adicionales

- **Seguridad**: Nunca subas archivos `.env` con credenciales a Git
- **SSL/TLS**: En producción, siempre usa HTTPS
- **Backups**: Configura backups automáticos de la base de datos en producción
- **Monitoreo**: Considera agregar herramientas de monitoreo (Sentry, LogRocket, etc.)
- **Rate Limiting**: Para producción, considera agregar rate limiting al API

---

**¿Problemas?** Revisa los logs del servicio y la sección de Troubleshooting. Si el problema persiste, abre un issue en el repositorio.

