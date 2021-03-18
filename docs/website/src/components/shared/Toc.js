
import React, {Fragment} from 'react'

const styles = {
  toc: {
    borderTop: '1px solid #E5E7EA',
    borderBottom: '1px solid #E5E7EA',
    padding: '5px 0',
    display: 'none',
    '& h2': {
      marginTop: '1rem !important',
    },
    '& ul': {
      marginTop: 0,
      marginBottom: 0,
    },
  },
  tocVisible: {
    display: 'block'
  }
}
  
const Toc = ({
  startLevel,
  isOpen,
  items,
}) => {
  const renderToc = (level, startLevel, items) => (
    items.map((item) => (
      <Fragment key={item.url}>
        {(level >= startLevel) && (
          <li>
            <a href={`${item.url}`}>{item.title}</a>
          </li>
        )}
        {item.items && renderToc(++level, startLevel, item.items)}
      </Fragment>
    ))
  )
  return (
    <div css={[styles.toc, isOpen && styles.tocVisible]}>
      <h2>Table of Contents</h2>
      <ul>
        {renderToc(0, startLevel, items)}
      </ul>
    </div>
  )
}

export default Toc
