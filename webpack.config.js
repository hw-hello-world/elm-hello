const path = require('path');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
  entry: [
    'babel-polyfill',
    './src/app.js',
  ],
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js',
    library: 'bundle',
  },
  devtool: 'source-map',
  plugins: [
    new CopyWebpackPlugin([
      { from: 'public' }
    ]),
  ],
  devServer: {
    inline: true,
    proxy: {
      '/api': {
        target: 'http://rain.okta1.com:1802/',
        secure: false,
        changeOrigin: true,
        logLevel: 'debug',
        headers: {
          'Authorization': 'SSWS 00opZbjVg6j9B3yh6IqgCZpwnqkKh2KBoPaYL3QPLF',
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      }
    }
  },
  module: {
    noParse: /\.elm$/,
    loaders: [
      {
        loader: 'babel-loader',
        test: /\.js$/,
        include: path.join(__dirname, 'src'),
        query: {
          presets: ['es2015'],
        },
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: 'elm-webpack',
      },
    ],
  },
  debug: true,
};
