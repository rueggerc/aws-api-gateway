"use strict";

const path = require('path');
const del = require('del');
const gulp = require('gulp');
const tap = require('gulp-tap');
const runSequence = require('run-sequence');
const zip = require('gulp-zip');
const replaceInFile = require('replace-in-file');


// Define where files will be place
const PROJECT_ROOT = ".";
const DIST_DIR = `${PROJECT_ROOT}/dist`;
const TARGET_DIR = `${PROJECT_ROOT}/target`;
const UBER_ZIP = getArtifactName();
const VERSION = getVersion();
const TERRAFORM_DIR = `${PROJECT_ROOT}/terraform`;

// Sub-ZIP files
const AUTHORIZER_ZIP = `${PROJECT_ROOT}/target-sensor-authorizer/sensor-authorizer.${VERSION}.zip`;

// Delete dist dir
gulp.task('clean-dist', () => {
  return del.sync(DIST_DIR);
});

// Delete target dir
gulp.task('clean-target', () => {
    return del.sync(TARGET_DIR);
});

gulp.task('clean-target', () => {
    return del.sync(TARGET_DIR);
});

gulp.task('writeTerraformVariables', () => {
  writeTerraformVariables();
});

gulp.task('copyTerraformFiles', () => {
  return gulp.src(
    [
      `${TERRAFORM_DIR}/**/*`,
    ]
  ).pipe(gulp.dest(`${DIST_DIR}`));
});

gulp.task('copyZipFiles', () => {
  return gulp.src(
    [
      `${AUTHORIZER_ZIP}`
    ]
  ).pipe(gulp.dest(`${DIST_DIR}`));
});



// Zip dist directory
// We use tab to determine if file should be directory, executable, config or regular
// file and set the mode explicitly in the zip file.
// This allows windows builds to work correctly when unzipping to Linux
gulp.task('createZip', () => {
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
         .pipe(zip(UBER_ZIP))
         .pipe(gulp.dest(`${TARGET_DIR}`));
});

gulp.task('done', () => {
  console.log(`Distribution created in ${path.resolve(DIST_DIR)}`);
  console.log(`Zipped target file created in ${path.resolve(TARGET_DIR)}`);
  console.log("Done!");
});

gulp.task('clean', () => {
  runSequence(
    'clean-dist',
    'clean-target'
  );
});


gulp.task('build', async () => {
  runSequence(
    'clean',
    'copyTerraformFiles',
    'copyZipFiles',
    'writeTerraformVariables',
    'createZip',
    'done'
  );
});

function getArtifactName() {
  let packagejson = require("./package.json");
  let artifactName = `${packagejson.name}.${packagejson.version}.zip`;
  return artifactName;
}

function getVersion() {
  let packagejson = require("./package.json");
  return packagejson.version;
}

function writeTerraformVariables() {
  try {
    console.log("Writing Terraform Variables");
    let options = {
      files: `${DIST_DIR}/vars/*.tfvars`,
      from: /\${version}/g,
      to: getVersion()
    };
    console.log(replaceInFile.sync(options));

  } catch (err) {
    console.log("Error Writing Terraform Variables: " + err);
  }
}
