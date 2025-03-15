#!/bin/bash

# 設定嚴格模式，任何錯誤發生時終止腳本
set -e

# 顯示顏色訊息函數
print_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_warning() {
    echo -e "\033[0;33m[WARNING]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

# 取得目前的專案 ID
PROJECT_ID=$(gcloud config get-value project)
REGION="asia-southeast1"
REPOSITORY="llm-models"
SERVICE_NAME="ollama-gemma"

print_info "開始清除在專案 '$PROJECT_ID' 中的資源..."

# 詢問確認
read -p "確定要刪除所有資源？此操作無法撤銷 (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "操作已取消"
    exit 0
fi

# 檢查並刪除 Cloud Run 服務
print_info "檢查 Cloud Run 服務 '$SERVICE_NAME'..."
if gcloud run services describe $SERVICE_NAME --region $REGION &> /dev/null; then
    print_info "刪除 Cloud Run 服務 '$SERVICE_NAME'..."
    gcloud run services delete $SERVICE_NAME --region $REGION --quiet
    print_success "Cloud Run 服務 '$SERVICE_NAME' 已刪除"
else
    print_warning "Cloud Run 服務 '$SERVICE_NAME' 不存在，跳過"
fi

# 檢查並刪除 Artifact Registry 中的映像
print_info "檢查 Artifact Registry 中的映像..."
REPO_PATH="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/ollama-gemma"

if gcloud artifacts repositories describe $REPOSITORY --location $REGION &> /dev/null; then
    # 檢查映像是否存在
    if gcloud artifacts docker images list $REPO_PATH --include-tags &> /dev/null; then
        print_info "刪除 Artifact Registry 中的容器映像..."
        
        # 列出所有標籤並刪除
        TAGS=$(gcloud artifacts docker tags list $REPO_PATH --format="value(tag)")
        for TAG in $TAGS; do
            print_info "刪除映像標籤: $REPO_PATH:$TAG"
            gcloud artifacts docker tags delete $REPO_PATH:$TAG --quiet
        done
        
        print_success "所有容器映像標籤已刪除"
    else
        print_warning "Artifact Registry 中沒有找到映像，跳過"
    fi

    # 最後刪除 Repository
    print_info "刪除 Artifact Registry repository '$REPOSITORY'..."
    gcloud artifacts repositories delete $REPOSITORY --location $REGION --quiet
    print_success "Artifact Registry repository '$REPOSITORY' 已刪除"
else
    print_warning "Artifact Registry repository '$REPOSITORY' 不存在，跳過"
fi

print_success "資源清除完成！"
print_info "注意: 此腳本不會停用已啟用的 API，因為它們可能被其他專案使用。"
print_info "如需停用 API，請使用 Google Cloud 控制台或 gcloud CLI 手動停用。"
