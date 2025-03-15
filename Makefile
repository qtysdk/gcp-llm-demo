# GCP LLM Demo Project Makefile

# 變數定義
PROJECT_ID := $(shell gcloud config get-value project)
REGION := asia-southeast1
REPOSITORY := llm-models
SERVICE_NAME := ollama-gemma
IMAGE_NAME := $(REGION)-docker.pkg.dev/$(PROJECT_ID)/$(REPOSITORY)/ollama-gemma:latest

# 顏色定義
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: help setup build deploy describe destroy clean

# 預設目標：顯示幫助
help:
	@echo "$(GREEN)GCP LLM Demo Project 使用方法:$(NC)"
	@echo "  make setup     - 設定專案環境與啟用必要的 GCP API"
	@echo "  make build     - 建置容器映像"
	@echo "  make deploy    - 將容器部署到 Cloud Run (需要 GPU 配額)"
	@echo "  make describe  - 顯示已部署服務的詳細資訊"
	@echo "  make destroy   - 清除所有資源"
	@echo "  make clean     - 清除本地暫存檔案"
	@echo ""
	@echo "$(YELLOW)專案資訊:$(NC)"
	@echo "  專案 ID: $(PROJECT_ID)"
	@echo "  區域: $(REGION)"
	@echo "  容器映像: $(IMAGE_NAME)"

# 設定專案環境
setup:
	@echo "$(GREEN)正在設定專案環境...$(NC)"
	@python scripts/setup_project.py

# 建置容器映像
build:
	@echo "$(GREEN)正在建置容器映像...$(NC)"
	@echo "$(YELLOW)注意：此過程可能需要 30 分鐘以上$(NC)"
	@gcloud builds submit --config=cloudbuild.yaml

# 部署到 Cloud Run
deploy:
	@echo "$(GREEN)正在部署到 Cloud Run...$(NC)"
	@chmod +x bin/deploy.sh
	@bin/deploy.sh

# 顯示已部署服務的詳細資訊
describe:
	@echo "$(GREEN)服務詳細資訊:$(NC)"
	@gcloud run services describe $(SERVICE_NAME) --region $(REGION)

# 清除所有資源
destroy:
	@echo "$(RED)警告：將要清除所有資源!$(NC)"
	@chmod +x bin/destroy.sh
	@bin/destroy.sh

# 清除本地暫存檔案
clean:
	@echo "$(GREEN)正在清除本地暫存檔案...$(NC)"
	@find . -name "__pycache__" -type d -exec rm -rf {} +
	@find . -name "*.pyc" -delete
	@find . -name ".DS_Store" -delete
	@echo "$(GREEN)清除完成!$(NC)"