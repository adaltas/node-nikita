// React
import React, {useState} from 'react'
// Material UI
import { useTheme } from '@material-ui/core/styles';
import Collapse from '@material-ui/core/Collapse'
import IconButton from '@material-ui/core/IconButton'
import ListItemText from '@material-ui/core/ListItemText'
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction'
import MenuItem from '@material-ui/core/MenuItem'
import MenuList from '@material-ui/core/MenuList'
import ExpandLess from '@material-ui/icons/ExpandLess'
import ExpandMore from '@material-ui/icons/ExpandMore'
// Gatsby
import { Link } from 'gatsby'

const useStyle = theme => ({
  root: {
    backgroundColor: '#FFF',
  },
  leaf: {
    fontWeight: theme.typography.fontWeightLight,
    paddingTop: theme.spacing(.33),
    paddingBottom: theme.spacing(.33),
  },
  link: {
    ...theme.typography.caption,
    textDecoration: 'none',
    color: theme.palette.grey[600],
    // paddingTop: 0,
    // paddingBottom: 0,
    minHeight: 'auto',
    '&:hover': {
      textDecoration: 'none',
    },
  },
  active: {
    color: theme.link.normal,
  },
})

const Nav = ({
  menu,
  onClickLink
}) => {
  const [isOpen, setIsOpen] = useState(true)
  const handleClick = (e) => {
    setIsOpen(!isOpen)
  }
  const styles = useStyle(useTheme())
  const pages = Object.values(menu.children)
    .sort((p1, p2) => p1.data.sort > p2.data.sort)
    .map(page => (
      <MenuItem
        component={Link}
        key={page.data.slug}
        to={page.data.slug}
        css={[styles.link, styles.leaf]}
        onClick={onClickLink}
        activeStyle={styles.active}
      >
        {page.data.navtitle || page.data.title}
      </MenuItem>
    ))
  return (
    <div css={styles.root}>
      <MenuList component="nav">
        <MenuItem
          component={Link}
          to={menu.data.slug}
          activeStyle={styles.active}
        >
          <ListItemText primary={menu.data.title} />
          <ListItemSecondaryAction>
            <IconButton onClick={handleClick}>
              {isOpen ? <ExpandLess /> : <ExpandMore />}
            </IconButton>
          </ListItemSecondaryAction>
        </MenuItem>
        <Collapse in={isOpen} timeout="auto" unmountOnExit>
          <MenuList component="ul" disablePadding>
            {pages}
          </MenuList>
        </Collapse>
      </MenuList>
    </div>
  )
}

export default Nav
