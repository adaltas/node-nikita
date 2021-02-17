// React
import React from 'react'
// Material UI
import { withStyles } from '@material-ui/core/styles'
import Grid from '@material-ui/core/Grid'
import Typography from '@material-ui/core/Typography'
// Gatsby
import { Link } from 'gatsby'

const styles = theme => ({
  root: {
    flexGrow: 1,
    backgroundColor: 'rgba(18, 24, 47, 1)',
  },
  rootInner: theme.mixins.gutters({
    ...theme.typography,
    flex: '1 1 100%',
    maxWidth: '100%',
    margin: '0 auto',
  }),
  [theme.breakpoints.up(900 + theme.spacing(6))]: {
    rootInner: {
      maxWidth: 900,
    },
  },
  subheading: {
    color: '#CCC8C7',
  },
  paper: {
    padding: theme.spacing(2),
    textAlign: 'justify',
    color: '#CCC8C7',
  },
  ul: {
    margin: '1rem 0',
    padding: 0,
    listStyle: 'none',
    color: '#CCC8C7',
    '& li': {
      margin: 0,
      padding: 0,
      listStyle: 'none',
    },
    '& a': {
      color: '#fff',
      textDecoration: 'none',
    },
    '& a:hover': {
      color: theme.link.normal,
    },
  },
  content: {
    margin: '1rem 0',
    color: '#CCC8C7',
    '& a': {
      color: '#fff',
      textDecoration: 'none',
    },
    '& a:hover': {
      color: theme.link.normal,
    },
  },
})

const Footer = ({
  classes,
  site
}) => {
  return (
    <footer className={classes.root}>
      <div className={classes.rootInner}>
        <Grid container spacing={0}>
          {site.footer.map((footer, i) =>  (
            <Grid key={'footer' + i} item xs={footer.xs || 4} sm={footer.sm || 4}>
              <div className={classes.paper}>
                <Typography variant="subtitle1" className={classes.subheading}>
                  {footer.title}
                </Typography>
                {footer.links && (
                  <ul className={classes.ul}>
                    {footer.links.map((link, j) => (
                      <li key={'footer' + i + '-' + j}>
                        {/^http/.test(link.url) ? (
                          <a href={link.url}>
                            {link.label}
                          </a>
                        ) : (
                          <Link to={link.url}>{link.label}</Link>
                        )}
                      </li>
                    ))}
                  </ul>
                )}
                {footer.content && (
                  <Typography
                    className={classes.content}
                    dangerouslySetInnerHTML={{ __html: footer.content }}
                  />
                )}
              </div>
            </Grid>
          ))}
        </Grid>
      </div>
    </footer>
  )
}

export default withStyles(styles, { withTheme: true })(Footer)
