import React, { Fragment, useEffect, useRef, useState } from 'react'
import Modal from 'react-modal'
import { css } from '@emotion/css'

/*

* userStyles.main
* userStyles.body
* userStyles.overlay

*/

const styles = {
  body: {
    width: '100%',
    overflowY: 'hidden',
  },
  main: {
    position: 'relative',
    margin: 0,
    paddingLeft: 250,
    // backgroundColor: '#F2F2F2',
    '@media (max-width: 980px)': {
      paddingLeft: 0,
    },
  },
  mainClose: {
    paddingLeft: 0,
    left: 0,
  },
  mainOpen: {
    '@media (min-width: 980px)': {
      paddingLeft: '250px',
      transition: 'padding-left 225ms cubic-bezier(0.0, 0, 0.2, 1)',
    },
    '@media (max-width: 980px)': {
      left: 250,
      transition: 'left 225ms cubic-bezier(0.0, 0, 0.2, 1)',
    },
  },
  drawer: {
    position: 'fixed',
    top: 0,
    height: '100vh',
    left: 0,
    width: 250,
    overflow: 'auto',
    '> *': {
      overflow: 'auto',
    },
    '@media (max-width: 980px)': {
      left: '-250px',
    },
  },
  drawerClose: {
    left: '-250px',
  },
  drawerOpen: {
    left: 0,
    transition: 'left 225ms cubic-bezier(0.0, 0, 0.2, 1)',
    '.ReactModal__Content--after-open': {
      left: 0,
      transition: 'left 225ms cubic-bezier(0.0, 0, 0.2, 1)',
    },
  },
  drawerOpenModal: {},
  overlay: {
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, .6)',
  },
}

const Drawer = ({
  breakpoint,
  drawer,
  main,
  onClickModal,
  open,
  width,
  styles: userStyles = {},
}) => {
  const [isMobile, setIsMobile] = useState(false)
  const mainEl = useRef(null)
  useEffect(() => {
    if (window.innerWidth < breakpoint) {
      setIsMobile(true)
    }
  }, [breakpoint])
  // const userStyles = this.props.styles || {}
  const w = width ? (typeof width === 'number' ? width + 'px' : width) : 250
  styles.main.paddingLeft = open ? w + 'px' : 0
  styles.mainOpen['@media (min-width: 980px)'].paddingLeft = w
  styles.mainOpen['@media (max-width: 980px)'].left = w
  styles.drawer.left = open ? 0 : '-' + w + 'px'
  styles.drawer.width = w + 'px'
  styles.drawer['@media (max-width: 980px)'].left = '-' + w
  styles.drawerClose.left = '-' + w + 'px'
  const isWindow = typeof window !== `undefined`
  return (
    <Fragment>
      <div
        ref={mainEl}
        id='toto'
        css={[
          styles.main,
          userStyles.main,
          isWindow && open ? styles.mainOpen : {},
          isWindow && !open ? styles.mainClose : {},
        ]}
      >
        {main}
      </div>
      {isWindow && isMobile ? (
        <Modal
          isOpen={open}
          onRequestClose={onClickModal}
          aria={{
            labelledby: 'Menu',
            describedby: 'Navigate through the site',
          }}
          appElement={mainEl.current}
          css={[
            styles.drawer,
            userStyles.drawer,
            isWindow && open && styles.drawerOpen,
            isWindow && !open && styles.drawerClose,
          ]}
          overlayClassName={css([
            styles.overlay,
            userStyles.overlay,
          ])}
          bodyOpenClassName={css([styles.body, userStyles.body])}
        >
          {drawer}
        </Modal>
      ) : (
        <div
          id="drawer"
          css={[
            styles.drawer,
            isWindow && open ? styles.drawerOpen : {},
            isWindow && !open ? styles.drawerClose : {},
          ]}
        >
          {drawer}
        </div>
      )}
    </Fragment>
  )
}

export default Drawer
