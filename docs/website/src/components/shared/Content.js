// React
import React, { Fragment, useState } from 'react'
import PropTypes from 'prop-types'
// Material UI
import { useTheme } from '@material-ui/core/styles';
import IconButton from '@material-ui/core/IconButton'
import Tooltip from '@material-ui/core/Tooltip'
import EditIcon from '@material-ui/icons/EditOutlined'
import ListIcon from '@material-ui/icons/ListOutlined'
import Toc from "./Toc"

require('prismjs/themes/prism-tomorrow.css')

const useStyles = theme => ({
  content: theme.mixins.gutters({
    // ...theme.typography,
    ...theme.typography.body1,
    paddingTop: 40,
    flex: '1 1 100%',
    maxWidth: '100%',
    margin: '0 auto 3rem',
    // fontSize: '1rem',
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
      ...theme.typography.root,
      ...theme.typography.h1,
      ...theme.typography.gutterBottom,
      color: '#777777',
      fontWeight: 'normal',
      '& code': {
        // color: '#000',
        padding: '.2em .3em .1em .3em',
        background: '#DFDEDE',
        borderRadius: '.3em'
      },
    },
    '& h2': {
      ...theme.typography.root,
      ...theme.typography.h2,
      ...theme.typography.gutterBottom,
      color: '#777777',
      fontWeight: 'normal',
      // marginTop: '3.5rem',
    },
    '& h3': {
      ...theme.typography.root,
      ...theme.typography.h3,
      ...theme.typography.gutterBottom,
      color: '#777777',
      fontWeight: 'normal',
      // marginTop: '2.5rem',
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
      // ...theme.typography.body1,
      // color: '#000',
      // textAlign: 'justify',
    },
    '& ul p': {
      // margin: 0,
    },
    '& ul': {
      paddingLeft: 20,
      // listStylePosition: 'inside',
    },
    '& li': {
      // color: '#2D2D2D',
      // textAlign: 'justify',
    },
    '& pre > code[class*="language-"]': {
      // fontSize: '1rem',
    },
    '& :not(pre) > code[class*="language-"]': {
      padding: '.2em .3em .1em .3em',
      background: '#DFDEDE',
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
    [theme.breakpoints.up(900 + theme.spacing(6))]: {
      maxWidth: 900,
    },
  }),
  tools: {
    float: 'right',
  },
  icons: {
    color: '#cccccc',
    '&:link,&:visited': {
      color: '#cccccc !important',
    },
    '&:hover': {
      textDecoration: 'none',
      color: theme.link.normal + ' !important',
    }
  },
})

const Content = ({
  children,
  page
}) => {
  const styles = useStyles(useTheme())
  const [isOpen, setIsOpen] = useState(false)
  const onToggle = () => {
    setIsOpen(!isOpen)
  }
  return (
    <main css={styles.content}>
      {page && (
        <Fragment>
          <div css={styles.tools}>
            {page.tableOfContents && page.tableOfContents.items && (
                <Tooltip id="content-toc" title="Toggle table of content">
                  <IconButton
                    color="inherit"
                    aria-labelledby="content-toc"
                    css={styles.icons}
                    onClick={onToggle}
                  >
                    <ListIcon />
                  </IconButton>
                </Tooltip>
            )}
            {page.edit_url && (
              <Tooltip id="content-edit" title="Edit on GitHub">
                <IconButton
                  color="inherit"
                  href={page.edit_url}
                  aria-labelledby="content-edit"
                  css={styles.icons}
                >
                  <EditIcon />
                </IconButton>
              </Tooltip>
            )}
          </div>
          <div dangerouslySetInnerHTML={{__html: page.titleHtml}} />
          {page.tableOfContents && page.tableOfContents.items && (
            <Toc
              startLevel={1}
              isOpen={isOpen}
              items={page.tableOfContents.items}
            />
          )}
        </Fragment>
      )}
      {children}
    </main>
  )
}

Content.propTypes = {
  children: PropTypes.node.isRequired,
}

export default Content
