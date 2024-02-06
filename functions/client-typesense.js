const Typesense = require('typesense')
const { removeStopwords, cat, spa, eng, fra } = require('stopword');

let debugClient = new Typesense.Client({
    'nodes': [{
      'host': 'eu7yr24qz3mapd8bp-1.a1.typesense.net',
      'port': '443',
      'protocol': 'https'
    }],
    'apiKey': '3twJq5yegiYM8tMqqtcT5MGNOJK39iMR',
    'connectionTimeoutSeconds': 5
  });

  let releaseClient = new Typesense.Client({
    'nodes': [{
      'host': 'eu7yr24qz3mapd8bp-1.a1.typesense.net',
      'port': '443',
      'protocol': 'https'
    }],
    'apiKey': '3twJq5yegiYM8tMqqtcT5MGNOJK39iMR',
    'connectionTimeoutSeconds': 5
  });


  function filterSymbols(inputString) {
    // Define a regular expression to match alphanumeric characters, spaces, and accented characters
    const regex = /[^a-zA-Z0-9áéíóúüñàèòçï\s]/g;

    // Use the regular expression to replace non-alphanumeric characters with an empty string
    const filteredText = inputString.replace(regex, '');

    return filteredText;
}

function removeDuplicates(inputString) {
  // Split the string into an array of words
  const words = inputString.split(/\s+/);

  // Create a Set to automatically eliminate duplicates
  const uniqueWordsSet = new Set(words);

  // Convert the Set back to an array
  const uniqueWordsArray = [...uniqueWordsSet];

  // Join the unique words back into a string
  const uniqueText = uniqueWordsArray.join(' ');

  return uniqueText;
}

function processText(inputString) {
  const symbolString = filterSymbols(inputString);
  const uniqueString = removeDuplicates(symbolString).split(' ');
  const processedString = removeStopwords(uniqueString, [...cat, ...spa, ...eng, ...fra]);
  return processedString
}

module.exports = {
  debugClient,
  releaseClient,
  processText
};