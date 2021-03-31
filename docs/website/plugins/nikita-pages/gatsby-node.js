
const crypto = require("crypto")
const path = require("path")
const grayMatter = require("gray-matter")
const { createFilePath } = require('gatsby-source-filesystem')

exports.createSchemaCustomization = ({ actions }) => {
  const { createTypes } = actions
  createTypes(`
    """
    NikitaPages Node
    """
    type NikitaPages implements Node @infer {
      frontmatter: NikitaPagesFrontmatter
      version: Int!
      slug: String!
      edit_url: String
    }
    type NikitaPagesFrontmatter {
      disabled: Boolean
      title: String
      navtitle: String
      sort: Int
    }
  `)
}

exports.onCreateNode = (args) => {
  const { actions, createNodeId, node, getNode, loadNodeContent, store, cache } = args
  const { createNode } = actions
  if (node.internal.type !== `Mdx`) { return }
  // Filter non-docs pages
  if(!/\/docs\/content\//.test(node.fileAbsolutePath)){ return }
  // Custom fields
  node.frontmatter.disabled = !!node.frontmatter.disabled
  const currentVersion = 1, version = 1 // Currently only 1 version
  const slug = `/${currentVersion == version ? 'current' : `v${version}`}${createFilePath({ node, getNode })}`
  const edit_url =
    "https://github.com/adaltas/node-nikita/edit/master/" +
    path.relative(`${__dirname}/../../../../`, node.fileAbsolutePath)
  const copy = {}
  const filter = ['children', 'id', 'internal', 'fields', 'parent', 'type']
  Object.keys(node).map( key => {
    if(!filter.some(k => k === key)) copy[key] = node[key]
  })
  createNode({
    // Custom fields
    ...copy,
    version: version,
    slug: slug,
    edit_url: edit_url,
    // Gatsby fields
    id: createNodeId(slug),
    parent: node.id,
    children: [],
    internal: {
      type: 'NikitaPages',
      // // An optional field. This is rarely used. It is used when a source plugin sources data it doesn’t know how to transform 
      // content: content,
      // the digest for the content of this node. Helps Gatsby avoid doing extra work on data that hasn’t changed.
      contentDigest: crypto
        .createHash(`md5`)
        .update(JSON.stringify(node))
        .digest(`hex`)
    }
  })
}

exports.createPages = ({ actions, graphql }) => {
  const { createPage, createRedirect } = actions
  const template = path.resolve(`src/templates/page.js`)
  return graphql(`
    {
      pages: allNikitaPages {
        edges {
          node {
            frontmatter {
              disabled
            }
            slug
          }
        }
      }
    }
  `).then(result => {
    if (result.errors) {
      return Promise.reject(result.errors)
    }
    result.data.pages.edges.forEach(({ node }) => {
      if (node.frontmatter.disabled) return
      createPage({
        path: node.slug,
        component: template,
        context: {}, // additional data can be passed via context
      })
    })
  })
}
