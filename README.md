# DevOpsToolkit
## Setup
```
curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/get_devops_toolkit.sh | bash
```

### -t production -> USE_DEFAULTS=true
```
curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/get_devops_toolkit.sh -t production | bash -s -- -t production
```

### -t staging -> USE_DEFAULTS=true
```
curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/get_devops_toolkit.sh -t staging | bash -s -- -t staging
```

### -t dev -> USE_DEFAULTS=true
```
curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/get_devops_toolkit.sh | bash -s -- -t dev
```


### -t dev -key "ssh-pub-key" -> USE_DEFAULTS=true
```
curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/get_devops_toolkit.sh | bash -s -- -t dev -key "ssh-pub-key"
```