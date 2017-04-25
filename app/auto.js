const git = require('simple-git')
const firebase = require('firebase')
const config = require('./config')

firebase.initializeApp(config)

var ref = firebase.database().ref().child("servers")

ref.child(config.device).on('value', autoPull)

// process.on('SIGINT', function() {
//   process.exit()
// });

var running = false

// setInterval(function() {
//   if (running == true) return false;
//   running = true
//   autoPull()
// }, config.interval || 30000) // 30000

function autoPull (data) {
  // console.log(data.val())
  git()
    .then(function() {
      console.log('Starting pull ...')
    })
    .pull(function(err, update) {
      if(update && update.summary.changes) {
        console.log('processing and restarting app ...')
      }
    })
    .then(function() {
      console.log('pull done.')
      running = false
    })
}
