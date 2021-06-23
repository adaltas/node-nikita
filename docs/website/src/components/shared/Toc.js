
import React, {Fragment} from 'react'
// Material UI
import { useTheme } from '@material-ui/core/styles';
import { Link } from 'gatsby'

const useStyles = theme => ({
  head: {
    color: '#777777',
    fontSize: theme.typography.fontSize,
    fontWeight: 500,
    textTransform: 'uppercase'
  },
  list: {
    margin: theme.spacing(3, 0),
    paddingLeft: 0,
    '& li': {
      listStyle: 'none',
      marginBottom: theme.spacing(1),
    },
    '& a': {
      fontSize: '.9rem',
      textDecoration: 'none',
      '&:link,&:visited': {
        color: '#777777',
      },
      '&:hover': {
        color: theme.link.light,
      },
    },
  }
})

const Toc = ({
  startLevel,
  items,
}) => {
  const styles = useStyles(useTheme())
  const renderToc = (level, startLevel, items) => (
    items.map((item) => (
      <Fragment key={item.url} >
        {(level >= startLevel) && (
          <li>
            <Link to={item.url}>{item.title}</Link>
          </li>
        )}
        {item.items && renderToc(++level, startLevel, item.items)}
      </Fragment>
    ))
  )
  return (
    <nav>
      <span css={styles.head}>Table of Contents</span>
      <ul css={styles.list}>
        {renderToc(0, startLevel, items)}
      </ul>
    </nav>
  )
}

export default Toc
