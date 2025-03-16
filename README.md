# LLM Deployment on Google Cloud Run

This project demonstrates how to deploy Large Language Models (LLMs), specifically `Gemma`, on **Google Cloud Platform (GCP)** using **Cloud Run**. It provides an optimized setup for **CPU-based inference**, ensuring cost efficiency.

---

## 📌 Features

- **Containerized LLM Deployment**: Uses `ollama/ollama` Docker image.
- **Automated Setup**: Includes scripts for project initialization, deployment, and cleanup.
- **Cloud Run & Cloud Build Integration**: Facilitates seamless image building and deployment.
- **Traefik Proxy Support**: Simplifies authentication and API management.

---

## 📁 Project Structure

- **`Dockerfile`** - Defines the container with the `ollama/ollama` image.
- **`cloudbuild.yaml`** - Automates container build & push using Cloud Build.
- **`bin/deploy.sh`** - Deploys the container to Cloud Run.
- **`bin/destroy.sh`** - Cleans up Cloud Run services & artifacts.
- **`scripts/setup_project.py`** - Automates GCP project setup.
- **`Makefile`** - Provides commands for build, deploy, and cleanup.
- **`test_inference.py`** - Tests the deployed LLM inference API.

---

## 🚀 Getting Started

### **1️⃣ Prerequisites**

Ensure you have:
- A **Google Cloud Project** with **billing enabled**.
- The **`gcloud` CLI** installed & configured.
- **Docker** installed (if building locally).

### **2️⃣ Clone the Repository**
```bash
git clone <repository_url>
cd gcp-llm-demo
```

### **3️⃣ Set Up the Project**
```bash
make setup
```
This will:
- Enable required GCP APIs.
- Create an **Artifact Registry** repository.

### **4️⃣ Build the Container**
```bash
make build
```
This process may take **30+ minutes** due to model downloads.

### **5️⃣ Deploy to Cloud Run**
```bash
make deploy
```
Deploys the container using the provided **deploy.sh** script.

---

## 🔥 Usage

### **Makefile Commands**
| Command           | Description |
|------------------|-------------|
| `make setup`    | Initializes GCP project |
| `make build`    | Builds & pushes container image |
| `make deploy`   | Deploys container to Cloud Run |
| `make describe` | Displays Cloud Run service details |
| `make destroy`  | 🚨 **Deletes all resources** |
| `make clean`    | Cleans up local temporary files |

### **Test Inference**
After deployment, verify the service:
```bash
python test_inference.py
```

---

## 🔧 Customization

### **Change the Model**
Modify the `MODEL` variable in the **Dockerfile**:
```Dockerfile
ENV MODEL codellama:7b
```

### **Adjust Cloud Run Configuration**
Edit **deploy.sh** to tweak CPU, memory, or concurrency settings.

### **Modify Deployment Region**
Update `REGION` in **Makefile** and **deploy.sh** as needed.

---

## 🧹 Cleanup
To avoid unnecessary GCP charges, delete all resources:
```bash
make destroy
```
🚨 **Warning:** This action is irreversible.

---

## 🔗 Traefik Proxy Support
This project integrates **Traefik Proxy** for easier API access.

### **When to Use**
- **✅ Traefik** → For production-like testing, handles authentication seamlessly.
- **⚠️ gcloud Proxy** → Suitable for quick tests, but may hit rate limits.

### **Setup**
Ensure Cloud Run is deployed:
```bash
make deploy
```
Then start the Traefik proxy:
```bash
./traefik-proxy/start-traefik.sh
```
### **Access Points**
- **Traefik Dashboard**: [http://localhost:8087](http://localhost:8087)
- **LLM API Endpoint**: [http://localhost:11434](http://localhost:11434)

---

## 💡 Additional Notes

- **Inference runs on CPU** – adjust resource allocation in `deploy.sh` as needed.
- **Model weights are included** in the container for faster startup.

---

## 📖 References

- [Google Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Google Cloud Build Documentation](https://cloud.google.com/cloud-build/docs)
- [Traefik Documentation](https://doc.traefik.io/traefik/)

---

**🚀 Happy Deploying!** 🎯

