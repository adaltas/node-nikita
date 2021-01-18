import React from 'react';
import CssBaseline from '@material-ui/core/CssBaseline';
import { createMuiTheme } from '@material-ui/core/styles';
import { ThemeProvider } from '@material-ui/styles';
import purple from '@material-ui/core/colors/purple';
import lightBlue from '@material-ui/core/colors/lightBlue';
import green from '@material-ui/core/colors/green';

function withRoot(Component) {
  class WithRoot extends React.Component {
    theme = null
    constructor(props) {
      super(props);
      this.theme = createMuiTheme({
        nprogress: {
          color: '#000',
        },
        link: {
          normal: lightBlue[500],
        },
        palette: {
          primary: {
            light: purple[300],
            main: purple[500],
            dark: purple[700],
          },
          secondary: {
            light: green[300],
            main: green[500],
            dark: green[700],
          },
        },
        typography: {
          fontSize: 17,
          body1: {
            // textAlign: 'justify',
          },
        },
      });
    }
    componentDidMount() {
      // Remove the server-side injected CSS.
      const jssStyles = document.querySelector('#server-side-jss');
      if (jssStyles && jssStyles.parentNode) {
        jssStyles.parentNode.removeChild(jssStyles);
      }
    }
    render() {
      return (
        <ThemeProvider theme={this.theme}>
          <CssBaseline />
          <Component {...this.props} />
        </ThemeProvider>
      );
    }
  }
  return WithRoot
}

export default withRoot
