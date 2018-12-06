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

### Structure

```text
├── current -> /my_app_name/releases/20150120114500/
├── releases
│   ├── 20150080072500
│   ├── 20150090083000
│   ├── 20150100093500
│   ├── 20150110104000
│   └── 20150120114500
├── repo
│   └── <GIT related data>
└── shared
    └── <linked_files and linked_dirs>

```

## Usage

```bash
$ paliari-deploy <action> <options>
```

## Actions

### init

Setup no servidor remoto.

```bash
  $ paliari-deploy init demo
```

### publish

Publicar no servidor remoto.

```bash
  $ paliari-deploy publish demo
```
