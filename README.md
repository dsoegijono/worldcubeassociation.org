worldcubeassociation.org
========================

This repository contains all of the code that runs on [worldcubeassociation.org](https://www.worldcubeassociation.org/).

NOTE: Currently, serving of static files doesn't work on Windows because it relies
upon symlinks to get apache to serve content outside of the DocumentRoot. There
are some things we could try to get this working on Windows, please comment
on this [issue](https://github.com/cubing/worldcubeassociation.org/issues/11) if
you're interested in helping out.

## Setup
- Install [Vagrant](https://www.vagrantup.com/), which requires
  [VirtualBox](https://www.virtualbox.org/).
- `git clone https://github.com/cubing/worldcubeassociation.org` - Clone this repo! (And navigate into it, `cd worldcubeassociation.org`)
- `git submodule update --init --recursive` - Initialize submodules. (Note: you will need to have access to the [cubing/wca-website-php](https://github.com/cubing/wca-website-php) repo, and an [SSH key](https://help.github.com/articles/generating-ssh-keys/) set up for this.)
- `(cd WcaOnRails; bundle install) && pre-commit install` - Set up git pre-commit hook. Optional, but very useful.

## Run
- `vagrant up dev` - Once the VM finishes initializing (which can take some time),
  the website will be accessible at [http://localhost:8080](http://localhost:8080).

## Deploy
- `time DIGITAL_OCEAN_API_KEY=<API_KEY> vagrant up staging|production --provider=digital_ocean`
- `ssh staging.worldcubeassociation.org pkill -U gjcomps -f rails`

## API
See http://localhost:3000/oauth/applications/ (WcaOnRails/db/seeds.rb) to view
and create new test applications.

```bash
> curl http://localhost:3000/oauth/token -X POST -F grant_type=password -F username=wca@worldcubeassociation.org -F password=wca`
{"access_token":"1d6c95446cab947224286b7bec4382d898c664c7a3cafb16d3d110a3044cf4dc","token_type":"bearer","expires_in":7200,"created_at":1430788134}
> curl -H "Authorization: Bearer 1d6c95446cab947224286b7bec4382d898c664c7a3cafb16d3d110a3044cf4dc" http://localhost:3000/api/v0/me
{"me":{"id":1,"email":"wca@worldcubeassociation.org","created_at":"2015-05-05T00:57:11.788Z","updated_at":"2015-05-05T00:57:12.072Z"}}
```
