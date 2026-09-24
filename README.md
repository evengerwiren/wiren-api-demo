# Wiren API Demo

Демонстрационный проект с ASP.NET Core Web API и React-клиентом для локальной разработки с использованием Docker Compose.

## Описание

Проект состоит из двух основных компонентов:

- **API** (ASP.NET Core .NET 8) - REST API с Swagger документацией
- **Client** (React + Vite + TypeScript) - веб-клиент для взаимодействия с API

## Требования

- Docker
- Docker Compose

## Быстрый старт

1. Клонируйте репозиторий:

```bash
git clone <repository-url>
cd <repository-name>
```

2. Создайте файл `.env` из примера:

```bash
cp .env.example .env
```

3. Запустите проект через Docker Compose:

**Linux / macOS:**
```bash
docker compose up --build
```

**Windows (PowerShell):**
```powershell
.\docker_run.ps1
```

Для запуска в фоновом режиме (Windows):
```powershell
.\docker_run.ps1 -Detached
```

4. Откройте в браузере:
   - **Клиент**: http://localhost:3000
   - **Swagger UI**: http://localhost:8080/swagger

## API Endpoints

API доступен по адресу `http://localhost:8080` и включает следующие методы:

### 1. Health Check (публичный)
```
GET /api/health
```
Возвращает статус работы API и текущее время UTC.

**Пример ответа:**
```json
{
  "status": "ok",
  "timeUtc": "2026-09-20T18:00:00.0000000Z"
}
```

### 2. Hello
```
GET /api/hello?name=Wiren
```
Возвращает персональное приветствие.

**Заголовки:**
- `X-Api-Key: dev-local-key-change-me` (обязательный)

**Пример ответа:**
```json
{
  "message": "Hello, Wiren!"
}
```

### 3. Echo
```
POST /api/echo
Content-Type: application/json
```
Возвращает отправленные данные обратно.

**Заголовки:**
- `X-Api-Key: dev-local-key-change-me` (обязательный)

**Тело запроса:**
```json
{
  "message": "Тестовое сообщение",
  "data": {
    "timestamp": "2026-09-20T18:00:00Z"
  }
}
```

**Пример ответа:**
```json
{
  "received": {
    "message": "Тестовое сообщение",
    "data": {
      "timestamp": "2026-09-20T18:00:00Z"
    }
  },
  "echoed": true,
  "timestamp": "2026-09-20T18:00:00.0000000Z"
}
```

## Аутентификация

Все endpoints кроме `/api/health` требуют заголовок `X-Api-Key` для авторизации.

**API ключ по умолчанию:** `dev-local-key-change-me`

Вы можете изменить ключ в файле `.env`:

```env
API_KEY=your-secure-key-here
```

## Структура проекта

```
.
├── docker-compose.yml          # Конфигурация Docker Compose
├── .env.example                # Пример переменных окружения
├── src/
│   ├── Api/                    # ASP.NET Core API
│   │   ├── Program.cs          # Точка входа и конфигурация
│   │   ├── Api.csproj          # Файл проекта .NET
│   │   └── Dockerfile          # Dockerfile для API
│   └── Client/                 # React клиент
│       ├── src/
│       │   ├── App.tsx         # Главный компонент
│       │   └── ...
│       ├── Dockerfile          # Dockerfile для клиента
│       ├── nginx.conf          # Конфигурация nginx
│       └── package.json        # Зависимости Node.js
└── README.md
```

## Локальная разработка без Docker

### API

```bash
cd src/Api
export API_KEY=dev-local-key-change-me
dotnet run
```

API будет доступен на http://localhost:5000

### Client

```bash
cd src/Client
cp .env.example .env
npm install
npm run dev
```

Клиент будет доступен на http://localhost:5173

## Технологии

- **Backend**: ASP.NET Core 8.0, Swagger/OpenAPI
- **Frontend**: React 18, TypeScript, Vite
- **Контейнеризация**: Docker, Docker Compose
- **Web Server**: nginx (для статики клиента)

## CORS

API настроен на разрешение запросов с `http://localhost:3000`. При необходимости измените настройки CORS в `src/Api/Program.cs`.

## Порты

- **API**: 8080
- **Client**: 3000

## Остановка

Для остановки контейнеров:

```bash
docker compose down
```

Для остановки и удаления volumes:

```bash
docker compose down -v
```

## Поддержка

При возникновении проблем:
1. Убедитесь, что порты 8080 и 3000 свободны
2. Проверьте логи: `docker compose logs`
3. Пересоберите образы: `docker compose build --no-cache`
