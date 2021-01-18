// React
import React, { Component } from 'react'
// Material UI
import { withStyles } from '@material-ui/core/styles'
// Gatsby
import { graphql } from 'gatsby'
// Local
import Layout from '../components/Layout'

const styles = theme => ({})

class Template extends Component {
  render() {
    const { data } = this.props
    const { page } = data // data.markdownRemark holds our post data
    return (
      <Layout page={{...page.fields, ...page.frontmatter}}>
        <div dangerouslySetInnerHTML={{ __html: page.html }} />
      </Layout>
    )
  }
}
export default withStyles(styles, { withTheme: true })(Template)

export const pageQuery = graphql`
  query($path: String!) {
    page: markdownRemark(fields: { slug: { eq: $path } }) {
      html
      fields {
        slug
        edit_url
      }
      frontmatter {
        title
        description
        keywords
      }
    }
  }
`
