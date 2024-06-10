# mail
Deploys Postfix, Dovecot, and PostfixAdmin.

## domain setup
* Add to https://localhost:8100
* Create `dmarc-reports@<domain>`
* Add the following record: `TXT  <subdomain-or-@>   v=spf1 mx ~all`
* Run Ansible
* Add the domain key: `/etc/opendkim/keys/<domain>/default.txt`
* Add a DMARC record: `TXT  _dmarc  v=DMARC1; p=none; pct=100; rua=mailto:dmarc-reports@<domain>`
* And, set up Postmark: https://dmarc.postmarkapp.com/ (add commas to `rua`, like `rua=mailto:email1,mailto:email2`)