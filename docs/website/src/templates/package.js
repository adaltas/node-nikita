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
  const { page } = data
  return (
    <Layout page={{
        keywords: page.keywords,
        description: page.description,
        ...page.parent.frontmatter,
        slug: page.slug,
        edit_url: page.edit_url,
        tableOfContents: page.parent.tableOfContents}}>
      <MDXProvider>
        <MDXRenderer>{page.parent.body}</MDXRenderer>
      </MDXProvider>
    </Layout>
  )
}
export default Template

export const pageQuery = graphql`
  query($path: String!) {
    page: nikitaPackage(slug: { eq: $path }) {
      slug
      edit_url
      description
      keywords
      parent {
        ... on Mdx {
          frontmatter {
            title
            titleHtml
          }
          body
          tableOfContents(maxDepth: 2)
        }
      }
    }
  }
`
