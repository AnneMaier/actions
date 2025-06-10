var express = require('express');
var app = express();


app.get('/', function(req, res) {
    res.json("hello node js")
})


app.listen(8000, function(){
    console.log("server star!t")
})