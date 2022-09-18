# gcloud beta builds triggers create github \
#     --repo-name=sudonym \
#     --repo-owner=sudonym-btc \
#     --branch-pattern=main \
#     --build-config=/cloudbuild.yaml \
#     --require-approval

gcloud beta builds triggers create github \
    --repo-name=sudonym \
    --repo-owner=sudonym-btc \
    --branch-pattern=test \
    --build-config=/cloudbuild.yaml \
