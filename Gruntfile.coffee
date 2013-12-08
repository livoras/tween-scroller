module.exports = (grunt)->
  process.env.DEBUG = 'facility'

  grunt.initConfig
    clean: 
      bin: ['bin']
      build: ['dist']

    connect: 
      server: 
        options: 
          port: 9001,

    coffee:
      src: 
        expand: true
        flatten: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'bin/'
        ext: '.js'
      test:  
        expand: true 
        flatten: true
        cwd: 'test'
        src: ['**/*.coffee']
        dest: 'bin/'
        ext: '.spec.js'
      build:
        files: [
          expand: true 
          flatten: true
          cwd: 'src'
          src: ['**/*.coffee']
          dest: 'bin/'
          ext: '.js'
        ]

    less:
      development: 
        files: 
          "bin/tween-scroller.css": "src/tween-scroller.less"    
      build:    
        files: 
          "dist/tween-scroller.min.css": "src/tween-scroller.less"    
        options:  
          compress: true
          ipCompat: true
          cleancss: true


    watch:
      compile:
        files: ["src/**/*.coffee", "src/**/*.less","test/**/*.coffee", "example/**/*"]
        tasks: ["coffee:src", "coffee:test", "less:development"]
        options: 
          livereload: true

    uglify:     
      build:
        options:
          compress: true
        files:   
          "dist/tween-scroller.min.js": ["bin/tween-scroller.js"]

  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-less"
  grunt.loadNpmTasks "grunt-contrib-uglify";

  grunt.registerTask "default", [
    "clean:bin"
    "connect" 
    "coffee:src" 
    "coffee:test"
    "less:development"
    "watch"
  ]

  grunt.registerTask "build", [
    "clean:build", 
    "coffee:build"
    "less:build"
    "uglify:build"
  ]