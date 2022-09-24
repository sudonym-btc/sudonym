gcloud auth configure-docker

docker build -f infrastructure/spec/fuse-lightning.Dockerfile -t gcr.io/$PROJECT_ID/fuse-lightning .
docker push gcr.io/$PROJECT_ID/fuse-lightning

docker build -f infrastructure/spec/fuse-bitcoin.Dockerfile -t gcr.io/$PROJECT_ID/fuse-bitcoin .
docker push gcr.io/$PROJECT_ID/fuse-bitcoin