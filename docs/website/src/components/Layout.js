// React
import React, {useState} from 'react'
import Helmet from 'react-helmet'
// Gatsby
import { StaticQuery, graphql } from 'gatsby'
// Local
import AppBar from './shared/AppBar'
import Content from './shared/Content'
import Footer from './shared/Footer'
import Menu from './shared/Menu'
import Nav from './shared/Nav'
// Material UI
import { useTheme, makeStyles } from '@material-ui/core/styles'
import Drawer from '@material-ui/core/Drawer'
import useMediaQuery from '@material-ui/core/useMediaQuery'

const drawerWidth = 250
const useClasses = makeStyles((theme) => ({
  drawerPaper: {
    width: drawerWidth,
  },
}))
const useStyles = theme => ({
  content: {
    width: '100%',
    backgroundColor: 'rgb(242,242,242)',
    transition: theme.transitions.create(['margin', 'width'], {
      easing: theme.transitions.easing.easeOut,
      duration: theme.transitions.duration.enteringScreen,
    }),
  },
  shift: {
    width: `calc(100% - ${drawerWidth}px)`,
    marginLeft: drawerWidth,
    transition: theme.transitions.create(['margin', 'width'], {
      easing: theme.transitions.easing.easeOut,
      duration: theme.transitions.duration.enteringScreen,
    }),
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
  // Styles
  const theme = useTheme()
  const classes = useClasses()
  const styles = useStyles(theme)
  // State
  var isMobile = useMediaQuery(theme.breakpoints.down('xs'), {noSsr: true})
  const [isOpen, setIsOpen] = useState(home || isMobile ? false : true)
  const onToggle = () => {
    setIsOpen(!isOpen)
  }
  // Create menu
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
        variant={isMobile ? 'temporary' : 'persistent'}
        anchor='left'
        open={isOpen}
        onClose={onToggle}
        classes={{
          paper: classes.drawerPaper,
        }}
      >
        <Menu>
          <Nav menu={menu.children.current.children}/>
        </Menu>
      </Drawer>
      <AppBar
        onMenuClick={onToggle}
        site={data.site.siteMetadata}
        shift={isOpen && !isMobile && styles.shift}
        opacity={home ? 0.3 : 1}
      />
      <div css={[styles.content, intro ? null : styles.contentNoIntro, isOpen && !isMobile && styles.shift]}>
        { intro }
        <Content page={page}>{children}</Content>
        <Footer site={data.site.siteMetadata} />
      </div>
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
