# deploy-vps
Ansible resources and GitHub actions for deploying my main VPS to dev and prod environments.

## execution
PRs are automatically checked & diffed against dev and prod nodes on submission.

When merged into `main`, changes are automatically applied to dev.

To apply to prod, manually kick off the `Apply Latest to Prod` action.

## secrets
For each environment, one secret is used containing various deployment details. It is a base64-encoded JSON string.

Keys:
* `vault_k`: Ansible vault key
* `bucket`: GCS bucket for Ansible vault
* `sa`: GCP service account key, base64 encoded
* `host`: Server's hostname (must be able to SSH through this)
* `key`: SSH private key
* `sudo`: Sudo password
* `user`: User to SSH in as

## node setup
When deploying a node initially, use these setup steps:
1. Create a user for Ansible.
    - [Disable password auth](https://serverfault.com/questions/285800/how-to-disable-ssh-login-with-password-for-some-users).
    - Add to sudoers.
    - Set a secure password for sudoing.
    - Store the username and password in `user` and `sudo`, then the SSH host in `host`.
2. Create an SSH key for Ansible.
    - Base64-encode the private key and store in your secrets as `key`.
    - Add the public key to the Ansible user's `.ssh/authorized_keys`.
3. Create an Ansible vault.
    - First, create a secure key for the vault (arbitrary) and store in `vault_k`.
    - Then, run `ansible-vault create vault`.
4. Create a GCS bucket.
    - Name is arbitrary. Place the name in `bucket` in secrets.
    - Generate a service account with read access. Place the base64-encoded key in `sa`.
5. Upload your vault.
    - Expected path is `<repo-name>/vault`. In this case, `deploy-vps/vault`.

At this point, your GitHub workflow should work.

## running locally
You'll need to have `task`, `ansible`, `gcloud`, and `jq` installed.
```sh
# Activate your Google Cloud service account
gcloud auth activate-service-account --key-file /path/to/sa.json

# Set the environment to deploy to
export ENV=dev

# Set the secrets for that environment (b64 encoded)
export SECRETS_dev=$(cat /path/to/base64/encoded/secrets.json.b64)

# Validate Ansible
task check

# Deploy
task deploy
```

## vault format
The vault is stored in YAML format with the following options:
* `env`: The environment name. E: `dev`
* `version_name`: The release name of the environment. E: `noble`
* `hostname`: The server's hostname. E: `devnode.csenneff.com`
* `allow_ipv6`: Whether the server supports IPv6. E: `false`
* `email_address`: Email used for Certbot, alerting, etc. E: `camden@csenneff.com`
* `b2_account`, `b2_key`, `b2_bucket`: Backblaze B2 details, if enabled.
* `extra_backups`: A list of extra folders to back up to Backblaze. Most feature flags will result in automatic backups of their important directories.
* `discord_webhook_url`: A discord (or Slack) webhook URL for alerting.
* `users`: Users to auto-deploy. A list.
    * `name`: User's username. E: `camden`
    * `groups`: A list of groups to add to. E: `["sudo"]`
    * `ssh_keys`: A list of SSH keys to allow.
    * `state`: The user's state. E: `present`
* `pterodactyl`: Pterodactyl deployment details, if wanted. A dict.
    * `ports`: A list of ports to open. Panel is already opened. E: `[25565]`
    * `user`: The default admin user. A dict.
        * `username`: The user's username. E: `admin`
        * `password`: The user's default password.
        * `email`: The user's email address. E: `camden@csenneff.com`
        * `first`: The user's first name.
        * `last`: The user's last name.
    * `sql`: MySQL database details. Automatically deployed.
        * `db`: Database name. E: `pterodactyl`
        * `user`: The username. E: `pterodactyl`
        * `password`: The password.
    * `panel_host`: The panel's FQDN. E: `panel.csenneff.com`
    * `wings_host`: The panel's Wings host. E: `devnode.csenneff.com`
    * `wings_init_command`: The Wings init command generated by the panel. Typically, you would deploy Pterodactyl alone, get this command, write it to the vault, enable the Wings flag, and re-deploy.
* `mongodb`: MongoDB details. A dict.
    * `admin_password`: Admin user password.
* `mail`: [Mailserver setup](docs/mail.md). A dict.
    * `host`: Mailserver host -- ie, what you point MX records to. E: `devmail.csenneff.com`
    * `dkim_hosts`: Hosts to validate with DKIM. Usually all the domains you'll receive mail to. A list. E: [`dev.csenneff.com`]
    * `postfixadmin`: Details for the PostfixAdmin deployment. A dict.
        * `sql_db`: Database name (SQL is all automatically deployed, don't create this yourself). E: `postfixadmin`
        * `sql_user`: The username. E: `postfixadmin`
        * `sql_password`: The password.
        * `setup_password`: The initialization setup password to use.