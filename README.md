# Minato
A self-hosted, no-code Platform-as-a-Service (PaaS) and server management panel. Designed to turn any fresh Linux server (Ubuntu/Debian) into a fully managed cloud hosting environment.

## 🚀 Features

*   **System Monitoring:** Live dashboard for CPU, Memory (RAM), and Disk Storage usage.
*   **Docker Management:** View, start, stop, restart, and delete running Docker containers.
*   **App Marketplace (1-Click Installs):** Instantly deploy popular applications (WordPress, Redis, PostgreSQL, Node.js) with zero configuration.
*   **Domain & SSL Routing:** Automatically map domains to your containers. Uses an embedded Caddy server to automatically negotiate Let's Encrypt SSL certificates.
*   **Visual Firewall:** A UI wrapper around Linux `ufw` (Uncomplicated Firewall) to easily open and close TCP/UDP ports.

## 🛠️ Architecture

*   **Backend:** Go (Golang) + Fiber. Communicates directly with the host machine via `gopsutil`, the Docker SDK, and the Caddy API.
*   **Frontend:** React 18 + Vite + TypeScript + Tailwind CSS v4.
*   **Reverse Proxy:** Caddy.

---
## Installation 

* Download this install.sh and run. It will install all the dependencies and minato on you main server. Later you can add muliple server as worker service.

## Note: Development in progress.
