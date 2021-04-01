module.exports = {
  // Seems it is not used, leave commented until published
  // pathPrefix: `/node-nikita`,
  siteMetadata: {
    title: 'Nikita',
    siteUrl: `https://nikita.js.org`,
    description:
      'Nikita - Automation of system deployments for applications and infrastructures.',
    keywords:
      'automation, deployment, node.js, devops, systems, applications, infrastructures',
    github: {
      url: 'https://github.com/adaltas/node-nikita',
      title: 'Nikita GitHub Repository',
    },
    issues: {
      url: 'https://github.com/adaltas/node-nikita/issues',
      title: 'Report an issue',
    },
    footer: [
      {
        title: 'Navigate',
        links: [
          {
            label: 'Getting started',
            url: '/current/about/',
          },
          {
            label: 'Usages',
            url: '/current/usages/',
          },
          {
            label: 'Metadata',
            url: '/current/metadata/',
          },
          {
            label: 'Action',
            url: '/current/action/',
          },
        ],
        xs: 6,
        sm: 3,
      },
      {
        title: 'Contribute',
        links: [
          {
            label: 'GitHub',
            url: 'https://github.com/adaltas/node-nikita',
          },
          {
            label: 'Issue Tracker',
            url: 'https://github.com/adaltas/node-nikita/issues',
          },
          {
            label: 'License',
            url: '/current/about/license',
          },
        ],
        xs: 6,
        sm: 3,
      },
      {
        title: 'About',
        content:
          'Nikita is an open source product hosted on <a href="https://www.github.com" target="_blank" rel="noopener">GitHub</a> and developed by <a href="http://www.adaltas.com" target="_blank" rel="noopener">Adaltas</a>.',
        xs: 12,
        sm: 6,
      },
    ],
  },
  plugins: [
    {
      resolve: 'nikita-pages'
    },
    {
      resolve: 'nikita-packages',
      options: {
        path: `${__dirname}/../../packages`,
        ignore: ['nikita'],
      },
    },
    {
      resolve: 'nikita-actions',
      options: {
        path: `${__dirname}/../../packages`,
      },
    },
    {
      resolve: `gatsby-plugin-material-ui`,
      options: {
        stylesProvider: {
          injectFirst: true,
        },
      },
    },
    `gatsby-plugin-react-helmet`,
    {
      resolve: `gatsby-plugin-emotion`,
    },
    {
      resolve: `gatsby-source-filesystem`,
      options: {
        path: `${__dirname}/../content`,
        name: 'pages',
      },
    },
    {
      resolve: `gatsby-source-filesystem`,
      options: {
        path: `${__dirname}/../../packages`,
        name: 'actions',
        ignore: ['**/assets', '**/env', '**/lib', '**/test']
      },
    },
    {
      resolve: "gatsby-plugin-mdx",
      options: {
        extensions: [`.mdx`, `.md`],
        gatsbyRemarkPlugins: [
          {
            resolve: 'gatsby-remark-title-to-frontmatter',
          },
          {
            resolve: 'gatsby-remark-autolink-headers',
            options: {
              offsetY: '64', // <600: 48; >600:64
            },
          },
          {
            resolve: `gatsby-remark-prismjs`,
            options: {
              classPrefix: 'language-',
              inlineCodeMarker: null,
              aliases: {},
              showLineNumbers: false,
              inlineCodeMarker: '±',
              prompt: {
                user: "whoami",
                host: "localhost",
                global: false,
              },
            },
          },
        ],
        // Fixes CSS of anchor icon
        // see https://github.com/gatsbyjs/gatsby/issues/20441 
        plugins: ['gatsby-remark-autolink-headers']
      }
    },
    {
      resolve: `gatsby-plugin-catch-links`,
    },
    {
      resolve: `gatsby-plugin-google-analytics`,
      options: {
        trackingId: 'UA-1322093-4',
      },
    },
    {
      resolve: `gatsby-plugin-manifest`,
      options: {
        name: 'Nikita',
        short_name: 'Nikita',
        start_url: '/',
        background_color: '#ffffff',
        theme_color: '#105859',
        display: 'minimal-ui',
        icon: 'src/images/logo.png', // This path is relative to the root of the site.
      },
    },
    {
      resolve: `gatsby-plugin-offline`,
    },
    {
      resolve: `gatsby-plugin-sitemap`,
    },
    {
      resolve: 'gatsby-plugin-robots-txt',
      options: {
        host: 'https://nikita.js.org',
        sitemap: 'https://nikita.js.org/sitemap.xml',
        policy: [{ userAgent: '*', allow: '/' }]
      }
    },
  ],
}
