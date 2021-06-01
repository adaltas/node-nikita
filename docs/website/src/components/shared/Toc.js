
import React, {Fragment} from 'react'
// Material UI
import { makeStyles } from '@material-ui/core/styles';
import Collapse from '@material-ui/core/Collapse';

const useClasses = makeStyles((theme) => ({
  wrapperInner: {
    borderTop: '1px solid #E5E7EA',
    borderBottom: '1px solid #E5E7EA',
    padding: theme.spacing(2, 0),
    margin: theme.spacing(2, 0),
    '& h2': {
      marginTop: theme.spacing(2, '!important'),
    },
  },
}))

const Toc = ({
  startLevel,
  isOpen,
  items,
}) => {
  const classes = useClasses()
  const renderToc = (level, startLevel, items) => (
    items.map((item) => (
      <Fragment key={item.url}>
        {(level >= startLevel) && (
          <li>
            <a href={item.url}>{item.title}</a>
          </li>
        )}
        {item.items && renderToc(++level, startLevel, item.items)}
      </Fragment>
    ))
  )
  return (
    <Collapse in={isOpen}
       classes={{
         wrapperInner: classes.wrapperInner,
       }}
       >
      <h2>Table of Contents</h2>
      <ul>
        {renderToc(0, startLevel, items)}
      </ul>
    </Collapse>
  )
}

export default Toc
