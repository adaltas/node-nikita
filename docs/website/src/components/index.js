// React
import React from 'react'
import Helmet from 'react-helmet'
// Material UI
import { withStyles } from '@material-ui/core/styles'
import withRoot from './mui/withRoot'
import 'typeface-roboto'
// Gatsby
import { StaticQuery, graphql } from 'gatsby'
// Local
import Drawer from './Drawer'
import AppBar from './shared/AppBar'
import Content from './shared/Content'
import Footer from './shared/Footer'
import Menu from './shared/Menu'
import Nav from './shared/Nav'
import Intro from './home/Intro'

const styles = theme => ({
  root: {
  },
  content: {
    backgroundColor: 'rgb(242,242,242)',
    // marginLeft: 0,
  },
})

class Layout extends React.Component {
  state = {
    open: false,
    breakpoint: 960,
  }
  render() {
    const { children, classes, data, page } = this.props
    const site = data.site.siteMetadata
    const onToggle = () => {
      this.setState({ open: !this.state.open })
    }
    const handleClickLink = () => {
      if(window.innerWidth < this.state.breakpoint){
        this.setState({ open: false })
      }
    }
    const menu = { children: {} }
    data.menu.edges.forEach(edge => {
      const slugs = edge.node.fields.slug.split('/').filter(part => part)
      let parentMenu = menu
      slugs.forEach(slug => {
        if (!parentMenu.children[slug])
          parentMenu.children[slug] = { data: {}, children: {} }
        parentMenu = parentMenu.children[slug]
      })
      parentMenu.data = {
        id: slugs.join('/'),
        navtitle: edge.node.frontmatter.navtitle,
        title: edge.node.frontmatter.title,
        slug: edge.node.fields.slug,
        sort: edge.node.frontmatter.sort || 99,
      }
    })
    return (
      <div className={classes.root}>
        <Helmet
          title={'NIKITA - ' + page.title || site.title}
          meta={[
            { name: 'description', content: page.description || site.description },
            { name: 'keywords', content: page.keywords || site.keywords },
            { name: 'google-site-verification', content: 'ukvG8Ae6z6Ly-ABtoUMWzRAPMmn07QWlbRnot0AC5FA'}
          ]}
        >
          <html lang="en" />
        </Helmet>
        <Drawer
          breakpoint={this.state.breakpoint}
          open={this.state.open}
          onClickModal={onToggle}
          main={
            <>
              <AppBar
                open={this.state.open}
                onMenuClick={onToggle}
                site={site}
                opacity={0.3}
              />
              <div className={classes.content}>
                <Intro />
                <Content>{children}</Content>
                <Footer site={site} />
              </div>
            </>
          }
          drawer={
            <Menu>
              {Object.values(menu.children.current.children)
              .sort((p1, p2) => p1.data.sort > p2.data.sort)
              .map(page => (
                <Nav
                  key={page.data.slug}
                  menu={page}
                  path={this.state.path}
                  onClickLink={handleClickLink}
                />
              ))}
            </Menu>
          }
        />
      </div>
    )
  }
}

const WrappedLayout = props => (
  <StaticQuery
    query={graphql`
      query IndexQuery {
        site: site {
          siteMetadata {
            title
            description
            github {
              url
              title
            }
            issues {
              url
              title
            }
            footer {
              title
              content
              links {
                label
                url
              }
              xs
              sm
            }
          }
        }
        menu: allMdx(
          filter: {
            frontmatter: { disabled: { eq: false } }
          }
          sort: { order: ASC, fields: [frontmatter___sort, fields___slug] }
        ) {
          edges {
            node {
              id
              excerpt(pruneLength: 250)
              frontmatter {
                navtitle
                title
                sort
              }
              fields {
                slug
              }
            }
          }
        }
      }
    `}
    render={data => <Layout data={data} {...props} />}
  />
)

export default withRoot(withStyles(styles, { withTheme: true })(WrappedLayout))
