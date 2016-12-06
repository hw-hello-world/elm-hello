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
