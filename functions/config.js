const Typesense = require('typesense')

let client = new Typesense.Client({
    'nodes': [{
      'host': 'eu7yr24qz3mapd8bp-1.a1.typesense.net',
      'port': '443',
      'protocol': 'https'
    }],
    'apiKey': '3twJq5yegiYM8tMqqtcT5MGNOJK39iMR',
    'connectionTimeoutSeconds': 5
  })

module.exports = client