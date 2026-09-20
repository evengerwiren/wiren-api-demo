import { useState } from 'react'
import './App.css'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080'
const API_KEY = import.meta.env.VITE_API_KEY || 'dev-local-key-change-me'

interface ApiResponse {
  [key: string]: any
}

function App() {
  const [healthData, setHealthData] = useState<ApiResponse | null>(null)
  const [helloName, setHelloName] = useState('Wiren')
  const [helloData, setHelloData] = useState<ApiResponse | null>(null)
  const [echoMessage, setEchoMessage] = useState('Hello from client!')
  const [echoData, setEchoData] = useState<ApiResponse | null>(null)
  const [loading, setLoading] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  const callApi = async (endpoint: string, options: RequestInit = {}) => {
    try {
      setError(null)
      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
      }
      
      if (!endpoint.includes('/health')) {
        headers['X-Api-Key'] = API_KEY
      }

      const response = await fetch(`${API_BASE_URL}${endpoint}`, {
        ...options,
        headers: {
          ...headers,
          ...options.headers,
        },
      })

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`)
      }

      return await response.json()
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Unknown error'
      setError(message)
      throw err
    }
  }

  const checkHealth = async () => {
    setLoading('health')
    try {
      const data = await callApi('/api/health')
      setHealthData(data)
    } finally {
      setLoading(null)
    }
  }

  const sayHello = async () => {
    setLoading('hello')
    try {
      const data = await callApi(`/api/hello?name=${encodeURIComponent(helloName)}`)
      setHelloData(data)
    } finally {
      setLoading(null)
    }
  }

  const echoMessage_fn = async () => {
    setLoading('echo')
    try {
      const data = await callApi('/api/echo', {
        method: 'POST',
        body: JSON.stringify({
          message: echoMessage,
          data: { timestamp: new Date().toISOString() }
        }),
      })
      setEchoData(data)
    } finally {
      setLoading(null)
    }
  }

  return (
    <div className="app">
      <header>
        <h1>Wiren API Demo</h1>
        <p>Демонстрация работы с ASP.NET Core API</p>
      </header>

      {error && (
        <div className="error-banner">
          <strong>Ошибка:</strong> {error}
        </div>
      )}

      <div className="api-sections">
        <section className="api-card">
          <h2>Health Check</h2>
          <p>Проверка состояния API (без авторизации)</p>
          <button onClick={checkHealth} disabled={loading === 'health'}>
            {loading === 'health' ? 'Загрузка...' : 'Проверить'}
          </button>
          {healthData && (
            <pre className="response">{JSON.stringify(healthData, null, 2)}</pre>
          )}
        </section>

        <section className="api-card">
          <h2>Hello Endpoint</h2>
          <p>Персональное приветствие</p>
          <input
            type="text"
            value={helloName}
            onChange={(e) => setHelloName(e.target.value)}
            placeholder="Введите имя"
          />
          <button onClick={sayHello} disabled={loading === 'hello'}>
            {loading === 'hello' ? 'Загрузка...' : 'Отправить'}
          </button>
          {helloData && (
            <pre className="response">{JSON.stringify(helloData, null, 2)}</pre>
          )}
        </section>

        <section className="api-card">
          <h2>Echo Endpoint</h2>
          <p>Эхо-запрос с JSON payload</p>
          <input
            type="text"
            value={echoMessage}
            onChange={(e) => setEchoMessage(e.target.value)}
            placeholder="Введите сообщение"
          />
          <button onClick={echoMessage_fn} disabled={loading === 'echo'}>
            {loading === 'echo' ? 'Загрузка...' : 'Отправить'}
          </button>
          {echoData && (
            <pre className="response">{JSON.stringify(echoData, null, 2)}</pre>
          )}
        </section>
      </div>

      <footer>
        <p>
          API Base URL: <code>{API_BASE_URL}</code>
        </p>
        <p>
          Swagger: <a href={`${API_BASE_URL}/swagger`} target="_blank" rel="noopener noreferrer">
            {API_BASE_URL}/swagger
          </a>
        </p>
      </footer>
    </div>
  )
}

export default App
