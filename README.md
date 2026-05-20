## Репозиторій містить інфраструктурну конфігурацію для деплою мікросервісного застосунку в Google Kubernetes Engine (GKE).

Містить:
- Kubernetes manifests (Deployment, Service)
- kustomization.yml для керування конфігураціями 
- CI/CD деплой через GitHub Actions 
- Підключення секретів через GitHub Secrets / Kubernetes Secrets 
- Gateway як єдина точка входу до системи


### Деплой

Деплой відбувається автоматично через GitHub Actions при пуші в основну гілку.

Основні кроки pipeline:

1. Збірка Docker-образів

2. Публікація в container registry

3. Оновлення manifests

4. Деплой у GKE через kubectl apply / kustomize