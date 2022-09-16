project=$(gcloud config get project)

gcloud auth configure-docker

docker build -f infrastructure/spec/fuse-lightning.Dockerfile -t gcr.io/$project/fuse-lightning .
docker push gcr.io/$project/fuse-lightning

docker build -f infrastructure/spec/fuse-bitcoin.Dockerfile -t gcr.io/$project/fuse-bitcoin .
docker push gcr.io/$project/fuse-bitcoin