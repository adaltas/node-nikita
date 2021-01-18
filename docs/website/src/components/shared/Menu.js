// React
import React from 'react'
// Material UI
import { withStyles } from '@material-ui/core/styles'
import Divider from '@material-ui/core/Divider'
import Typography from '@material-ui/core/Typography'
// Gatsby
import { Link, push } from 'gatsby'

const styles = theme => ({
  root: {
    // position: 'relative',
    backgroundColor: 'rgb(245, 245, 245)',
    // height: '100%',
  },
  toolbar: {
    ...theme.mixins.toolbar,
    paddingLeft: theme.spacing(2),
    display: 'flex',
    flexGrow: 1,
    flexDirection: 'column',
    alignItems: 'flex-start',
    justifyContent: 'center',
    color: theme.palette.grey[600],
    '& a': {
      textDecoration: 'none',
      color: theme.palette.text.primary,
    },
  },
  footer: {
    paddingLeft: theme.spacing(2),
    paddingRight: theme.spacing(2),
    borderTop: '1px solid rgb(200, 200, 200)',
    padding: '20px 0',
    backgroundColor: 'rgb(245, 245, 245)',
    // textAlign: 'justify',
    color: theme.palette.grey[600],
    '& a': {
      textDecoration: 'none',
      color: theme.palette.text.primary,
    },
  },
})

class Menu extends React.Component {
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
    const { classes, children } = this.props
    return (
      <div className={classes.root}>
        <div>
          <div className={classes.toolbar}>
            <Link to="/">
              Documentation
            </Link>
            <Typography variant="caption">{'version 0.8'}</Typography>
          </div>
          <Divider />
        </div>
        {children}
        <div className={classes.footer}>
          <Typography variant="caption">
            Help us{' '}
            <a
              href="https://github.com/adaltas/node-nikita-docs/issues"
            >
              improve the docs
            </a>{' '}
            by fixing typos and proposing enhancements.
          </Typography>
        </div>
      </div>
    )
  }
}

export default withStyles(styles, { withTheme: true })(Menu)
