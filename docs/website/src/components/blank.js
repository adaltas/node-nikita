// React
import React, { Component } from 'react'
import PropTypes from 'prop-types'
// Material UI
import { withStyles } from '@material-ui/core/styles'
import withRoot from './mui/withRoot'
import 'typeface-roboto'

const styles = theme => ({})

class AppFrame extends Component {
  render() {
    const { children, theme } = this.props
    return <div>{children}</div>
  }
}
AppFrame.propTypes = {
  children: PropTypes.func,
}

export default withRoot(withStyles(styles, { withTheme: true })(AppFrame))
// export default AppFrame
