// React
import React from 'react'
// Gatsby
import { graphql } from 'gatsby'
// MDX
import { MDXProvider } from "@mdx-js/react"
import { MDXRenderer } from "gatsby-plugin-mdx"
// Local
import Layout from '../components/Layout'

const Template = ({
  data
}) => {
  const { action } = data
  return (
    <Layout page={{
        keywords: action.package.keywords,
        description: action.parent.excerpt,
        ...action.parent.frontmatter,
        slug: action.slug,
        edit_url: action.edit_url,
        tableOfContents: action.parent.tableOfContents}}>
      <MDXProvider>
        <MDXRenderer>{action.parent.body}</MDXRenderer>
      </MDXProvider>
    </Layout>
  )
}
export default Template

export const pageQuery = graphql`
  query($path: String!) {
    action: nikitaAction(slug: { eq: $path }) {
      slug
      edit_url
      package {
        id
        keywords
      }
      parent {
        ... on Mdx {
          frontmatter {
            title
            titleHtml
          }
          body
          tableOfContents(maxDepth: 2)
          excerpt(truncate: true, pruneLength: 200)
        }
      }
    }
  }
`
