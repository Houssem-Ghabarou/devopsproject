import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [counter, setCounter] = useState(0);
  const [timestamp, setTimestamp] = useState(new Date().toLocaleString());

  useEffect(() => {
    const interval = setInterval(() => {
      setTimestamp(new Date().toLocaleString());
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  const handleIncrement = () => setCounter(counter + 1);
  const handleDecrement = () => setCounter(counter - 1);
  const handleReset = () => setCounter(0);

  return (
    <div className="App">
      <div className="container">
        <header className="header">
          <h1>🚀 DevOps Mini Project</h1>
          <p className="subtitle">React App with Kubernetes & CI/CD</p>
        </header>

        <div className="card">
          <h2>Counter Application</h2>
          <div className="counter-display">{counter}</div>
          <div className="button-group">
            <button className="btn btn-decrement" onClick={handleDecrement}>
              - Decrement
            </button>
            <button className="btn btn-reset" onClick={handleReset}>
              Reset
            </button>
            <button className="btn btn-increment" onClick={handleIncrement}>
              + Increment
            </button>
          </div>
        </div>

        <div className="info-grid">
          <div className="info-card">
            <h3>🐳 Docker</h3>
            <p>Containerized Application</p>
          </div>
          <div className="info-card">
            <h3>☸️ Kubernetes</h3>
            <p>Orchestration Platform</p>
          </div>
          <div className="info-card">
            <h3>🔄 CI/CD</h3>
            <p>Jenkins Pipeline</p>
          </div>
          <div className="info-card">
            <h3>📊 Monitoring</h3>
            <p>Prometheus & Grafana</p>
          </div>
        </div>

        <div className="footer">
          <p>Current Time: {timestamp}</p>
          <p>Environment: {process.env.NODE_ENV || 'development'}</p>
        </div>
      </div>
    </div>
  );
}

export default App;
