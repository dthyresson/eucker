module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    move: {
      eucker: {
        src: ['src/*.coffee'],
        dest: 'scripts/*.coffee',
      }
    }
  });

  // Load the plugins
  grunt.loadNpmTasks('grunt-contrib');

  // Default task(s).
  grunt.registerTask('default', ['move']);

};
