import { createMuiTheme } from '@material-ui/core/styles';
import purple from '@material-ui/core/colors/purple';
import lightBlue from '@material-ui/core/colors/lightBlue';
import green from '@material-ui/core/colors/green';

// A custom theme for this app
const theme = createMuiTheme({
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
    fontSize: 14,
    h1: {
      fontSize: 14,
    }
  },
});

export default theme;
