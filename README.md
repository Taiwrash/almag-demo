# Almag
Welcome to the **Almag** demonstration repository. 
> Almag is the safety rail for AI-accelerated development, providing an intelligent, enforceable release gate for security findings.
---

## Demo video

<a href="https://youtu.be/sFr7Uynu8GY?si=2WNQlLERJ_7s8V9E&t=12" target="_blank" rel="noopener noreferrer">
  <img
    width="1369"
    height="781"
    alt="Screenshot 2026-01-19 at 13 51 23"
    src="https://github.com/user-attachments/assets/c414e3c6-0f69-4c7e-be01-f32d5e787f9c"
  />
</a>

## Project Brief
[Brief](brief.md)

## 🚀 Quick Start (One-Click)

The easiest way to run the Almag demo is using our automation script. This script will check your system requirements and launch the application on an available port.

```bash
curl -sSL https://raw.githubusercontent.com/taiwrash/almag-demo/main/run-demo.sh | bash
```

---

## 🛠 Manual Setup

If you prefer to run it manually using Docker Compose:

### 1. Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running.
- clone this repository

### 2. Launch the Application
Run the following command in this directory:

```bash
cd demo && docker compose up -d
```

### 3. Access Almag
- **Frontend Dashboard**: [http://localhost](http://localhost) (or port 80)
- **Backend API**: [http://localhost:8080](http://localhost:8080)

---

## 🧪 Testing the Platform

Once the platform is running, you can explore the following features:

1. **Dashboard**: Premium dark-mode UI showing security posture.
2. **Release Gating**: Observe how deployment status changes based on active blocks.
3. **Multi-tenancy**: Create an account and manage your own organization's findings.
4. **CI/CD Integration**: See the documentation for using the Almag GitHub Action.

## 📦 Architecture Highlights

- **Backend**: High-performance Go (Golang) microservice.
- **Frontend**: Modern React + Vite + Tailwind CSS.
- **Reverse Proxy**: Nginx optimized for SPA routing.
- **Containerization**: Fully orchestrated using Docker Hub hosted images.

---

## 📬 Contact & Code Access

If you are an organizer or technical judge and would like to review the Go/React source code, please reach out via:
- **Portfolio**: [https://taiwrash.xyz](taiwrash.xyz)
- **Contact Email**: dev@taiwrash.xyz
We are happy to provide temporary access to our private repositories for evaluation purposes.
