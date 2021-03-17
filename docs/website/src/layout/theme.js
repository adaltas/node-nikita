import { createMuiTheme, responsiveFontSizes } from '@material-ui/core/styles';
import purple from '@material-ui/core/colors/purple';
import lightBlue from '@material-ui/core/colors/lightBlue';
import green from '@material-ui/core/colors/green';
import {styles} from '@material-ui/core/Typography/Typography';

// A custom theme for this app
let theme = createMuiTheme({
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
      fontSize: '4rem',
    },
    h2: {
      fontSize: '3rem',
    },
    h3: {
      fontSize: '2rem',
    },
  },
});
theme = responsiveFontSizes(theme);
// Note, the current version of mui export `styles` function to enrich the 
// theme typography with additionnal properties like `root` and `gutterBottom`
// Things are changing in the future version of mui (branch `next`), there is
// `TypographyRoot` which we could use or the `typographyClasses` and the
// `getTypographyUtilityClass` properties.
// current: https://github.com/mui-org/material-ui/tree/ae27276980fd6f6950fc7d7ce7e19ab7215b03eb/packages/material-ui/src/Typography
// future: https://github.com/mui-org/material-ui/tree/next/packages/material-ui/src/Typography
// in the end, we dont need much, all the code below for:
// - typography.root: margin: 0
// - typography.gutterBottom: marginBottom: '0.35em'
theme.typography = {
  ...theme.typography,
  ...styles(theme),
}

export default theme;
