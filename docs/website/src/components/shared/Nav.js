// React
import React, {Fragment} from 'react'
// Material UI
import { useTheme } from '@material-ui/core/styles';
import ListItemText from '@material-ui/core/ListItemText'
import MenuItem from '@material-ui/core/MenuItem'
import MenuList from '@material-ui/core/MenuList'
import Divider from '@material-ui/core/Divider'
// Gatsby
import { Link } from 'gatsby'

const useStyles = theme => ({
  devider: {
    margin: '0 10px',
  },
  bottomNav: {
    paddingTop: theme.spacing(1),
    paddingBottom: theme.spacing(1),
  },
  bottomNavTitle: {
    opacity: 0.35,
    textTransform: 'uppercase',
    paddingTop: theme.spacing(4),
    paddingLeft: theme.spacing(2),
    paddingBottom: theme.spacing(1),
    fontSize: '1rem',
  },
  children: {
    '& a': {
      paddingLeft: theme.spacing(4),
    }
  },
  active: {
    color: theme.link.normal,
  },
})

const Item = ({
  page,
  styles
}) => (
  <MenuItem
    component={Link}
    to={page.data.slug}
    activeStyle={styles.active}
    partiallyActive={true}
  >
    <ListItemText primary={page.data.navtitle || page.data.title} />
  </MenuItem>
)

const BottomNav = ({
  menu,
  styles
}) => {
  const pages = Object.values(menu.children)
  .sort((p1, p2) => p1.data.sort > p2.data.sort)
  .map(page => {
    return (
      <Fragment key={page.data.slug}>
        <Item page={page} styles={styles} />
        {Object.keys(page.children).length !== 0 && (
          <MenuList css={styles.children}>
            {Object.values(page.children)
              .sort((p1, p2) => p1.data.sort > p2.data.sort)
              .map(child => (
                <Item key={child.data.slug} page={child} styles={styles} />
              ))}
          </MenuList>
        )}
      </Fragment>
    )
  })
  return (
    <div css={styles.bottomNav}>
      <Divider css={styles.devider}/>
      <div css={styles.bottomNavTitle}>{menu.data.navtitle || menu.data.title}</div>
      {pages}
    </div>
  )
}

const Nav = ({
  menu
}) => {
  const styles = useStyles(useTheme())
  var current
  const pages = Object.values(menu)
  .sort((p1, p2) => p1.data.sort > p2.data.sort)
  .map(page => {
    if(Object.keys(page.children).length !== 0)
      current = page
    return (
      <Item key={page.data.slug} page={page} styles={styles} />
    )
  })
  return (
    <MenuList component="nav">
      {pages}
      {current && current.children && (
        <BottomNav styles={styles} menu={current} />
      )}
    </MenuList>
  )
}

export default Nav
