// React
import React, { Component } from 'react'
import PropTypes from 'prop-types'
// Material UI
import IconButton from '@material-ui/core/IconButton'
import Tooltip from '@material-ui/core/Tooltip'
import EditIcon from '@material-ui/icons/EditOutlined'
import ListIcon from '@material-ui/icons/ListOutlined'
import { withStyles } from '@material-ui/core/styles'
import Toc from "./Toc"

require('prismjs/themes/prism-tomorrow.css')

const styles = theme => ({
  content: theme.mixins.gutters({
    ...theme.typography,
    paddingTop: 40,
    flex: '1 1 100%',
    maxWidth: '100%',
    margin: '0 auto 3rem',
    fontSize: '1rem',
    lineHeight: '1.6rem',
    '& a': {
      textDecoration: 'none',
      '&:link,&:visited': {
        color: '#00618E',
      },
      '&:hover': {
        textDecoration: 'none',
        color: theme.link.normal,
      },
    },
    '& h1': {
      color: '#777777',
      fontWeight: 'normal',
      '& code': {
        color: '#000',
        padding: '.2em .3em 0 .3em',
        background: '#E6E6E6',
        borderRadius: '.3em'
      },
    },
    '& h2': {
      color: '#777777',
      fontWeight: 'normal',
      marginTop: '3.5rem',
    },
    '& h3': {
      color: '#777777',
      fontWeight: 'normal',
      marginTop: '2.5rem',
    },
    // '& em': {
    //   color: '#2D2D2D',
    // },
    '& blockquote': {
      borderLeft: '3px solid #777777',
      margin: 0,
      paddingLeft: '40px',
    },
    '& blockquote p': {
      color: '#777777',
    },
    '& blockquote p > code[class*="language-"]': {
      color: '#646464',
    },
    '& p': {
      color: '#000',
      textAlign: 'justify',
    },
    '& ul p': {
      margin: 0,
    },
    '& ul': {
      paddingLeft: 20,
      // listStylePosition: 'inside',
    },
    '& li': {
      // color: '#2D2D2D',
      textAlign: 'justify',
    },
    '& pre > code[class*="language-"]': {
      fontSize: '1rem',
    },
    '& :not(pre) > code[class*="language-"]': {
      padding: '.2em .3em 0 .3em',
      background: '#E6E6E6',
      color: '#000',
    },
    '& .gatsby-highlight-code-line': {
      background: 'rgba(255,255,255,.2)',
      marginLeft: '-1rem',
      marginRight: '-1rem',
      paddingLeft: '.75rem',
      paddingRight: '1rem',
      borderLeft: '0.25rem solid rgba(255,255,255, .75)',
      display: 'block',
    },
  }),
  [theme.breakpoints.up(900 + theme.spacing(6))]: {
    content: {
      maxWidth: 900,
    },
  },
  icons: {
    float: 'right',
    color: '#cccccc',
    top: '-3.8rem',
    position: 'relative',
    '&:link,&:visited': {
      color: '#cccccc !important',
    },
    '&:hover': {
      textDecoration: 'none',
      color: theme.link.normal + ' !important',
    },
  },
})

class Content extends Component {
  state = { isOpen: false }
  render() {
    const onToggle = () => {
      this.setState({ isOpen: !this.state.isOpen })
    }
    const { classes, children, page } = this.props
    return (
      <main ref="content" className={classes.content}>
        {page && (
          <>
            <div dangerouslySetInnerHTML={{__html: page.titleHtml}} />
            <Tooltip id="content-edit" title="Edit on GitHub" enterDelay={300}>
              <IconButton
                color="inherit"
                href={page.edit_url}
                aria-labelledby="content-edit"
                className={classes.icons}
              >
                <EditIcon />
              </IconButton>
            </Tooltip>
            {page.tableOfContents.items
              && (
              <>
                <Tooltip
                  id="content-toc"
                  title="Toggle table of content"
                  enterDelay={300}
                >
                  <IconButton
                    color="inherit"
                    aria-labelledby="content-toc"
                    className={classes.icons}
                    onClick={onToggle}
                  >
                    <ListIcon />
                  </IconButton>
                </Tooltip>
                <Toc
                  startLevel={1}
                  isOpen={this.state.isOpen}
                  items={page.tableOfContents.items}
                />
              </>
            )}
          </>
        )}
        {children}
      </main>
    )
  }
}

Content.propTypes = {
  children: PropTypes.node.isRequired,
}

export default withStyles(styles, { withTheme: true })(Content)
