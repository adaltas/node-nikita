import React from 'react'
// Material UI
import Button from '@material-ui/core/Button'
import IconButton from '@material-ui/core/IconButton'
import SvgIcon from '@material-ui/core/SvgIcon'
import { withStyles } from '@material-ui/core/styles'
// Gatsby
import { Link } from 'gatsby'
// Particles
import Particles from 'react-particles-js'
import particles from './particles'
import mw_low from './milky-way-low.jpg'
import mw_high from './milky-way-high.jpg'
// Scroll
import { animateScroll as scroll } from 'react-scroll'

const styles = theme => ({
  root: {
    // backgroundColor: '#42456C !important',
    background: `no-repeat url(${mw_low})`,
    backgroundSize: `cover`,
    position: 'relative',
    height: '100vh',
    // A test to fix mobile viewport, can be removed if not working
    minHeight: 'calc(100% - 0)',
    '& h1': {
      fontSize: '6rem',
      margin: '0 0 1rem',
    },
    '& p': {
      fontSize: '2rem',
      margin: '0 0 .5rem',
    },
    // Mobile portrait
    '@media (max-width: 600px)': {
      '& h1': {
        fontSize: '3rem !important',
      },
      '& p': {
        fontSize: '1rem !important',
        margin: '0 0 .5rem !important',
      },
    },
    // Mobile landscape
    '@media (max-height: 400px)': {
      '& h1': {
        fontSize: '3rem !important',
      },
      '& p': {
        fontSize: '1rem !important',
        margin: '0 0 .5rem !important',
      },
    },
  },
  bck: {
    background: `no-repeat url(${mw_high})`,
    backgroundSize: `cover`,
    height: '100%',
  },
  content: {
    ...theme.typography,
    bottom: '0%',
    width: '100%',
    position: 'absolute',
    textAlign: 'center',
    color: '#ffffff',
    '@media (max-width: 600px)': {
      bottom: '10%',
    },
  },
  button: {
    margin: theme.spacing(),
  },
  headlines: {
    margin: '0 0 2rem',
  },
  outlined: {
    borderColor: '#fff',
    color: '#fff',
    // backgroundColor: 'rgba(0, 0, 0, 0.2)',
    backgroundColor: 'rgba(255, 255, 255, 0.08)',
    '&:hover': {
      backgroundColor: 'rgba(255, 255, 255, 0.2)',
    },
  },
  scrollDown: {
    color: 'rgba(255, 255, 255, 0.6)',
    fontSize: 32,
    // display: 'block',
    textAlign: 'center',
    '&:hover': {
      color: 'rgba(255, 255, 255, 1)',
      // backgroundColor: 'rgba(255, 255, 255, 0.2)',
    },
  },
})

class Intro extends React.Component {
  render() {
    const { classes } = this.props
    const scrollDown = e => {
      const offset = window.innerHeight - (window.innerHeight < 600 ? 48 : 64)
      scroll.scrollTo(offset, {
        duration: 400,
        delay: 0,
        smooth: 'easeInOutQuart',
      })
    }
    return (
      <div className={classes.root}>
        <Particles params={particles} className={classes.bck} />
        <div className={classes.content}>
          <h1>Nikita</h1>
          <div className={classes.headlines}>
            <p>{'Automation and deployment solution'}</p>
            <p>{'Built for Node.js, MIT License'}</p>
            <p>{'Deploy apps and infrastructures'}</p>
          </div>
          <Button
            component={Link}
            to="/about/tutorial/"
            size="large"
            variant="outlined"
            className={classes.button}
            classes={{ outlined: classes.outlined }}
          >
            {'Get started'}
          </Button>
          <Button
            component={Link}
            to="/about/changelog/"
            size="large"
            variant="outlined"
            className={classes.button}
            classes={{ outlined: classes.outlined }}
          >
            {'Changelog'}
          </Button>
          <div>
            <IconButton
              aria-label="Learn more"
              className={classes.scrollDown}
              onClick={scrollDown}
            >
              <SvgIcon>
                <g>
                  <g>
                    <path d=" M 1.649 1.861 C 1.271 1.488 0.66 1.488 0.283 1.861 C -0.094 2.234 -0.095 2.84 0.283 3.213 L 11.317 14.139 C 11.694 14.512 12.306 14.512 12.683 14.139 L 23.717 3.213 C 24.094 2.84 24.094 2.235 23.717 1.861 C 23.34 1.488 22.729 1.488 22.351 1.861 L 12 11.825 L 1.649 1.861 Z " />
                  </g>
                  <g>
                    <path d=" M 1.649 9.861 C 1.271 9.488 0.66 9.488 0.283 9.861 C -0.094 10.234 -0.095 10.84 0.283 11.213 L 11.317 22.139 C 11.694 22.512 12.306 22.512 12.683 22.139 L 23.717 11.213 C 24.094 10.84 24.094 10.235 23.717 9.861 C 23.34 9.488 22.729 9.488 22.351 9.861 L 12 19.825 L 1.649 9.861 Z " />
                  </g>
                </g>
              </SvgIcon>
            </IconButton>
          </div>
        </div>
      </div>
    )
  }
}

export default withStyles(styles, { withTheme: true })(Intro)
