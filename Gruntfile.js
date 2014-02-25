module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    copy: {
      main: {
        files: [
          {expand: true, flatten: true, src: ['src/*.coffee'], dest: 'scripts/', filter: 'isFile'}
          ]
      },
    }
  });

  // Load the plugins
  grunt.loadNpmTasks('grunt-contrib');

  // Default task(s).
  grunt.registerTask('default', ['copy']);

};
