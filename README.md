# DevOpsToolkit

The **DevOpsToolkit** repository provides a collection of scripts and configurations to quickly and easily set up a development, staging, or production environment. It is flexible and allows configuration based on user-defined settings or the use of default values.

## Configuration

The file [config.temp.yaml](https://github.com/NiklasJavier/DevOpsToolkit/blob/HEAD/environments/config.temp.yaml) illustrates the options that can be set as variables during the execution of our script. However, the actual configuration takes place dynamically during the script execution, where the user can adjust the variables or use automatically generated default values.

### Variables in `config.yaml`:

- **`system_name`**:  
  The name of the system or server used for configuration. If the user does not provide a name, a random name will be generated.  
  Example:  
  ```yaml
  system_name: "$SYSTEM_NAME"
  ```

- **`ssh_port`**:  
  The SSH port through which the connection to the server is established. By default, port **282** is used if the user does not specify a port.  
  Example:  
  ```yaml
  ssh_port: "$SSH_PORT"
  ```

- **`log_level`**:  
  The desired log level for the application’s logging. Possible options are `"debug"`, `"info"`, `"warn"`, and `"error"`. Default value: **info**.  
  Example:  
  ```yaml
  log_level: "$LOG_LEVEL"
  ```

- **`opt_data_dir`**:  
  The data directory where application data is stored. It is by default based on `system_name` (e.g., `/opt/$SYSTEM_NAME/data`) unless another directory is specified.  
  Example:  
  ```yaml
  opt_data_dir: "$OPT_DATA_DIR"
  ```

- **`use_defaults`**:  
  A flag variable indicating whether the script runs in "default mode." When `use_defaults` is set to **true**, no prompts are given to the user, and default values are used automatically.  
  Example:  
  ```yaml
  use_defaults: "$USE_DEFAULTS"
  ```

- **`tools`**:  
  This variable contains the list of tools to be installed. The user can manually specify the tools (e.g., `docker ansible terraform`). If no input is provided or `USE_DEFAULTS=true`, all default tools will be selected automatically.  
  Example:  
  ```yaml
  tools: "$TOOLS"
  ```

- **`ssh_key_function_enabled`**:  
  This variable indicates whether the SSH key function is enabled. It is set to **false** if no SSH key is provided or the function is disabled by default unless a valid SSH key is entered.  
  Example:  
  ```yaml
  ssh_key_function_enabled: "$SSH_KEY_FUNCTION_ENABLED"
  ```

- **`ssh_key_public`**:  
  Contains the public SSH key provided by the user. If no key is entered, this variable remains empty.  
  Example:  
  ```yaml
  ssh_key_public: "$SSH_KEY_PUBLIC"
  ```

- **`tools_dir`**:  
  Stores the path to the directory where various tools (e.g., Ansible, Docker, Terraform) are stored.  
  Example:  
  ```yaml
  tools_dir: "$TOOLS_DIR"
  ```

- **`scripts_dir`**:  
  Stores the path to the directory where general scripts are stored.  
  Example:  
  ```yaml
  scripts_dir: "$SCRIPTS_DIR"
  ```

- **`pipelines_dir`**:  
  Stores the path to the directory where pipeline configuration files (e.g., CI/CD pipelines) are stored.  
  Example:  
  ```yaml
  pipelines_dir: "$PIPELINES_DIR"
  ```

## Setup

To install and configure **DevOpsToolkit**, the following script can be used. Several options are available to configure different environments.

### Standard Setup

This setup uses default values for all variables:

```bash
curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/get_devops_toolkit.sh | bash
```

### Setup Options:

The following commands use the **`-t`** flag to specify the type of environment. The **`-key`** flag can optionally be added to provide a public SSH key.

- **`-t production`**:  
  Sets **`USE_DEFAULTS=true`** and sets up a production environment.

  ```bash
  curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/get_devops_toolkit.sh | bash -s -- -t production
  ```

- **`-t staging`**:  
  Sets **`USE_DEFAULTS=true`** and sets up a staging environment.

  ```bash
  curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/get_devops_toolkit.sh | bash -s -- -t staging
  ```

- **`-t dev`**:  
  Sets **`USE_DEFAULTS=true`** and sets up a development environment.

  ```bash
  curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/get_devops_toolkit.sh | bash -s -- -t dev
  ```

- **`-t dev -key "ssh-pub-key"`**:  
  Sets **`USE_DEFAULTS=true`**, sets up a development environment, and enables the SSH key function with the provided public key.

  ```bash
  curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/get_devops_toolkit.sh | bash -s -- -t dev -key "ssh-pub-key"
  ```

## Option Explanations

- **`-t production / staging / dev`**:  
  This option specifies which environment will be set up. The **`USE_DEFAULTS=true`** option ensures that no user input is required, and the default values are applied automatically.

- **`-key "ssh-pub-key"`**:  
  This option allows you to provide a public SSH key. When a key is provided, the SSH key function is enabled, and the key is added to the server.