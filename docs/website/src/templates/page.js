// React
import React, { Component } from 'react'
// Material UI
import { withStyles } from '@material-ui/core/styles'
// Gatsby
import { graphql } from 'gatsby'
// MDX
import { MDXProvider } from "@mdx-js/react"
import { MDXRenderer } from "gatsby-plugin-mdx"
// Local
import Layout from '../components/Layout'

const styles = theme => ({})

class Template extends Component {
  render() {
    const { data } = this.props
    const { page } = data // data.markdownRemark holds our post data
    return (
      <Layout page={{...page.fields, ...page.frontmatter, tableOfContents: page.tableOfContents}}>
        <MDXProvider>
          <MDXRenderer>{page.body}</MDXRenderer>
        </MDXProvider>
      </Layout>
    )
  }
}
export default withStyles(styles, { withTheme: true })(Template)

export const pageQuery = graphql`
  query($path: String!) {
    page: mdx(fields: { slug: { eq: $path } }) {
      body
      fields {
        slug
        edit_url
      }
      frontmatter {
        title
        titleHtml
        description
        keywords
      }
      tableOfContents(maxDepth: 2)
    }
  }
`
