// React
import React from 'react'
// Material UI
import { useTheme } from '@material-ui/core/styles'
import Typography from '@material-ui/core/Typography'
// Gatsby
import { Link, StaticQuery, graphql } from 'gatsby'
// Local
import Nav from './Nav'

const useStyles = theme => ({
  root: {
    height: '100%',
    backgroundColor: '#fff',
  },
  toolbar: {
    ...theme.mixins.toolbar,
    backgroundColor: '#f2f2f2',
    borderBottom: '1px solid #0000001f',
    paddingLeft: theme.spacing(2),
    display: 'flex',
    flexGrow: 1,
    flexDirection: 'column',
    alignItems: 'flex-start',
    justifyContent: 'center',
    color: theme.palette.grey[600],
    '& a': {
      ...theme.typography.body1,
      textDecoration: 'none',
      color: theme.palette.text.primary,
    },
  },
  body: {
    minHeight: 'calc(100% - 140px)',
  },
  footer: {
    backgroundColor: '#f2f2f2',
    padding: theme.spacing(2),
    borderTop: '1px solid #0000001f',
    color: theme.palette.grey[600],
    '& a': {
      textDecoration: 'none',
      color: theme.palette.text.primary,
    },
  },
})

const createMenu = (menu, page, nodes, maxDepth = 3) => {
  const pageSlugs = page.slug.split('/').filter(part => part)
  if (page.version !== null) // Don't count root version pages (eg. "/current/")
    pageSlugs.shift()
  const limitPageSlugs = pageSlugs.slice(0, maxDepth - 1)
  nodes.forEach( node => {
    const slugs = node.slug.split('/').filter(part => part)
    if(node.version.alias) slugs.shift() // Don't count root version pages (eg. "/current/")
    // Filter items for current page
    var flag = false
    if(slugs.length === 1)
      flag = true // pass all root pages
    if(page.slug.indexOf(node.slug.replace(/[a-z0-9-_]*\/$/, '')) === 0)
      flag = true // pass same and lower level pages with the same path
    if(slugs.slice(0, maxDepth - 1).toString() === limitPageSlugs.toString())
      flag = true
    if(!flag) return
    let parentMenu = menu
    // Get menu hierarchy
    slugs.forEach((slug, i) => {
      if (i > maxDepth - 1) return
      if (i === maxDepth - 1)
        slug = slugs.slice(maxDepth - 1, slugs.length).join('/')
      if (!parentMenu.children[slug]){
        parentMenu.children[slug] = { data: {}, children: {} }
      }
      parentMenu = parentMenu.children[slug]  
    })
    parentMenu.data = {
      navtitle: node.navtitle || (node.frontmatter ? node.frontmatter.navtitle : ''),
      title: node.title || (node.frontmatter ? node.frontmatter.title : ''),
      slug: node.slug,
      sort: (node.frontmatter ? node.frontmatter.sort || 99 : '') || 99,
    }
  })
}

const Menu = ({
  page,
  data
}) => {
  const menu = { children: {} }
  createMenu(menu, page, data.pages.nodes) // Pages
  // Actions root page
  menu.children.actions = {
    children: {},
    data: {
      title: 'Actions',
      slug: '/current/actions/',
      sort: 10,
    }
  }
  createMenu(menu, page, data.packages.nodes) // Packages
  createMenu(menu, page, data.actions.nodes) // Actions
  const styles = useStyles(useTheme())
  return (
    <div css={styles.root}>
      <div css={styles.toolbar}>
        <Link to="/">
          Documentation
        </Link>
        <Typography variant="caption">{page.version ? `${page.version} version` : 'current version'}</Typography>
      </div>
      <div css={styles.body}>
        <Nav menu={menu}/>
      </div>
      <div css={styles.footer}>
        <Typography variant="caption">
          Help us
          {' '}
          <a
            href="https://github.com/adaltas/node-nikita/issues"
          >
            improve the docs
          </a>{' '}
          by fixing typos and proposing enhancements.
        </Typography>
      </div>
    </div>
  )
}

const WrappedMenu = props => (
  <StaticQuery
    query={graphql`
      query NavQuery {
        pages: allNikitaPage(
          filter: { frontmatter: { disabled: { eq: false } } }
          sort: { order: ASC, fields: [frontmatter___sort, slug] }
        ) {
          nodes {
            frontmatter {
              navtitle
              title
              sort
            }
            version {
              alias
            }
            slug
          }
        }
        packages: allNikitaPackage(sort: {fields: slug, order: ASC}) {
          nodes {
            slug
            title: name
            version {
              alias
            }
          }
        }
        actions: allNikitaAction(sort: {fields: slug, order: ASC}) {
          nodes {
            slug
            title: name
            version {
              alias
            }
          }
        }
      }
    `}
    render={data => <Menu data={data} {...props} />}
  />
)

export default WrappedMenu
