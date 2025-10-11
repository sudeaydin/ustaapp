#!/bin/bash

echo ""
echo "========================================"
echo "  ustam - HIZLI DEPLOYMENT"
echo "  Project: ustaapp-analytics"
echo "========================================"
echo ""

echo "[1/7] Google Cloud CLI kontrolu..."
if ! command -v gcloud &> /dev/null; then
    echo "Google Cloud CLI bulunamadi!"
    echo "Lutfen su adimları takip edin:"
    echo "1. https://cloud.google.com/sdk/docs/install adresinden gcloud CLI indirin"
    echo "2. Kurulum sonrasi: gcloud auth login"
    echo "3. Bu scripti tekrar calistirin"
    exit 1
fi

echo "[2/7] Proje ayarlaniyor..."
gcloud config set project ustaapp-analytics

echo "[3/7] Gerekli API'lar aktifleştiriliyor..."
gcloud services enable appengine.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable cloudbuild.googleapis.com

echo "[4/7] Python dependencies kuruluyor..."
cd backend
pip install -r requirements.txt

echo "[5/7] BigQuery analytics kuruluyor..."
python production_analytics_setup.py ustaapp-analytics --environment production

echo "[6/7] Veritabani hazirlaniyor..."
python create_db_with_data.py

echo "[7/7] App Engine'e deploy ediliyor..."
gcloud app deploy --quiet

echo ""
echo "========================================"
echo "  DEPLOYMENT TAMAMLANDI!"
echo "========================================"
echo ""
echo "Uygulamaniz artik canli:"
echo "https://ustaapp-analytics.appspot.com"
echo ""
echo "Analytics Dashboard:"
echo "https://console.cloud.google.com/bigquery?project=ustaapp-analytics"
echo ""
echo "Sonraki adimlar:"
echo "1. Uygulamayi test edin: https://ustaapp-analytics.appspot.com/api/health"
echo "2. Mobile app URL'lerini guncelleyin"
echo "3. Analytics dashboard'u baslatın"
echo ""