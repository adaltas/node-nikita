const path = require('path')

const { createFilePath } = require(`gatsby-source-filesystem`)

exports.onCreateNode = ({ node, getNode, actions }) => {
  const { createNodeField } = actions
  if (node.internal.type === `MarkdownRemark`) {
    node.frontmatter.disabled = !!node.frontmatter.disabled
    slug = createFilePath({ node, getNode, basePath: `pages` })
    edit_url =
      "https://github.com/adaltas/node-nikita/edit/master/" +
      path.relative(__dirname, node.fileAbsolutePath)
    createNodeField({
      node,
      name: `slug`,
      value: slug,
    })
    createNodeField({
      node,
      name: `edit_url`,
      value: edit_url,
    })
  }
}

exports.createPages = ({ actions, graphql }) => {
  const { createPage, createRedirect } = actions
  const template = path.resolve(`src/templates/template.js`)
  return graphql(`
    {
      allMarkdownRemark(
        sort: { order: DESC, fields: [frontmatter___sort] }
        limit: 1000
      ) {
        edges {
          node {
            frontmatter {
              title
              redirects
              disabled
            }
            fields {
              slug
            }
          }
        }
      }
    }
  `).then(result => {
    if (result.errors) {
      return Promise.reject(result.errors)
    }
    result.data.allMarkdownRemark.edges.forEach(({ node }) => {
      if (node.frontmatter.disabled) return
      createPage({
        path: node.fields.slug,
        component: template,
        context: {}, // additional data can be passed via context
      })
      if (node.frontmatter.redirects) {
        node.frontmatter.redirects.map(redirect => {
          createRedirect({
            fromPath: redirect,
            toPath: node.fields.slug,
            isPermanent: true,
            redirectInBrowser: true,
          })
        })
      }
    })
  })
}
