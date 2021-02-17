// React
import React, {Fragment, useState} from 'react'
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

const styles = {
  content: {
    backgroundColor: 'rgb(242,242,242)',
  },
}

const Layout = ({
  children,
  data,
  page
}) => {
  const [isOpen, setIsOpen] = useState(false)
  const [breakpoint] = useState(960)
  const onToggle = () => {
    setIsOpen(!isOpen)
  }
  const handleClickLink = () => {
    if(window.innerWidth < breakpoint){
      setIsOpen(false)
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
    <div>
      <Helmet
        title={'NIKITA - ' + page.title}
        meta={[
          { name: 'description', content: page.description },
          { name: 'keywords', content: page.keywords },
          { name: 'google-site-verification', content: 'ukvG8Ae6z6Ly-ABtoUMWzRAPMmn07QWlbRnot0AC5FA'}
        ]}
      >
        <html lang="en" />
      </Helmet>
      <Drawer
        breakpoint={breakpoint}
        open={isOpen}
        onClickModal={onToggle}
        main={
          <Fragment>
            <AppBar
              open={isOpen}
              onMenuClick={onToggle}
              site={data.site.siteMetadata}
              opacity={0.3}
            />
            <div css={styles.content}>
              <Intro />
              <Content>{children}</Content>
              <Footer site={data.site.siteMetadata} />
            </div>
          </Fragment>
        }
        drawer={
          <Menu>
            {Object.values(menu.children.current.children)
            .sort((p1, p2) => p1.data.sort > p2.data.sort)
            .map(page => (
              <Nav
                key={page.data.slug}
                menu={page}
                onClickLink={handleClickLink}
              />
            ))}
          </Menu>
        }
      />
    </div>
  )
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
