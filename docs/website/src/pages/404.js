import React from 'react'
import Layout from '../components/Layout'

const NotFoundPage = ({ data }) => (
  <Layout
    page={{
      title: 'Page not found',
      description: 'The requested page does not exist',
      keywords: 'nikita, node.js, 404, not found'
    }}
  >
    <div>
      <h1>NOT FOUND</h1>
      <p>You just hit a route that doesn&#39;t exist... the sadness.</p>
    </div>
  </Layout>
)

export default NotFoundPage
