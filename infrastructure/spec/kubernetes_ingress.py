from helper import getDeploymentName, getServiceName, getVolumeClaimName
from kubernetes_cluster import cluster
from kubernetes_lightning_rest import lightning_rest

from kubernetes_db import db
from kubernetes_ride_the_lightning import ride_the_lightning
from kubernetes_lightning_rest import lightning_rest
from kubernetes_cluster import cluster
from kubernetes_bitcoin import bitcoin
from kubernetes_lightning_rest import lightning_rest
from kubernetes_api import api


def ingress(config, cluster_types):
    kube_type_name = cluster(config)["kube_type_name"]
    base_name = config["env"] + "-ingress"

    ride_the_lightning_base_name = ride_the_lightning(config, cluster_types)[
        "base_name"
    ]
    lightning_rest_base_name = lightning_rest(config, cluster_types)["base_name"]
    api_base_name = api(config, cluster_types)["base_name"]
    bitcoin_base_name = bitcoin(config, cluster_types)["base_name"]
    db_base_name = db(config, cluster_types)["base_name"]

    return {
        "resources": [
            {
                "name": config["env"] + "-tls",
                "type": cluster_types["Secret"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "Secret",
                    "namespace": "default",
                    "metadata": {"name": config["env"] + "-tls"},
                    "type": "kubernetes.io/tls",
                    "data": {
                        "tls.crt": """LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUYxekNDQTcrZ0F3SUJBZ0lVVlpyUklUUUxqb2lLZFRkVGdvUGNXQTROQ1hZd0RRWUpLb1pJaHZjTkFRRUwKQlFBd2V6RUxNQWtHQTFVRUJoTUNSMEl4RHpBTkJnTlZCQWdNQmt4dmJtUnZiakVQTUEwR0ExVUVCd3dHVEc5dQpaRzl1TVJBd0RnWURWUVFLREFkemRXUnZibmx0TVJRd0VnWURWUVFEREF0emRXUnZlVzV0TG1Gd2NERWlNQ0FHCkNTcUdTSWIzRFFFSkFSWVRjR0YwY21samEwQnpkV1J2Ym5sdExtRndjREFlRncweU1qQTVNakl4TXpNMU1EUmEKRncweU16QTVNakl4TXpNMU1EUmFNSHN4Q3pBSkJnTlZCQVlUQWtkQ01ROHdEUVlEVlFRSURBWk1iMjVrYjI0eApEekFOQmdOVkJBY01Ca3h2Ym1SdmJqRVFNQTRHQTFVRUNnd0hjM1ZrYjI1NWJURVVNQklHQTFVRUF3d0xjM1ZrCmIzbHViUzVoY0hBeElqQWdCZ2txaGtpRzl3MEJDUUVXRTNCaGRISnBZMnRBYzNWa2IyNTViUzVoY0hBd2dnSWkKTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElDRHdBd2dnSUtBb0lDQVFDL01TM1QwQm02NWdMN3cyZTNhL1l6cU94cQpQZERDalNmK3hscUdjeGZuSUd6ZFlacDlWZFRxQThqSk5WTlF4Y0JlODRRQytoajFBTVo3UTZqNmFqRW5wZGxkClc2K2lPdjJyRjh2dWRyckRLaU5UQXdnTG1GSXc4RFU0V0hFQXJHRkJUd1hVM3ZqcDRMSjdwbUNNaVdISjdPdkQKVFBGdWpNYmdXWUx0YlFGemkzUVBnVm1tL3BDVDF5N011d0pNQ1RSb2VzSDlBTkMyQ0NKQVhxUTF1WEs3YnJUYwpzL3MrK1Zadmg5VkhDbmFkUWpUcmRnWHdGQ0tvTEM1R2N0WkI0VDF1V21FR0kvWHlKYWRlUUYwQmVIalpXMlJ6CmpMTUh0YmorenJ5akhnQ1VGeXNKTnNxTXpacWYwb1ZLT0F3eGdUekc2aW9IY3ByKzlKT0l2cnUwc3RmaDdsa2UKalBDbFVSZkZlSmVzUTBXL1dpZjgzVVNMeFk3ZzdZSm5RcjBRbFdUTmFhcm5BbmFDaTNnMCtEUld2UjJVYXBycApaQVpGci9WdnR2N3FvbnkzTmlKMjQrRFlIWGxVQXE5K1FnV2pJSVN1VG9sT1h2eG9KZU40d2tYZDI5bWZkQ0FKCmV0a0xIUVhzUWpKRkREc3lrS2VKQTJrWkZtUnkwMVV2UzlWa0dvRE1QOW9rdkxwdzd3eHFDQWc2Sk9jWU8yWXUKT0RReFNLbnZsTjVlODFUcjVvYlYxTWxWQUh3dFp1OUhYRzdlQldQaUdkVFpZRkhNNGd5YkVOUUJDV3FBSG8wSAp0VzZPWDltbkZoNmc3RFpxejZoc3FGTjEzN0VZZ3R5cWtYWGdTZmsyZGVIejNnN2o5WmtwcDJ4SGJHT1ZDVldsCk9zSnZBMlAycVd3WStnVTI4d0lEQVFBQm8xTXdVVEFkQmdOVkhRNEVGZ1FVOGtCRXhzMEFzZ0krQWd2ZU9lSTAKL0d5djJyUXdId1lEVlIwakJCZ3dGb0FVOGtCRXhzMEFzZ0krQWd2ZU9lSTAvR3l2MnJRd0R3WURWUjBUQVFILwpCQVV3QXdFQi96QU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FnRUFqZmovWFZjSXpJNHJSZHd4UzI5RlhhSy9mYkpICnlpK3hHYkJuenZtRXF1cE9FdDBCVnYwMnZJVmN4d0dleFd3Z3U1TmYrTHBaY1crR0t5MHU2K0dMc2pod3NFRGIKQmUwVkQ4bVpnR2pNVG9nTEx0dHhCSnB4VnJyWDBjRy93RGpOVlRHd1pMVTlFcC9Ia0t5S3kwUFpscTUwSE13MQpFUkI5bXNwajc5WTdVcmREU2NyaTVLR1BFZmY5d2MzTTg2Ym9KTHl3NWllZFJmMHhVVGNzZis3S0hRNjBRbXBuCm1RcllEM1NIT0Q3TnJoOGZ3QzlhS2tkTTRiNG5UNDl6Njd6WExDZ2syNmJaSWNMNnFxS3hlbWZqZnA3YmY0aWkKaXh6Y282UnVvV0pNNjN3WndscEtUbGh3MFRvNXdJOGxzd0kwWCtaaGFYY3Zpb0w3Vms3OHcrUGFkWHlzVjBhMwoycGZIbzZ2TE1VQVRVMEF3REErMGw0NEk5YitPTFloSXNScXN2RmF5MzJ0Zm0zY2g2Zzhac2o0QWZQV2JNS2pVCnhuSUN5ZktjdEFGb1RpMitySjBrN0RYMFNKSkx4ejl0OXMrVzJIRW1vSFp6VEdSUE1XRElCUmFZNTFQaXFyLzkKNENRM2pTTmp2Q09IckZzOFFaZ2luY1ArRXBFM3Y2TU9kQkNHQ2tYTVUrb3RCOVcvS1Z3V1JTSFZWVWJiRmFjWgoxdWw0UkhJN293c1BCSUdXNkd5S2l3ajNHb1lLZUcyOFA0dXZRLzU2MkE2UmNIdktoNzFmSlFZTG44R1JuSHJ3ClNUU2xNc1FvOEZ4cHM0SmlzdDhheVpoMFZ3YjRkS2ticjltZld0ZGZjcWpyUmNmSnZNNm16SzdkcmppV0syYkcKN0grbW5ubTgrbDZJWERNPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==""",
                        \"tls.key\": \"\"\"REDACTED\"\"\"
                    },
                },
            },
            {
                "name": config["env"] + "-ingress",
                "type": cluster_types["Ingress"],
                "metadata": {"dependsOn": [kube_type_name, config["env"] + "-tls", config["env"] + "-ip"]},
                "properties": {
                    "apiVersion": "networking.k8s.io/v1",
                    "kind": "Ingress",
                    "namespace": "default",
                    "metadata": {
                        "name": config["env"] + "-ingress",
                        "annotations": {
                            # "kubernetes.io/ingress.class": "nginx",
                            #                             "nginx.org/websocket-services": api_base_name + "-service",
                            #                             "nginx.ingress.kubernetes.io/proxy-read-timeout": "3600",
                            #                             "nginx.ingress.kubernetes.io/proxy-send-timeout": "3600",
                            #                             "nginx.ingress.kubernetes.io/configuration-snippet": """
                            #    proxy_http_version 1.1;
                            #    proxy_set_header Upgrade "websocket";
                            #    proxy_set_header Connection "Upgrade";""",
                            "kubernetes.io/ingress.global-static-ip-name": config["env"]
                            + "-ip",
                        },
                    },
                    "spec": {
                        "defaultBackend": {
                            "service": {
                                "name": getServiceName(ride_the_lightning_base_name),
                                "port": {"number": config["rtl"]["port"]},
                            }
                        },
                        "tls": [
                            {
                                "hosts": [
                                    config["domain"],
                                    "api." + config["domain"],
                                    "rtl." + config["domain"],
                                    "lightning-rest." + config["domain"],
                                    # "bitcoin-mq." + config["domain"],
                                ],
                                "secretName": config["env"] + "-tls",
                            }
                        ],
                        "rules": [
                            {
                                "host": "rtl." + config["domain"],
                                "http": {
                                    "paths": [
                                        {
                                            "path": "/",
                                            "pathType": "Prefix",
                                            "backend": {
                                                "service": {
                                                    "name": getServiceName(
                                                        ride_the_lightning_base_name
                                                    ),
                                                    "port": {
                                                        "number": config["rtl"]["port"]
                                                    },
                                                }
                                            },
                                        }
                                    ]
                                },
                            },
                            {
                                "host": "bitcoin-mq." + config["domain"],
                                "http": {
                                    "paths": [
                                        {
                                            "path": "/",
                                            "pathType": "Prefix",
                                            "backend": {
                                                "service": {
                                                    "name": getServiceName(
                                                        bitcoin_base_name + "-zeromq"
                                                    ),
                                                    "port": {"number": 5555},
                                                }
                                            },
                                        }
                                    ]
                                },
                            },
                            {
                                "host": "lightning-rest." + config["domain"],
                                "http": {
                                    "paths": [
                                        {
                                            "path": "/",
                                            "pathType": "Prefix",
                                            "backend": {
                                                "service": {
                                                    "name": getServiceName(
                                                        lightning_rest_base_name
                                                    ),
                                                    "port": {
                                                        "number": config[
                                                            "lightningRest"
                                                        ]["port"]
                                                    },
                                                }
                                            },
                                        }
                                    ]
                                },
                            },
                            # Forward .well-known on base domain to API
                            {
                                "host": config["domain"],
                                "http": {
                                    "paths": [
                                        {
                                            "path": "/.well-known",
                                            "pathType": "Prefix",
                                            "backend": {
                                                "service": {
                                                    "name": getServiceName(
                                                        api_base_name
                                                    ),
                                                    "port": {
                                                        "number": config["api"]["port"]
                                                    },
                                                }
                                            },
                                        }
                                    ]
                                },
                            },
                            {
                                "host": "api." + config["domain"],
                                "http": {
                                    "paths": [
                                        {
                                            "path": "/",
                                            "pathType": "Prefix",
                                            "backend": {
                                                "service": {
                                                    "name": getServiceName(
                                                        api_base_name
                                                    ),
                                                    "port": {
                                                        "number": config["api"]["port"]
                                                    },
                                                }
                                            },
                                        },
                                        {
                                            "path": "/socket.io",
                                            "pathType": "Prefix",
                                            "backend": {
                                                "service": {
                                                    "name": getServiceName(
                                                        api_base_name
                                                    ),
                                                    "port": {
                                                        "number": config["api"][
                                                            "websocketPort"
                                                        ]
                                                    },
                                                }
                                            },
                                        },
                                    ]
                                },
                            },
                        ]
                        + (
                            [
                                {
                                    "host": "db." + config["domain"],
                                    "http": {
                                        "paths": [
                                            {
                                                "path": "/",
                                                "pathType": "Prefix",
                                                "backend": {
                                                    "service": {
                                                        "name": getServiceName(
                                                            db_base_name
                                                        ),
                                                        "port": {"number": 3306},
                                                    }
                                                },
                                            }
                                        ]
                                    },
                                },
                            ]
                            if config["env"] == "development"
                            else []
                        ),
                    },
                },
            },
        ],
        "base_name": base_name,
    }
