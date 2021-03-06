requirejs.config
  shim:
    'spellcheck':
      exports: '$Spelling'
    'deepCopy':
      exports: 'owl'
    'uuid':
      exports: 'uuid'
    'materialize':
      exports: 'Materialize'
      deps: ['jquery', 'hammerjs', 'velocity']
  baseUrl: "bin/"
  paths:
    'hammerjs': 'external/hammer.min'
    'jquery': 'external/jquery.min'
    'materialize': 'external/materialize'
    'moment': 'external/moment.min'
    'mithril': 'external/mithril.min'
    'pouchdb': 'external/pouchdb-6.1.1.min'
    'pouchdb-collate': 'external/pouchdb-collate'
    'pouchdb-erase': 'external/pouchdb-erase.min'
    'pouchdb-search': 'external/pouchdb.quick-search'
    'pouchdb-upsert': 'external/pouchdb.upsert.min'
    'underscore': 'external/underscore-min'
    'velocity': 'external/velocity.min'
    'arbiter': 'external/promissory-arbiter'
    'es6-promise': 'external/es6-promise.min'
    'dropzone': 'external/dropzone-amd-module'
    'spellcheck': 'external/spellcheck/include'
    'uuid': 'external/uuid.min'
requirejs [
  'uuid'
  'mithril'
  'errorLogger'
  'chatCommands'
  'emoticons'
  'plugins'
  'promisePolyfill'
  'messageRenderer'
  'messagesManager'
  'scrollManager'
  'uiSetup'
  'inputManager'
  'idleManager'
  'settings'
  'fileCache'
  'fileManager'
  'markov'
  ],
() ->
  window.baseTitle = "Bonfire"
