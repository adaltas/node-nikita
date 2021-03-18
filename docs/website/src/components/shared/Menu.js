// React
import React from 'react'
// Material UI
import { useTheme } from '@material-ui/core/styles'
import Typography from '@material-ui/core/Typography'
// Gatsby
import { Link } from 'gatsby'

const useStyles = theme => ({
  root: {
    backgroundColor: '#fff',
    minHeight: '100vh',
    borderRight: '1px solid #0000001f',
    position: 'relative',
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
    paddingBottom: '75px',
  },
  footer: {
    position: 'absolute',
    bottom: 0,
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

const Menu = ({
  children
}) => {
  const styles = useStyles(useTheme())
  return (
    <div css={styles.root}>
      <div css={styles.toolbar}>
        <Link to="/">
          Documentation
        </Link>
        <Typography variant="caption">{'current version'}</Typography>
      </div>
      <div css={styles.body}>
        {children}
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

export default Menu
