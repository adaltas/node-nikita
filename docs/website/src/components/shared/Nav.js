// React
import React from 'react'
import classNames from 'classnames'
// Material UI
import Collapse from '@material-ui/core/Collapse'
import IconButton from '@material-ui/core/IconButton'
import ListItemText from '@material-ui/core/ListItemText'
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction'
import MenuItem from '@material-ui/core/MenuItem'
import MenuList from '@material-ui/core/MenuList'
import { withStyles } from '@material-ui/core/styles'
import ExpandLess from '@material-ui/icons/ExpandLess'
import ExpandMore from '@material-ui/icons/ExpandMore'
// Gatsby
import { Link, push } from 'gatsby'

const styles = theme => ({
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
    '&:active': {
      color: theme.link.normal,
    },
  },
  active: {
    color: theme.link.normal,
  },
})

class Nav extends React.Component {
  state = { open: true }
  handleClick = e => {
    // e.stopPropagation()
    this.setState({ open: !this.state.open })
  }
  navigate = to => {
    const { menu } = this.props
    push({
      pathname: menu.data.slug,
      state: {
        // showPage: true,
      },
    })
  }
  render() {
    const { classes, menu, onClickLink } = this.props
    const pages = Object.values(menu.children)
      .sort((p1, p2) => p1.data.sort > p2.data.sort)
      .map(page => (
        <MenuItem
          component={Link}
          key={page.data.slug}
          to={page.data.slug}
          activeClassName={classes.active}
          className={classNames(classes.link, classes.leaf)}
          onClick={onClickLink}
        >
          {page.data.navtitle || page.data.title}
        </MenuItem>
      ))
    return (
      <div className={classes.root}>
        <MenuList component="nav">
          <MenuItem
            component={Link}
            to={menu.data.slug}
            activeClassName={classes.active}
          >
            <ListItemText primary={menu.data.title} />
            <ListItemSecondaryAction>
              <IconButton onClick={this.handleClick}>
                {this.state.open ? <ExpandLess /> : <ExpandMore />}
              </IconButton>
            </ListItemSecondaryAction>
          </MenuItem>
          <Collapse in={this.state.open} timeout="auto" unmountOnExit>
            <MenuList component="ul" disablePadding>
              {pages}
            </MenuList>
          </Collapse>
        </MenuList>
      </div>
    )
  }
}

export default withStyles(styles, { withTheme: true })(Nav)
