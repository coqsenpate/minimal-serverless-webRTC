var path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

BUILD_PATH = 'build';

module.exports = {
	mode: 'development',
	entry: './src/main.coffee',
	output: {
		path: path.resolve(__dirname, BUILD_PATH),
		filename: 'main.js'
	},
	devtool: 'inline-source-map',
	devServer: {
		contentBase: './build'
	},
	module: {
		rules: [{
			test: /\.css$/,
			use: [
				'style-loader',
				'css-loader'
			]}
		,	{
			test: /\.s(c|a)ss$/,
			use: [
				'style-loader',
				'css-loader',
				'sass-loader'
			]}
		,
			{
			test: /\.coffee$/,
			use: [ 'coffee-loader' ]}
		]
	},
	resolve: {
		extensions: [ '.js', '.coffee', '.css', '.scss' ]
	},
	plugins: [
		new HtmlWebpackPlugin({
			template: "./src/index.html",
			title: "Serverless webRTC"
		})
	]
};
