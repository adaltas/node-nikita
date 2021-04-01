
const crypto = require("crypto")
const nikita = require("nikita")
const path = require('path')
const fs = require('fs').promises
const constants = require('fs').constants

exports.createSchemaCustomization = ({ actions }) => {
  const { createTypes } = actions
  createTypes(`
    """
    NikitaAction Node
    """
    type NikitaAction implements Node @dontInfer {
      name: String!
      action: [String]!
      version: String!
      slug: String!
      edit_url: String!
      packageName: String!
      srcPath: String
    }
  `)
}

exports.sourceNodes = async ({ actions, createNodeId }, pluginOptions) => {
  const { createNode } = actions
  const nikitaActions = await nikita.registry.get({flatten: true})
  nikitaActions.forEach( async (action) => {
    // Filter actions without modules
    if (!action.metadata || !action.metadata.module) return
    // Get custom fields
    const name = action.action.join('.')
    const packageName = action.metadata.module.split('/')[1]
    const currentVersion = 1, version = 1 // Currently only 1 version
    const actionPath = action.action[0] === packageName ? action.action.join('/') : [packageName, action.action.join('/')].join('/')
    var slug = [
      currentVersion == version ? 'current' : `v${version}`,
      'actions',
      actionPath
    ].join('/')
    slug = `/${slug}/`
    var srcPath = action.metadata.module
      .replace('@nikitajs/','')
      .replace(/\/lib$/,'/src')
      .replace('/lib/','/src/')
    pluginOptions.path = path.resolve(pluginOptions.path)
    srcPath = path.join(path.basename(pluginOptions.path), srcPath)
    try {
      await fs.access(path.resolve(pluginOptions.path, '../', `${srcPath}.coffee.md`), constants.R_OK)  // check if exists
      srcPath = `${srcPath}.coffee.md`
    } catch (err) {
      await fs.access(path.resolve(pluginOptions.path, '../', `${srcPath}/index.coffee.md`), constants.R_OK)  // check if exists
      srcPath = `${srcPath}/index.coffee.md`
    }
    const edit_url = `https://github.com/adaltas/node-nikita/edit/master/${srcPath}`
    // Create node
    createNode({
      // Custom fields
      name: name,
      action: action.action,
      version: version,
      packageName: packageName,
      metadata: action.metadata,
      srcPath: srcPath, // needed to filter Mdx
      slug: slug,
      edit_url: edit_url,
      // Gatsby fields
      id: createNodeId(slug),
      parent: null,
      children: [],
      internal: {
        type: 'NikitaAction',
        // // An optional field. This is rarely used. It is used when a source plugin sources data it doesn’t know how to transform 
        // content: content,
        // the digest for the content of this node. Helps Gatsby avoid doing extra work on data that hasn’t changed.
        contentDigest: crypto
          .createHash(`md5`)
          .update(slug)
          .digest(`hex`)
      }
    })
  })
}

exports.createResolvers = ({ createResolvers, createNodeId }) => {
  createResolvers({
    NikitaAction: {
      package: {
        type: 'NikitaPackage',
        resolve(source, args, context, info) {
          // We use an author's `email` as foreign key in `BlogJson.authors`
          return context.nodeModel
          .getAllNodes(
            { type: 'NikitaPackage' },
            { connectionType: 'NikitaPackage' }
          )
          .filter( target =>
            source.packageName == target.name
          )[0]
        }
      },
      parent: {
        resolve(source, args, context, info) {
          // We use an author's `email` as foreign key in `BlogJson.authors`
          return context.nodeModel
          .getAllNodes(
            { type: 'Mdx' },
            { connectionType: 'Mdx' }
          )
          .filter( target =>
            new RegExp(source.srcPath).test(target.fileAbsolutePath)
          )[0]
        }
      }
    }
  })
}


exports.createPages = ({ actions, graphql }) => {
  const { createPage, createRedirect } = actions
  const template = path.resolve(`src/templates/action.js`)
  return graphql(`
    {
      actions: allNikitaAction {
        edges {
          node {
            slug
          }
        }
      }
    }
  `).then(result => {
    if (result.errors) {
      return Promise.reject(result.errors)
    }
    result.data.actions.edges.forEach(({ node }) => {
      createPage({
        path: node.slug,
        component: template,
        context: {}, // additional data can be passed via context
      })
    })
  })
}
