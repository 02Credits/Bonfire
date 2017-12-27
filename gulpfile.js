var gulp = require("gulp");
var gutil = require("gulp-util");
var exec = require('child_process').exec;
var spawn = require('child_process').spawn;
var electronPath = require('electron');

gulp.task("webpack", function(cb) {
  let child = exec("webpack --color");
  child.on('exit', (code, signal) => {
    console.log("webpack finished.");
    cb();
  });

  child.stdout.on("data", (data) => {
    console.log(data);
  });
  child.stderr.on("data", (data) => {
    console.log(data);
  });
});

gulp.task("webpack-dev-server", function() {
  let child = exec("webpack-dev-server --color");
  child.on('exit', (code, signal) => {
    console.log("webpack finished.");
    cb();
  });

  child.stdout.on("data", (data) => {
    console.log(data);
  });
  child.stderr.on("data", (data) => {
    console.log(data);
  });
});

gulp.task("run", function () {
  exec(electronPath + " " + __dirname);
});

gulp.task("run-dev", function (cb) {
  let child = exec(electronPath + " " + __dirname + " -d");
  child.on('exit', (code, signal) => {
    console.log('electron quit.');
    cb();
  });

  child.stdout.on("data", (data) => {
    console.log(data);
  });
});

gulp.task("live", ["webpack-dev-server", "run-dev"]);

gulp.task("dev", ["webpack"], function () {
  gulp.start("live");
});

gulp.task("default", ["webpack"]);
