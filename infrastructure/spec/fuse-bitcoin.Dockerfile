FROM ruimarinho/bitcoin-core:23.0
ENV GCSFUSE_REPO gcsfuse-stretch

RUN sed -i 's/bullseye\/updates/bullseye-security/g' /etc/apt/sources.list

RUN apt-get update && apt-get install --yes --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
  && echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" \
    | tee /etc/apt/sources.list.d/gcsfuse.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
  && apt-get update \
  && apt-get install --yes gcsfuse \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
# RUN apt-get update && \
#     apt-get install -y curl gnupg && \
#     echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
#     curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && \
#     apt-get update -y && \
#     apt-get install google-cloud-sdk -y 

# RUN apt install nodejs npm -y

# RUN (cd /home && npm init && npm install @google-cloud/storage && echo "" >> get.js )