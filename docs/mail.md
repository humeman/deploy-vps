# mail
Deploys a complete mail stack (Postfix, Dovecot, PostfixAdmin, DMARC, DKIM, SpamAssassin, ...)

## deploying mail only
This repo is set up as a full CI server deployer, but it's possible to just deploy the mail stuff on a server.

These assume you're on some Debian-based Linux, if you're on Windows you'll want to use WSL.

This is designed to target an Ubuntu server.

#### set up your domain
- Create an A record at the `mail` subdomain pointing to your server's IP
  - If on Cloudflare, turn off proxying (use DNS only).
- Create an MX record at your domain's root pointing to `mail.<your-domain>`.

#### install server dependencies
If you don't have them, MariaDB Server and nginx are required.
- `sudo apt update`
- `sudo apt install -y mariadb-server nginx`

#### set up Spamhaus
This provides automatic spam blocking.

Go to [Spamhaus](https://www.spamhaus.com/data-access/free-data-query-service/) and sign up, you'll get a list of domains. We'll use the Zen and DBL domains later.

#### set up ansible
- Install Ansible Playbook, Ansible Galaxy, and Task:
  - `sudo apt update`
  - `sudo apt install -y ansible ansible-galaxy task`
- Create a user on your server that has sudo access.
  - `sudo adduser ansibledeploy`
  - `sudo usermod -aG sudo ansibledeploy`
- Create an inventory file pointing to your server.
  - Name it `inventory` and put it in the root directory of this repository.
  - In it:
    ```
    [servers]
    <ssh host> ansible_user=ansibledeploy ansible_become_password=<ssh user password> ansible_ssh_common_args='-o StrictHostKeyChecking=no'
    ```
- Install an SSH key for the user so Ansible can connect.
  - If you don't have an SSH key:
    - `ssh-keygen`
  - `ssh-copy-id ansibledeploy@<your-server-ip>`
- Create a vault file.
  - Name it `vault.yml` and put it in the root directory of this repository.
  - Follow the steps below for what to put in it.

#### configure vault
The `vault.yml` template to deploy mail is:
```yml
env: prod

# The hostname of your server, ie what you SSH into.
hostname: "<server hostname>"

# This can be any email address you own. It's used by Let's Encrypt for SSL certificates.
email_address: "<any email address>"

flags:
  setup: false
  users: false
  ssh: false
  fail2ban: false
  alerting: false
  backblaze: false
  mysql: false
  nginx: false
  docker: false
  pelican: false
  wings: false
  mongodb: false
  bind9: true
  mail: true
  logwatch: false
  crowdsec: false

dependency_versions:
  # This has to match whatever is in your server's Ubuntu repositories.
  # On Ubuntu Server 24.04, it'd be '8.4'.
  php: "<php version>"

mail:
  # The hostname where you're pointing the MX record of your server.
  host: "<mail server hostname>"
  
  dkim_hosts:
    # The domain you're using at the end of your email address, ie 'mydomain.com' for 'me@mydomain.com'.
    - "<email address domain>"
    
  postfixadmin:
    version: "3.3.15"
    download: "https://github.com/postfixadmin/postfixadmin/archive/refs/tags/postfixadmin-3.3.15.tar.gz"

    # Pick whatever you want here. It'll autocreate them in your local MariaDB instance.
    sql_db: postfixadmin
    sql_user: postfixadmin
    sql_password: "<a secure password>"

    # A temporary secure password, used the first time to set up PostfixAdmin
    setup_password: "<a secure password>"

  # Spamhaus stuff from earlier
  dbl: "<dbl-domain>"
  zen: "<zen-domain>"
```

#### run Ansible
Run `ONLY_DEPLOY=mail,bind9 task deploy-local`.

## domain setup
* Add your domain to the domain list on PostfixAdmin (https://localhost:8100)
  * If running remotely, use `ssh me@server.com -L 8100:localhost:8100` to forward it to your machine.
* Add the following record: `TXT  <subdomain-or-@>   v=spf1 mx ~all`
  * This goes off of your email's domain. If just your site, use `@`, otherwise a subdomain (eg: `@dev.csenneff.com` -> `dev`).
* Run Ansible.
* Add the domain key to your DNS.
  * You'll find this on the system with `cat /etc/opendkim/keys/<domain>/default.txt`
  * Most DNS providers should have an import button that can load it.
* Start creating virtual lists (users)
  * When logging in, use `SSL/TLS` for both incoming/outgoing servers.
  * `STARTTLS` also works if not available.

Optional but useful stuff: 
* Set up Postmark: https://dmarc.postmarkapp.com/
* Run an email test: https://www.mail-tester.com/
