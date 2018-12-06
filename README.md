# Paliari deploy

Ferramente para deploy, gerenciando releases e rollback

## Install

```bash
sh -c "$(curl -fsSL https://git.paliari.com.br/paliari/paliari-deploy/raw/master/install.sh)"
```

### Config

Create path .deploy with files stage-<stage>.yml and hooks.yml

#### Example of file .deploy/stage-pro.yml

```hml
deploy:
  remote:
    user: user-name
    host: paliari.com.br
    path: /home/isse/app/api
  publish:
    # choice git|scp|script
    git:
      url: git@git.paliari.com.br:paliari/paliari-deploy.git
      branch: master
    scp:
      path: .|dist
    script: heroku a b

```

#### Example of file .deploy/hooks.yml

```hml
deploy:
  hooks:
    repo:
      - echo call 1 in the repo
      - echo call 2 in the repo
    releases:
      - echo call 1 in the release
      - echo call 2 in the release

```

## Usage

```bash
$ paliari-deploy <action> <options>
```

## Commands

### init

Setup no servidor remoto.

```bash
  $ paliari-deploy init demo
```

### init

Setup no servidor remoto.

```bash
  $ paliari-deploy publish demo
```
