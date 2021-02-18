// React
import React from 'react'
// Material UI
import { useTheme } from '@material-ui/core/styles'
import Divider from '@material-ui/core/Divider'
import Typography from '@material-ui/core/Typography'
// Gatsby
import { Link } from 'gatsby'

const useStyles = theme => ({
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

const Menu = ({
  children
}) => {
  const styles = useStyles(useTheme())
  return (
    <div css={styles.root}>
      <div>
        <div css={styles.toolbar}>
          <Link to="/">
            Documentation
          </Link>
          <Typography variant="caption">{'version 0.8'}</Typography>
        </div>
        <Divider />
      </div>
      {children}
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

export default Menu
