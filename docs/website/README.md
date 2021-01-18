
# Nikita Website

The official website of the [Nikita project](https://github.com/adaltas/node-nikita). It is written with [Gatsby.js](https://www.gatsbyjs.org/) and [Material-UI](https://material-ui.com/).

To install and run the server:

```
git clone https://github.com/adaltas/node-nikita.git nikita
cd nikita/docs/website
yarn install
npm run develop
```

## TODO

* Automatic conversion between CoffeeScript and JavaScript source code
* Import Nikita source code written in CoffeeScript Literate.

## Request

Create a GitHub personal access token with the "public_repo - Access public repositories" access. Encrypt the token for Travis:

```
docker run \
  --rm -v $PWD:/repo -v ~/.travis:/travis \
  andredumas/travis-ci-cli \
  encrypt GH_TOKEN="..your..token.."
```
