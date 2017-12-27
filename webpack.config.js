const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

const commonConfig = {
  output: {
    path: path.resolve(__dirname, "bin"),
    filename: '[name].js',
    publicPath: '/bin/',
    devtoolModuleFilenameTemplate: function(info){
      return "../" + info.resourcePath;
    }
  },
  module: {
    rules: [
      {
        test: /\.ts$/,
        exclude: /node_modules/,
        loader: 'ts-loader'
      }, {
        test: /\.css$/,
        use: ['style-loader', 'css-loader']
      }
    ]
  },
  resolve: {
    extensions: ['.ts', '.js', '.css']
  },
  node: {__dirname: false}
};

module.exports = [
  Object.assign({
    target: 'electron-main',
    entry: {main: './src/main.ts'},
    devServer: {
      inline: true,
      port: 8080
    }
  }, commonConfig),
  Object.assign({
    target: 'electron-renderer',
    entry: {gui: './src/gui.ts'},
    plugins: [new HtmlWebpackPlugin({
      inject: false,
      template: require('html-webpack-template'),
      appMountId: 'app',
      title: 'Bonfire',
      devServer: 'http://localhost:8080'
    })],
    devServer: {
      inline: true,
      port: 8080
    }
  }, commonConfig)
];
