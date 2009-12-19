function download(post_url, blip) {
  new Ajax.Request(post_url, {
parameters: { 'blip' : Object.toJSON(blip), 
  'convert_to_audio' : false},
    onSuccess: function(response) {
      alert("complete");
    },
onFailure: function(response) {
alert("failed");
}
  });
}

function downloadAndConvert(post_url, blip) {
  new Ajax.Request(post_url, {
parameters: { 'blip' : Object.toJSON(blip), 
  'convert_to_audio' : true},
    onSuccess: function(response) {
      alert("complete");
    },
onFailure: function(response) {
alert("failed");
}
  });
}
