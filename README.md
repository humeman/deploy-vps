# deploy-vps
Ansible resources and GitHub actions for deploying my main VPS to dev and prod environments.

## execution
PRs are automatically checked & diffed against dev and prod nodes on submission.

When merged into `main`, changes are automatically applied to dev.

To apply to prod, manually kick off the `Apply Latest to Prod` action.

## secrets
For each environment, these secrets are used:
- `SSH_USER_<env>`
- `SSH_KEY_<env>`
- `SSH_HOST_<env>`
- `SSH_SUDO_<env>`

## node setup
When deploying a node initially, use these setup steps:
1. Create a user corresponding to `SSH_USER_<env>`
    - [Disable password auth](https://serverfault.com/questions/285800/how-to-disable-ssh-login-with-password-for-some-users)
    - Add to sudoers
2. Generate and add an SSH key for `git@github.com`

#