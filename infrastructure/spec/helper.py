def addNum(name, num = 1): return name + ("-" + str(num) if num > 1 else "")

def getDeploymentName(base, num = 1): return addNum(base + "-deployment", num)
def getSecretName(base, num = 1): return addNum(base + "-secret", num)
def getServiceName(base, num = 1): return addNum(base + "-service", num)
def getConfigName(base, num = 1): return addNum(base + "-config", num)
def getIngressName(base, num = 1): return addNum(base + "-ingress", num)
def getVolumeClaimName(base, num = 1): return addNum(base + "-volume-claim", num)

