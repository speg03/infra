# infra

## Generate SSH keys

```
$ ssh-keygen -f console.pem -N ''
```

## SSH configuration

```
Host console
  HostName console.speg03.be
  User ec2-user
  Port 22
  PasswordAuthentication no
  IdentityFile /path/to/console.pem
  IdentitiesOnly yes
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  ServerAliveInterval 60
```
