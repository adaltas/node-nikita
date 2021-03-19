// React
import React, {Fragment, useEffect, useState} from 'react'
import Helmet from 'react-helmet'
// Gatsby
import { StaticQuery, graphql } from 'gatsby'
// Local
import Drawer from './Drawer'
import AppBar from './shared/AppBar'
import Content from './shared/Content'
import Footer from './shared/Footer'
import Menu from './shared/Menu'
import Nav from './shared/Nav'
// Material UI
import { useTheme } from '@material-ui/core/styles';

const useStyles = theme => ({
  content: {
    backgroundColor: 'rgb(242,242,242)',
  },
  contentNoIntro: {
    paddingTop: theme.spacing(8),
  },
})

const Layout = ({
  children,
  data,
  intro,
  home = false,
  page,
}) => {
  const styles = useStyles(useTheme())
  const [isOpen, setIsOpen] = useState(home ? false : true)
  const [breakpoint] = useState(960)
  useEffect( () => {
    if (window.innerWidth < breakpoint) {
      setIsOpen(false)
    }
  }, [breakpoint])
  const onToggle = () => {
    setIsOpen(!isOpen)
  }
  // const handleClickLink = () => {
  //   if(window.innerWidth < breakpoint){
  //     setIsOpen(false)
  //   }
  // }
  const menu = { children: {} }
  data.menu.edges.forEach(edge => {
    // Filter items for current page
    if((page.slug || '/current/').indexOf(edge.node.fields.slug.replace(/[a-z0-9-_]*\/$/, '')) === -1) return
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
              onMenuClick={onToggle}
              site={data.site.siteMetadata}
              open={isOpen}
              opacity={home ? 0.3 : 1}
            />
            <div css={[styles.content, intro ? null : styles.contentNoIntro]}>
              { intro }
              <Content page={page}>{children}</Content>
              <Footer site={data.site.siteMetadata} />
            </div>
          </Fragment>
        }
        drawer={
          <Menu>
            <Nav menu={menu.children.current.children}/>
          </Menu>
        }
      />
    </div>
  )
}

const WrappedLayout = props => (
  <StaticQuery
    query={graphql`
      query DocQuery {
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
            fields: { slug: { regex: "/^/.+/" } }
          }
          sort: { order: ASC, fields: [frontmatter___sort, slug] }
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

export default WrappedLayout
