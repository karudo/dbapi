if (process.env.KARUDODEV === '1') {
  require('coffee-script/register');
  module.exports = require('./src');
} else {
  module.exports = require('./lib');
}