"use strict";

const gulp = require('gulp');
const path = require('path');
const del = require('del');
const runSequence = require('run-sequence');
const zip = require('gulp-zip');
const tap = require('gulp-tap');
const {exec} = require('child_process');

// Control Constants
const MODULE_NAME="sensor-authorizer"
const OUTPUT_FILE_NAME = getArtifactName();

// Define where files will be place
const PROJECT_ROOT = ".";
const SRC_DIR = `${PROJECT_ROOT}/src`
const DIST_DIR = `${PROJECT_ROOT}/dist-${MODULE_NAME}`;
const TARGET_DIR = `${PROJECT_ROOT}/target-${MODULE_NAME}`;

// Delete dist dir
gulp.task('clean-dist', () => {
  return del.sync(DIST_DIR);
});

// Delete delivery dir
gulp.task('clean-delivery', () => {
    return del.sync(TARGET_DIR);
});

gulp.task('clean-delivery', () => {
    return del.sync(TARGET_DIR);
});

gulp.task('installPackages', (cb) => {
  exec(`cd ${DIST_DIR} && npm install --production=true`, (err => {cb(err)}));
});


gulp.task('copyBaseFiles', () => {
  return gulp.src(
    [
      `${PROJECT_ROOT}/package.json`,
    ]
  )
  .pipe(gulp.dest(DIST_DIR));
});


gulp.task('copySrcFiles', () => {
  return gulp.src(
    [
      `${SRC_DIR}/**/*`
    ]
  ).pipe(gulp.dest(`${DIST_DIR}`));
});


gulp.task('writeTerraformVariables', () => {
  writeTerraformVariables();
});



// Zip dist directory
// We use tab to determine if file should be directory, executable, config or regular
// file and set the mode explicitly in the zip file.
// This allows windows builds to work correctly when unzipping to Linux
gulp.task('createZip', () => {
  del.sync(`${DIST_DIR}/local_modules`);
  let dirMode = parseInt('40755', 8);
  let fileMode = parseInt('100644', 8);
  return gulp.src(`${DIST_DIR}/**/*`)
         .pipe(tap((file) => {
            if (file.stat.isDirectory()) {
              file.stat.mode = dirMode;
            } else {
              file.stat.mode = fileMode;
            }
         }))
         .pipe(zip(OUTPUT_FILE_NAME))
         .pipe(gulp.dest(`${TARGET_DIR}`));
});

gulp.task('done', () => {
  console.log(`Distribution created in ${path.resolve(DIST_DIR)}`);
  console.log(`Zipped delivery file created in ${path.resolve(TARGET_DIR)}`);
  console.log("Done!");
});

gulp.task('clean', () => {
  runSequence(
    'clean-dist',
    'clean-delivery'
  );
});


gulp.task('build', async () => {
  runSequence(
    'clean',
    'copyBaseFiles',
    'copySrcFiles',
    'installPackages',
    'createZip',
    'done'
  );
});


function getArtifactName() {
  let packagejson = require("./package.json");
  let artifactName = `${MODULE_NAME}.${packagejson.version}.zip`;
  return artifactName;
}