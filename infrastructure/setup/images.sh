gcloud auth configure-docker

docker build -f infrastructure/spec/fuse-lightning.Dockerfile -t gcr.io/sudonym-lightning-test/fuse-lightning .
docker push gcr.io/sudonym-lightning-test/fuse-lightning

docker build -f infrastructure/spec/fuse-bitcoin.Dockerfile -t gcr.io/sudonym-lightning-test/fuse-bitcoin .
docker push gcr.io/sudonym-lightning-test/fuse-bitcoin
